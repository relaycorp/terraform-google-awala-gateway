variable "sre_iam_uri" {
  description = "GCP IAM URI for an SRE or the SRE group (e.g., 'group:sre-team@acme.com')"
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "prevent_destruction" {
  default     = true
  type        = bool
  description = "Whether to prevent destruction of stateful resources"
}

variable "instance_name" {
  description = "The name of the backend"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.instance_name))
    error_message = "Name must be between 1 and 10 characters long, and contain only lowercase letters and digits"
  }
}

variable "internet_address" {
  description = "The Awala Internet address of the gateway (e.g., 'example.com')"
  type        = string
}

variable "docker_image_name" {
  description = "The Docker image to deploy"
  default     = "relaycorp/awala-gateway"
}

variable "docker_image_tag" {
  description = "The Docker image tag to deploy (highly recommended to set this explicitly)"
  default     = "5.0.10"
}

variable "kms_protection_level" {
  description = "The KMS protection level (SOFTWARE or HSM)"
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.kms_protection_level)
    error_message = "KMS protection level must be either SOFTWARE or HSM"
  }
}

variable "mongodb_uri" {
  description = "The MongoDB URI"
  type        = string
}
variable "mongodb_db" {
  description = "The MongoDB database name"
  type        = string
}
variable "mongodb_user" {
  description = "The MongoDB username"
  type        = string
}
variable "mongodb_password" {
  description = "The MongoDB password"
  type        = string
  sensitive   = true
}

variable "log_level" {
  description = "The log level (trace, debug, info, warn, error, fatal)"
  type        = string
  default     = "info"

  validation {
    condition = contains(["trace", "debug", "info", "warn", "error", "fatal"], var.log_level)

    error_message = "Invalid log level"
  }
}

variable "parcel_retention_days" {
  description = "The number of days to retain parcels in GCS"
  default     = 90
}

// ===== PoHTTP =====

variable "pohttp_server_domain" {
  description = "Domain name for the PoHTTP server"
}
variable "pohttp_server_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the PoHTTP server)"
  type        = number
  default     = 80
}
variable "pohttp_server_min_instance_count" {
  description = "The minimum number of instances (for the PoHTTP server)"
  type        = number
  default     = 1
}
variable "pohttp_server_max_instance_count" {
  description = "The maximum number of instances (for the PoHTTP server)"
  type        = number
  default     = 3
}

// ===== PoWeb =====

variable "poweb_server_domain" {
  description = "Domain name for the PoWeb server"
}
variable "poweb_server_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the PoWeb server)"
  type        = number
  default     = 80
}
variable "poweb_server_min_instance_count" {
  description = "The minimum number of instances (for the PoWeb server)"
  type        = number
  default     = 1
}
variable "poweb_server_max_instance_count" {
  description = "The maximum number of instances (for the PoWeb server)"
  type        = number
  default     = 3
}

// ===== CogRPC =====

variable "cogrpc_server_domain" {
  description = "Domain name for the CogRPC server"
}
variable "cogrpc_server_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the CogRPC server)"
  type        = number
  default     = 80
}
variable "cogrpc_server_min_instance_count" {
  description = "The minimum number of instances (for the CogRPC server)"
  type        = number
  default     = 1
}
variable "cogrpc_server_max_instance_count" {
  description = "The maximum number of instances (for the CogRPC server)"
  type        = number
  default     = 3
}

// ===== Background queue =====

variable "queue_server_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the background queue)"
  type        = number
  default     = 80
}
variable "queue_server_min_instance_count" {
  description = "The minimum number of instances (for the background queue)"
  type        = number
  default     = 1
}
variable "queue_server_max_instance_count" {
  description = "The maximum number of instances (for the background queue)"
  type        = number
  default     = 3
}
