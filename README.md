# Online Shopping Order Processing System 
**Contributors:** Luiz Leão Junior and Susanne Danninger 

## Order Management System Architecture

### How to run 
#### Phase 1: local Docker Compose
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

#### Phase 2: Azure Event Hub 
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