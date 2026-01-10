resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_eventhub_namespace" "ns" {
  name                = var.eventhub_namespace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku      = var.sku
  capacity = var.capacity

  tags = {
    project = "oms"
  }
}

# Storage account for long-term archive (Event Hubs Capture)
resource "azurerm_storage_account" "archive" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Optional but common defaults
  allow_nested_items_to_be_public = false
  min_tls_version                = "TLS1_2"

  tags = {
    project = "oms"
  }
}

resource "azurerm_storage_container" "archive" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.archive.name
  container_access_type = "private"
}

# Event Hub with Capture enabled -> Blob Storage
resource "azurerm_eventhub" "hub" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.ns.name
  resource_group_name = azurerm_resource_group.rg.name

  partition_count   = var.partition_count
  message_retention = var.message_retention

  # Capture configuration (archives to Storage for 10+ years)
  capture_description {
    enabled             = var.capture_enabled
    encoding            = var.capture_encoding
    interval_in_seconds = var.capture_interval_seconds
    size_limit_in_bytes = var.capture_size_limit_bytes
    skip_empty_archives = var.capture_skip_empty_archives

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      storage_account_id  = azurerm_storage_account.archive.id
      blob_container_name = azurerm_storage_container.archive.name

      # Events will be written under this prefix inside the container
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
    }
  }
}

resource "azurerm_eventhub_consumer_group" "cg" {
  name                = var.consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.ns.name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Authorization rules for sending and receiving
resource "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = "oms-send"
  namespace_name      = azurerm_eventhub_namespace.ns.name
  resource_group_name = azurerm_resource_group.rg.name

  send   = true
  listen = false
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "listen" {
  name                = "oms-listen"
  namespace_name      = azurerm_eventhub_namespace.ns.name
  resource_group_name = azurerm_resource_group.rg.name

  send   = false
  listen = true
  manage = false
}


