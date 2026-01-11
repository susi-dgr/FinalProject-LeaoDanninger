# Online Shopping Order Processing System 
**Contributors:** Luiz Leão Junior and Susanne Danninger 

## Order Management System Architecture

### How to run 
#### On-Prem Setup with Docker Compose
1. Move to the `on-prem/` directory:
```shell
cd on-prem
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
- Health at: `http://localhost/api/health`
- Traefik dashboard at: `http://localhost:8080/dashboard/#/http/services`

5. Stop the services:
```shell
docker compose down
```

#### Azure Event Hub 
1. Login to Azure CLI and set subscription:
```shell
az login
```

Show your subscription ID:
```shell
az account list -o table
```

Set your subscription (replace `<SUBSCRIPTION_ID>` with your own):
```shell
az account set --subscription <SUBSCRIPTION_ID>
```

Make sure the right location for your resources is set in `terraform.tfvars`.

2. Terraform commands to create the Event Hub infrastructure:
```shell
terraform init
terraform plan
terraform apply
```

#### Testing with Postman
- post a new order: 
```
http://localhost/api/orders
Body (JSON):
{
  "orderId": "ORD-1010",
  "customerId": "CUST-123",
  "total": 20,
  "items": [
    { "sku": "SKU-001", "qty": 2, "price": 10 },
    { "sku": "SKU-ABC", "qty": 1, "price": 10 }
  ]
}
```

- Get all orders:
```
http://localhost/api/orders
```