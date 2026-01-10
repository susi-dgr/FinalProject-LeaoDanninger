CREATE TABLE IF NOT EXISTS orders (
  order_id        VARCHAR(64) PRIMARY KEY,
  customer_id     VARCHAR(64) NOT NULL,
  total           DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS order_items (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id   VARCHAR(64) NOT NULL,
  quantity   INT NOT NULL,
  price      DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE IF NOT EXISTS order_status_history (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id   VARCHAR(64) NOT NULL,
  status     VARCHAR(32) NOT NULL,
  timestamp  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hist_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_hist_order_ts ON order_status_history(order_id, ts);


