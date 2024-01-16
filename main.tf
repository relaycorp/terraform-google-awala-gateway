terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.11"
    }
  }
}

resource "random_id" "unique_suffix" {
  byte_length = 3
}

locals {
  sanitised_internet_address = replace(var.internet_address, "/\\.$/", "")
}
