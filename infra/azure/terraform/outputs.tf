output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "eventhub_namespace_name" {
  value = azurerm_eventhub_namespace.ns.name
}

output "eventhub_name" {
  value = azurerm_eventhub.hub.name
}

output "consumer_group_name" {
  value = azurerm_eventhub_consumer_group.cg.name
}

# This is the namespace-level connection string with send/listen rights.
# Treat as a secret (don’t commit it).
output "eventhub_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.app.primary_connection_string
  sensitive = true
}
