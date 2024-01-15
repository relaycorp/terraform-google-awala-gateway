variable "sre_iam_uri" {}

variable "google_project_id" {
  description = "Google project id"
}
variable "google_credentials_path" {
  description = "Path to Google credentials file"
}
variable "google_region" {
  description = "Google region"
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas public key"
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas private key"
  sensitive   = true
}
variable "mongodbatlas_project_id" {}

variable "internet_address" {
  description = "The Awala Internet address (domain name) of the gateway"
}
variable "pohttp_server_domain" {
  description = "The domain name for the PoHTTP server in the Awala Internet Gateway"
}
variable "poweb_server_domain" {
  description = "The domain name for the PoWeb server in the Awala Internet Gateway"
}
variable "cogrpc_server_domain" {
  description = "The domain name for the CogRPC server in the Awala Internet Gateway"
}
