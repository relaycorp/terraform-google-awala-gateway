resource "google_compute_global_address" "redis" {
  name          = "${var.instance_name}-redis"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "redis" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.redis.name]
}

resource "google_redis_instance" "main" {
  name           = var.instance_name
  display_name   = "Awala Gateway (${var.instance_name})"
  tier           = "BASIC"
  memory_size_gb = 1

  region = var.region

  authorized_network = google_compute_network.main.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version = "REDIS_6_X"

  persistence_config {
    persistence_mode = "DISABLED"
  }

  maintenance_policy {
    weekly_maintenance_window {
      day = "TUESDAY"
      start_time {
        hours = 10
      }
    }
  }

  depends_on = [google_service_networking_connection.redis]
}
