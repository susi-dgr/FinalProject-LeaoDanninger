# Online Shopping Order Processing System 
**Contributors:** Luiz Leão Junior and Susanne Danninger 

## Order Management System Architecture

### How to run (Phase 1: local Docker Compose)
1. Move to the `stack/` directory:
```shell
cd stack
```

2. Docker Compose
```shell
docker compose build
```

3. Start the services (with 3 web instances for load balancing):
```shell
docker compose up -d --scale web=3
```
- Web UI at: `http://localhost/`
- API at: `http://localhost/api/orders?limit=5`
- Health at: `http://localhost/api/health`

4. Stop the services:
```shell
docker compose down
```
