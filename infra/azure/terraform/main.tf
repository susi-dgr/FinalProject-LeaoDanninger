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

resource "azurerm_eventhub" "hub" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.ns.name
  resource_group_name = azurerm_resource_group.rg.name

  partition_count   = var.partition_count
  message_retention = var.message_retention
}

resource "azurerm_eventhub_consumer_group" "cg" {
  name                = var.consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.ns.name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Shared Access Policy for apps (send/listen/manage via keys)
resource "azurerm_eventhub_namespace_authorization_rule" "app" {
  name                = "oms-app"
  namespace_name      = azurerm_eventhub_namespace.ns.name
  resource_group_name = azurerm_resource_group.rg.name

  listen = true
  send   = true
  manage = false
}
