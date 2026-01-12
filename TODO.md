## TODO 

Note: This might change in the process

- [x] On-Prem (Docker): Traefik reverse proxy / load balancer in front of Nginx web tier
  - [x] Run at least 3 Nginx instances behind Traefik and verify load balancing
  - [x] Expose API through Traefik routing (`/api/*` → NodeJS)

- [x] On-Prem (Docker): MySQL operational database
  - [x] Create DB schema: `orders`, `order_items`, `order_status_history`
  - [x] Add initial seed/demo data
  - [ ] Add more demo data 

- [x] Azure Cloud (Terraform): Event streaming + long-term archive path (10+ years requirement)
  - [x] Terraform scaffold: `versions.tf`, `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`
  - [x] Create Resource Group
  - [x] Create Event Hubs Namespace
  - [x] Create Event Hub `orders`
  - [x] Create Consumer Group `oms-consumer`
  - [x] Output required values (names + connection string) for use by on-prem services

- [x] OMS backend integration (on-prem → Azure Event Hub → on-prem processing → MySQL)

- [x] Event generation for demo (to prove end-to-end streaming)
  - [x] Implement an event producer (API endpoint)
  - [x] Publish simulated order events into Azure Event Hub

- [x] Build an AI Agent using learned tools in class to query the Orders Database
(MySql) in natural language.

- [x] One command to build on-prem stack via Ansible

- [ ] One-command end-to-end deployment (Azure infra + on-prem stack)

- [ ] Documentation (README.md + docs/)
  - [ ] Include the architecture diagram + short explanation of each component (Frontend, Event Hub, NodeJS processing, MySQL)
  - [ ] Describe the end-to-end flow (Client → Traefik → Nginx/API → Event Hub → NodeJS processing → MySQL)
  - [ ] Describe the setup
  - [x] Step-by-step run instructions (local + on-prem via Ansible; Azure via Terraform/Azure CLI)
  - [ ] “Learnings & challenges” section (routing conflicts, env/secrets handling, Event Hub auth, retries, etc.)  