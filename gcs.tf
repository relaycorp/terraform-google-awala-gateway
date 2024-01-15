resource "random_id" "parcels" {
  byte_length = 3
}

resource "google_storage_bucket" "parcels" {
  name          = "gateway-${var.instance_name}-parcels-${random_id.parcels.hex}"
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

resource "google_storage_bucket_iam_binding" "parcels" {
  bucket = google_storage_bucket.parcels.name
  role   = "roles/storage.objectUser"
  members = [
    "serviceAccount:${google_service_account.pohttp.email}",
    "serviceAccount:${google_service_account.poweb.email}",
    "serviceAccount:${google_service_account.queue.email}",
  ]
}
