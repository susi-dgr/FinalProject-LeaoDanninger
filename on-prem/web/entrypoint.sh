#!/bin/sh
set -eu
cat > /usr/share/nginx/html/index.html <<'EOF'
<html>
  <head>
    <meta charset="utf-8" />
    <title>Traefik Load Balancing Test</title>
  </head>
  <body>
    <h1>Served by: __HOSTNAME__</h1>
    <p>Refresh the page to see load balancing across containers.</p>
  </body>
</html>
EOF

sed -i "s/__HOSTNAME__/$(hostname)/g" /usr/share/nginx/html/index.html
exec nginx -g 'daemon off;'