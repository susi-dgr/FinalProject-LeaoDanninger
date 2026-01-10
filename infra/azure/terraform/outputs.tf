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
output "eventhub_send_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.send.primary_connection_string
  sensitive = true
}

output "eventhub_listen_connection_string" {
  value     = azurerm_eventhub_namespace_authorization_rule.listen.primary_connection_string
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.archive.name
}

output "storage_container_name" {
  value = azurerm_storage_container.archive.name
}
