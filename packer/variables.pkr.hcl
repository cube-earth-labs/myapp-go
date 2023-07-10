variable "subscription_id" {
    type        = string
    sensitive   = true
}

variable "client_id" {
    type        = string
    sensitive   = true
}

variable "client_secret" {
    type        = string
    sensitive   = true
}

variable "image_name" {
    type        = string
    default     = "cube-ubuntu-myapp"
}

variable "resource_group" {
    type        = string
}

variable "default_base_tags" {
  description = "Required tags for the environment"
  type        = map(string)
  default = {
    owner   = "App Team"
    contact = "myapp@mydomain.com"
  }
}
