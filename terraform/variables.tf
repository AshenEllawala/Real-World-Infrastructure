variable "app_name" {
  type        = string
  description = "Application name"
  default     = "myapp"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name"
  default     = "myapp-rg"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastasia"
}

variable "db_username" {
  type        = string
  description = "Database admin username"
  default     = "appuser"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Production"
    Project     = "RealWorldInfrastructure"
  }
}
