resource "random_id" "gateway_messages_bucket_suffix" {
  byte_length = 3
}

resource "google_storage_bucket" "gateway_messages" {
  name          = "gateway-${var.instance_name}-messages-${random_id.gateway_messages_bucket_suffix.hex}"
  storage_class = "REGIONAL"
  location      = upper(var.region)

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 2 // https://github.com/relaycorp/cloud-gateway/issues/64
    }
    action {
      type = "Delete"
    }
  }

  force_destroy = !var.prevent_destruction
}
