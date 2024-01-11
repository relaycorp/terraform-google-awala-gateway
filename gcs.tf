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
      age = var.parcel_retention_days
    }
    action {
      type = "Delete"
    }
  }

  force_destroy = !var.prevent_destruction
}

resource "google_storage_bucket_iam_binding" "gateway_messages" {
  bucket = google_storage_bucket.gateway_messages.name
  role   = "roles/storage.objectUser"
  members = [
    "serviceAccount:${google_service_account.pohttp.email}",
    "serviceAccount:${google_service_account.poweb.email}",
    "serviceAccount:${google_service_account.queue.email}",
  ]
}
