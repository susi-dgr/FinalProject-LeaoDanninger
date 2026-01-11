const mysql = require("mysql2/promise");
const {
  EventHubConsumerClient,
  earliestEventPosition,
  latestEventPosition,
} = require("@azure/event-hubs");
const { BlobServiceClient } = require("@azure/storage-blob");
const { BlobCheckpointStore } = require("@azure/eventhubs-checkpointstore-blob");

const {
  // Event Hub
  EVENTHUB_CONNECTION_STRING,
  EVENTHUB_NAME,
  EVENTHUB_CONSUMER_GROUP = "oms-consumer",

  // Blob checkpoint store (NOT your capture archive container)
  AZURE_STORAGE_CONNECTION_STRING,
  CHECKPOINT_CONTAINER = "eh-checkpoints",

  // MySQL
  MYSQL_HOST = "db",
  MYSQL_PORT = "3306",
  MYSQL_DATABASE = "oms",
  MYSQL_USER = "oms_user",
  MYSQL_PASSWORD = "oms_pass",

  // Behavior
  START_POSITION = "latest", // "latest" or "earliest"
} = process.env;

function mustGet(name, val) {
  if (!val) throw new Error(`Missing required env var: ${name}`);
  return val;
}

function normalizeItems(items) {
  if (!Array.isArray(items)) return [];
  return items.map((it) => ({
    sku: String(it?.sku || "SKU-001"),
    qty: Number(it?.qty ?? 1),
    price: Number(it?.price ?? 9.99),
  }));
}

async function ensureCheckpointContainer() {
  const conn = mustGet("AZURE_STORAGE_CONNECTION_STRING", AZURE_STORAGE_CONNECTION_STRING);
  const blobServiceClient = BlobServiceClient.fromConnectionString(conn);
  const containerClient = blobServiceClient.getContainerClient(CHECKPOINT_CONTAINER);
  await containerClient.createIfNotExists();
  return containerClient;
}

async function initMysqlPool() {
  return mysql.createPool({
    host: MYSQL_HOST,
    port: parseInt(MYSQL_PORT, 10),
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: MYSQL_DATABASE,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });
}

async function upsertOrderTx(conn, { orderId, customerId, total }) {
  await conn.query(
    `INSERT INTO orders (order_id, customer_id, total, current_status)
     VALUES (?, ?, ?, 'PLACED')
     ON DUPLICATE KEY UPDATE customer_id=VALUES(customer_id), total=VALUES(total)`,
    [orderId, customerId, total]
  );

  // Insert status history only if not already there (idempotent)
  await conn.query(
    `INSERT INTO order_status_history (order_id, status)
     SELECT ?, 'PLACED'
     WHERE NOT EXISTS (
       SELECT 1 FROM order_status_history WHERE order_id=? AND status='PLACED'
     )`,
    [orderId, orderId]
  );
}

async function upsertItemsTx(conn, { orderId, items }) {
  for (const it of items) {
    // Requires UNIQUE(order_id, sku) for true idempotency
    await conn.query(
      `INSERT INTO order_items (order_id, sku, qty, price)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE qty=VALUES(qty), price=VALUES(price)`,
      [orderId, it.sku, it.qty, it.price]
    );
  }
}

async function processOrderCreated(pool, msg) {
  const order = msg?.order;
  if (!order?.orderId) {
    console.warn("[processor] skipping event: missing order.orderId");
    return;
  }

  const orderId = String(order.orderId);
  const customerId = String(order.customerId || "CUST-001");
  const total = Number(order.total ?? 0);
  const items = normalizeItems(order.items);

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    await upsertOrderTx(conn, { orderId, customerId, total });
    await upsertItemsTx(conn, { orderId, items });

    await conn.commit();
    console.log(`[processor] stored order ${orderId} (items=${items.length})`);
  } catch (e) {
    await conn.rollback();
    console.error(`[processor] db error for order ${orderId}:`, e?.message || e);
    throw e;
  } finally {
    conn.release();
  }
}

async function main() {
  mustGet("EVENTHUB_CONNECTION_STRING", EVENTHUB_CONNECTION_STRING);
  mustGet("EVENTHUB_NAME", EVENTHUB_NAME);

  const pool = await initMysqlPool();

  // Quick DB check
  await pool.query("SELECT 1");

  const checkpointContainerClient = await ensureCheckpointContainer();
  const checkpointStore = new BlobCheckpointStore(checkpointContainerClient);

  const consumer = new EventHubConsumerClient(
    EVENTHUB_CONSUMER_GROUP,
    EVENTHUB_CONNECTION_STRING,
    EVENTHUB_NAME,
    checkpointStore
  );

  console.log(`[processor] consumer group: ${EVENTHUB_CONSUMER_GROUP}`);
  console.log(`[processor] start position: ${START_POSITION}`);
  console.log("[processor] listening...");

  const startPosition =
    (START_POSITION || "").toLowerCase() === "earliest"
      ? earliestEventPosition
      : latestEventPosition;

  const subscription = consumer.subscribe(
    {
      processEvents: async (events, context) => {
        for (const event of events) {
          const msg = event.body;

          try {
            if (msg?.type === "OrderCreated") {
              await processOrderCreated(pool, msg);
            } else {
              // ignore other event types for now
              // console.log("[processor] ignoring event type:", msg?.type);
            }

            // checkpoint AFTER successful processing
            await context.updateCheckpoint(event);
          } catch (e) {
            // If processing fails, we do NOT checkpoint (so it can be retried)
            console.error("[processor] processing failed; will retry on next run/receive");
          }
        }
      },
      processError: async (err, context) => {
        console.error(`[processor] error on partition ${context.partitionId}:`, err);
      },
    },
    { startPosition }
  );

  const shutdown = async () => {
    console.log("\n[processor] shutting down...");
    await subscription.close();
    await consumer.close();
    await pool.end();
    process.exit(0);
  };

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

main().catch((e) => {
  console.error("[processor] fatal:", e?.message || e);
  process.exit(1);
});
