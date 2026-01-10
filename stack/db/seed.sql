INSERT INTO orders (order_id, customer_id, total, current_status)
VALUES
  ('1', '1', 59.90, 'PAID'),
  ('2', '2', 19.99, 'PLACED'),
  ('3', '3', 120.00, 'SHIPPED')
ON DUPLICATE KEY UPDATE customer_id=VALUES(customer_id), total=VALUES(total), current_status=VALUES(current_status);

INSERT INTO order_items (order_id, qty, price)
VALUES
  ('1', 1, 29.95),
  ('2', 1, 29.95),
  ('3', 1, 19.99),
  ('4', 2, 60.00);

INSERT INTO order_status_history (order_id, status)
VALUES
  ('1', 'PLACED'),
  ('1', 'PAID'),
  ('2', 'PLACED'),
  ('3', 'PLACED'),
  ('3', 'PAID'),
  ('3', 'SHIPPED');