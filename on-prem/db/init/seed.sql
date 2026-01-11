INSERT INTO orders (order_id, customer_id, total, current_status)
VALUES
  ('ORDER-1001', 'CUST-001', 59.90, 'PAID'),
  ('ORDER-1002', 'CUST-002', 19.99, 'PLACED'),
  ('ORDER-1003', 'CUST-003', 120.00, 'SHIPPED')
ON DUPLICATE KEY UPDATE customer_id=VALUES(customer_id), total=VALUES(total), current_status=VALUES(current_status);

INSERT INTO order_items (order_id, sku, qty, price)
VALUES
  ('ORDER-1001', 'SKU-AAA', 1, 29.95),
  ('ORDER-1001', 'SKU-BBB', 1, 29.95),
  ('ORDER-1002', 'SKU-CCC', 1, 19.99),
  ('ORDER-1003', 'SKU-DDD', 2, 60.00);

INSERT INTO order_status_history (order_id, status)
VALUES
  ('ORDER-1001', 'PLACED'),
  ('ORDER-1001', 'PAID'),
  ('ORDER-1002', 'PLACED'),
  ('ORDER-1003', 'PLACED'),
  ('ORDER-1003', 'PAID'),
  ('ORDER-1003', 'SHIPPED');
