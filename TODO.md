## TODO 

Note: This might change in the process

- [x] On-Prem (Docker): Traefik reverse proxy / load balancer in front of Nginx web tier
  - [x] Run at least 3 Nginx instances behind Traefik and verify load balancing
  - [x] Expose API through Traefik routing (`/api/*` → NodeJS)

- [x] On-Prem (Docker): MySQL operational database
  - [x] Create DB schema: `orders`, `order_items`, `order_status_history`
  - [x] Add initial seed/demo data
  - [ ] Add more demo data (more orders, multiple statuses, date ranges, customers, products)

- [ ] Azure Cloud (Terraform): Event streaming + long-term archive path (10+ years requirement)
  - [ ] Terraform scaffold: `versions.tf`, `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`
  - [ ] Create Resource Group
  - [ ] Create Event Hubs Namespace
  - [ ] Create Event Hub `orders`
  - [ ] Create Consumer Group `oms-consumer`
  - [ ] Output required values (names + connection string) for use by on-prem services

- [ ] Azure CLI bootstrap (repeatable setup for Terraform auth)
  - [ ] `az login` and set subscription
  - [ ] Create Service Principal for Terraform (RBAC)
  - [ ] Export `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`
  - [ ] Provide `scripts/bootstrap_azure.sh` (or `.ps1` on Windows) + short README usage

- [ ] OMS backend integration (matches diagram flow: on-prem → Azure Event Hub → on-prem processing → MySQL)
  - [ ] Update NodeJS order-processing service to **consume** from Azure Event Hub (`orders`, `oms-consumer`)
  - [ ] Validate incoming event JSON schema (`orderId`, `customerId`, `status`, `timestamp`, `total`, `items[]`)
  - [ ] Persist to MySQL:
    - [ ] Upsert into `orders` (current status + totals + timestamps)
    - [ ] Insert into `order_items`
    - [ ] Append into `order_status_history`
  - [ ] Add retry/backoff + error handling (Event Hub and DB)
  - [ ] Add structured logs per event (orderId, status, processing result)

- [ ] Event generation for demo (to prove end-to-end streaming)
  - [ ] Implement an event producer (CLI or endpoint like `/api/generate`)
  - [ ] Publish simulated order events into Azure Event Hub
  - [ ] Provide a short “demo script” to generate N events and show DB rows increase

- [ ] Build an AI Agent using learned tools in class to query the Orders Database
(MySql) in natural language.

- [ ] Automation / orchestration (deliverable: deploy infra + deploy app once servers are up)
  - [ ] Ansible: install Docker Engine + Docker Compose plugin on target on-prem host/VM
  - [ ] Ansible: deploy repo (clone/copy), render `.env` from template, start stack (`docker compose up -d`)
  - [ ] Ansible: verification tasks (containers running, `/api/health`, DB connectivity, row counts)

- [ ] One-command end-to-end deployment
  - [ ] `scripts/deploy_all.sh`:
    - [ ] Run Terraform init/plan/apply (Azure Event Hub)
    - [ ] Export Terraform outputs into `.env` (or generate `.env` from template)
    - [ ] Run Ansible playbook to deploy on-prem stack
  - [ ] Document expected outputs + how to rollback/clean up

- [ ] Documentation (README.md + docs/)
  - [ ] Include the architecture diagram + short explanation of each component (Frontend, Event Hub, NodeJS processing, MySQL)
  - [ ] Describe the end-to-end flow (Client → Traefik → Nginx/API → Event Hub → NodeJS processing → MySQL)
  - [ ] Step-by-step run instructions (local + on-prem via Ansible; Azure via Terraform/Azure CLI)
  - [ ] Verification checklist (load balancing proof, Event Hub consumption, DB records, AI agent queries)
  - [ ] “Learnings & challenges” section (routing conflicts, env/secrets handling, Event Hub auth, retries, etc.)
