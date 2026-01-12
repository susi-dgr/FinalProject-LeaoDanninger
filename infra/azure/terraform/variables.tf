variable "location" {
  description = "Azure region"
  type        = string
  default     = "swedencentral"
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

variable "storage_account_name" {
  description = "Storage account name for Event Hub Capture (3-24 lowercase letters/numbers, globally unique)"
  type        = string
}

variable "storage_container_name" {
  description = "Blob container name for Event Hub Capture"
  type        = string
  default     = "eventhub-archive"
}

variable "capture_enabled" {
  description = "Enable Event Hubs Capture to Blob Storage for long-term archiving"
  type        = bool
  default     = true
}

variable "capture_encoding" {
  description = "Capture encoding (Avro is standard)"
  type        = string
  default     = "Avro"
}

variable "capture_interval_seconds" {
  description = "Capture time window in seconds"
  type        = number
  default     = 300
}

variable "capture_size_limit_bytes" {
  description = "Capture size window in bytes"
  type        = number
  default     = 314572800 # 300 MB
}

variable "capture_skip_empty_archives" {
  description = "Skip writing empty capture files"
  type        = bool
  default     = true
}
