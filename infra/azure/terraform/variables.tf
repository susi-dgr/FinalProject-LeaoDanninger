variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "resourcegn-oms"
}

variable "eventhub_namespace_name" {
  description = "Event Hubs namespace name (must be globally unique)"
  type        = string
}

variable "eventhub_name" {
  description = "Event Hub name"
  type        = string
  default     = "orders"
}

variable "consumer_group_name" {
  description = "Consumer group name"
  type        = string
  default     = "oms-consumer"
}

variable "sku" {
  description = "Event Hubs SKU"
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Throughput units (Standard only)"
  type        = number
  default     = 1
}

variable "partition_count" {
  description = "Partitions for the Event Hub"
  type        = number
  default     = 2
}

variable "message_retention" {
  description = "Retention in days"
  type        = number
  default     = 7
}