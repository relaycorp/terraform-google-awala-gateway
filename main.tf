terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.82.0, < 6.0.0"
    }
  }
}

resource "random_id" "unique_suffix" {
  byte_length = 3
}
