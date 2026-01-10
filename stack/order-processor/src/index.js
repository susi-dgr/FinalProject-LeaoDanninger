const express = require("express");
const mysql = require("mysql2/promise");
const { EventHubProducerClient } = require("@azure/event-hubs"); 

const PORT = parseInt(process.env.PORT || "3000", 10);

const {
  MYSQL_HOST = "db",
  MYSQL_PORT = "3306",
  MYSQL_DATABASE = "oms",
  MYSQL_USER = "oms_user",
  MYSQL_PASSWORD = "oms_pass",

  // Event Hub settings
  EVENTHUB_CONNECTION_STRING,
  EVENTHUB_NAME,
} = process.env;

let pool;

// Event Hub producer (lazy init)
let ehProducer;
function getEventHubProducer() {
  if (!EVENTHUB_CONNECTION_STRING || !EVENTHUB_NAME) return null;
  if (!ehProducer) {
    ehProducer = new EventHubProducerClient(EVENTHUB_CONNECTION_STRING, EVENTHUB_NAME);
  }
  return ehProducer;
}

// publish helper
async function publishOrderCreated({ orderId, customerId, total, items }) {
  const producer = getEventHubProducer();
  if (!producer) {
    // If you want hard-fail when EH isn't configured, throw instead.
    console.warn("[api] Event Hub not configured; skipping publish.");
    return;
  }

  const event = {
    type: "OrderCreated",
    version: 1,
    occurredAt: new Date().toISOString(),
    order: { orderId, customerId, total, items },
  };

  // Partition key keeps related events ordered (optional)
  const partitionKey = String(customerId || orderId);

  const batch = await producer.createBatch({ partitionKey });
  const ok = batch.tryAdd({
    body: event,
    contentType: "application/json",
  });

  if (!ok) {
    // very large payload; consider trimming items or sending separate item events
    throw new Error("Event too large to add to Event Hub batch");
  }

  await producer.sendBatch(batch);
}

async function initDbPool() {
  pool = await mysql.createPool({
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

function requirePool(req, res, next) {
  if (!pool) return res.status(503).json({ ok: false, error: "DB not ready" });
  next();
}

async function main() {
  await initDbPool();

  const app = express();
  app.use(express.json());

  // Health
  app.get("/health", async (req, res) => {
    try {
      const [rows] = await pool.query("SELECT 1 AS ok");
      res.json({ ok: true, db: rows[0]?.ok === 1 });
    } catch (e) {
      res.status(500).json({ ok: false, error: String(e.message || e) });
    }
  });

  // Create a simulated order
  app.post("/orders", requirePool, async (req, res) => {
    const orderId = req.body?.orderId || cryptoRandomId();
    const customerId = req.body?.customerId || "CUST-001";
    const total = Number(req.body?.total ?? 0);

    // Optional items
    const items = Array.isArray(req.body?.items) ? req.body.items : [];

    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      await conn.query(
        `INSERT INTO orders (order_id, customer_id, total, current_status)
         VALUES (?, ?, ?, 'PLACED')
         ON DUPLICATE KEY UPDATE customer_id=VALUES(customer_id), total=VALUES(total)`,
        [orderId, customerId, total]
      );

      await conn.query(
        `INSERT INTO order_status_history (order_id, status)
         VALUES (?, 'PLACED')`,
        [orderId]
      );

      for (const it of items) {
        const sku = String(it.sku || "SKU-001");
        const qty = Number(it.qty ?? 1);
        const price = Number(it.price ?? 9.99);
        await conn.query(
          `INSERT INTO order_items (order_id, sku, qty, price)
           VALUES (?, ?, ?, ?)`,
          [orderId, sku, qty, price]
        );
      }

      await conn.commit();

      // publish AFTER commit (don’t publish an order that failed DB write)
      await publishOrderCreated({ orderId, customerId, total, items });

      res.status(201).json({ ok: true, orderId });
    } catch (e) {
      await conn.rollback();
      res.status(500).json({ ok: false, error: String(e.message || e) });
    } finally {
      conn.release();
    }
  });

  // Read recent orders
  app.get("/orders", requirePool, async (req, res) => {
    const limit = clampInt(req.query.limit, 1, 100, 20);
    const [rows] = await pool.query(
      `SELECT order_id, customer_id, total, current_status, created_at
       FROM orders
       ORDER BY created_at DESC
       LIMIT ?`,
      [limit]
    );
    res.json({ ok: true, data: rows });
  });

  app.listen(PORT, () => {
    console.log(`[api] listening on :${PORT}`);
    console.log(`[api] mysql: ${MYSQL_USER}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}`);
    console.log(`[api] eventhub: ${EVENTHUB_NAME ? EVENTHUB_NAME : "(not configured)"}`);
  });
}

// Helpers
function clampInt(value, min, max, fallback) {
  const n = parseInt(String(value ?? ""), 10);
  if (Number.isNaN(n)) return fallback;
  return Math.max(min, Math.min(max, n));
}

function cryptoRandomId() {
  const s4 = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  return `${s4()}${s4()}-${s4()}-${s4()}-${s4()}-${s4()}${s4()}${s4()}`;
}

main().catch((e) => {
  console.error("[api] fatal:", e);
  process.exit(1);
});
