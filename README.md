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

#### Ansible
1. Build the Ansible runner image:
```shell
docker build --no-cache -f on-prem/ansible/Dockerfile.ansible -t ansible-runner:local on-prem/ansible
```

2. Create .env and set the required variables:
```shell
copy .env.example .env
```

3. Run Ansible to build and start the stack:
```shell
docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/on-prem/ansible `
  -v //var/run/docker.sock:/var/run/docker.sock `
  ansible-runner:local `
  ansible-playbook -i inventory.ini site.yml
```

4. Verify the setup:
- Web UI at: `http://localhost/`
- Health at: `http://localhost/api/health`
- Traefik dashboard at: `http://localhost:8080/dashboard/#/http/services`

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

#### AI Agent 
Langflow Desktop was used to create an AI agent that can query the MySQL database in natural language. To make this work, a few steps are necessary:
1. Install Langflow
2. Modify `requirements.txt` file found in the directory `C:\Users\USER\AppData\Roaming\com.LangflowDesktop\data` (replace `USER` with your Windows username) to include the following packages:
```
pymysql==1.1.1
```
3. Add a global variable in Langflow with the following details:
- Name: `MY-SQL-DB`
- Value: `mysql+pymysql://oms_user:oms_pass@localhost:3306/oms` 
4. Setup the AI agent flow as shown below:
![AI Agent Flow](docs/aiagentflow.png)