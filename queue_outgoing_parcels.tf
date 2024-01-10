resource "google_pubsub_topic" "outgoing_parcels" {
  project = var.project_id

  name = "gateway.${var.instance_name}.outgoing_parcels"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_topic_iam_binding" "outgoing_parcels_publisher" {
  project = var.project_id

  topic   = google_pubsub_topic.outgoing_parcels.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_service_account.poweb.email}"]
}
