resource "google_cloud_run_v2_service" "pohttp" {
  name     = "gateway-${var.instance_name}-pohttp"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  launch_stage = "BETA"

  template {
    timeout = "5s"

    service_account = google_service_account.main.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = var.pohttp_server_max_instance_request_concurrency

    containers {
      name  = "pohttp"
      image = "${var.docker_image_name}:${var.docker_image_tag}"

      args = ["build/main/bin/pohttp-server.js"]

      env {
        name  = "PUBLIC_ADDRESS"
        value = var.internet_address
      }

      env {
        name  = "GATEWAY_VERSION"
        value = var.docker_image_tag
      }

      env {
        name  = "MONGODB_URI"
        value = var.mongodb_uri
      }
      env {
        name  = "MONGODB_DB"
        value = var.mongodb_db
      }
      env {
        name  = "MONGODB_USER"
        value = var.mongodb_user
      }
      env {
        name = "MONGODB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.mongodb_password.id
            version = "latest"
          }
        }
      }

      env {
        name  = "PRIVATE_KEY_STORE_ADAPTER"
        value = "0"
      }

      // @relaycorp/awala-keystore-cloud options
      env {
        name  = "KEYSTORE_ADAPTER"
        value = "gcp"
      }
      env {
        name  = "KS_GCP_LOCATION"
        value = var.region
      }
      env {
        name  = "KS_KMS_KEYRING"
        value = google_kms_key_ring.keystores.name
      }
      env {
        name  = "KS_KMS_ID_KEY"
        value = google_kms_crypto_key.identity_key.name
      }
      env {
        name  = "KS_KMS_SESSION_ENC_KEY"
        value = google_kms_crypto_key.session_keys.name
      }

      // @relaycorp/webcrypto-kms options
      env {
        name  = "GCP_KMS_LOCATION"
        value = var.region
      }
      env {
        name  = "GCP_KMS_KEYRING"
        value = google_kms_key_ring.keystores.name
      }
      env {
        name  = "GCP_KMS_PROTECTION_LEVEL"
        value = var.kms_protection_level
      }

      env {
        name  = "OBJECT_STORE_BACKEND"
        value = "gcs"
      }
      env {
        name  = "OBJECT_STORE_BUCKET"
        value = google_storage_bucket.gateway_messages.name
      }

      env {
        name  = "REDIS_URL"
        value = "redis://${google_redis_instance.main.host}:${google_redis_instance.main.port}"
      }

      env {
        name  = "LOG_LEVEL"
        value = var.log_level
      }
      env {
        name  = "LOG_TARGET"
        value = "gcp"
      }

      env {
        name  = "REQUEST_ID_HEADER"
        value = "X-Cloud-Trace-Context"
      }

      resources {
        startup_cpu_boost = true
        cpu_idle          = false

        limits = {
          cpu    = 1
          memory = "512Mi"
        }
      }

      startup_probe {
        initial_delay_seconds = 3
        failure_threshold     = 3
        period_seconds        = 10
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        failure_threshold     = 3
        period_seconds        = 20
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }
    }

    scaling {
      min_instance_count = var.pohttp_server_min_instance_count
      max_instance_count = var.pohttp_server_max_instance_count
    }

    vpc_access {
      network_interfaces {
        network = google_compute_network.main.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
  }

  depends_on = [
    time_sleep.wait_for_id_key_creation,
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
  ]
}

resource "google_cloud_run_service_iam_member" "pohttp_public_access" {
  location = google_cloud_run_v2_service.pohttp.location
  project  = google_cloud_run_v2_service.pohttp.project
  service  = google_cloud_run_v2_service.pohttp.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "pohttp" {
  project = var.project_id
  region  = var.region

  name = "gateway-${var.instance_name}"

  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.pohttp.name
  }
}
