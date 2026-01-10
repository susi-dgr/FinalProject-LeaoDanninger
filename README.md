# Online Shopping Order Processing System 
**Contributors:** Luiz Leão Junior and Susanne Danninger 

## Order Management System Architecture

### How to run (phase 1: local Docker Compose)
1. Move to the `stack/` directory:
```shell
cd stack
```
2. Copy the example environment file (or use your own credentials):
```shell
cp .env.example .env
```

3. Docker Compose
```shell
docker compose build
```

4. Start the services (with 3 web instances for load balancing):
```shell
docker compose up -d --scale web=3
```
- Web UI at: `http://localhost/`
- API at: `http://localhost/api/orders?limit=5`
- Health at: `http://localhost/api/health`

5. Stop the services:
```shell
docker compose down
```
