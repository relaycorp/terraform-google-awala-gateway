resource "google_service_account" "cogrpc" {
  project = var.project_id

  account_id   = "gateway-${var.instance_name}-cogrpc"
  display_name = "Awala Internet Gateway (CogRPC, ${var.instance_name})"
}

resource "google_cloud_run_v2_service" "cogrpc" {
  name     = "gateway-${var.instance_name}-cogrpc"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    timeout = "5s"

    service_account = google_service_account.cogrpc.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = var.cogrpc_server_max_instance_request_concurrency

    containers {
      name  = "cogrpc"
      image = "${var.docker_image_name}:${var.docker_image_tag}"

      args = ["build/main/bin/cogrpc-server.js"]

      env {
        name  = "INTERNET_ADDRESS"
        value = local.sanitised_internet_address
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

      env {
        name  = "OBJECT_STORE_BACKEND"
        value = "gcs"
      }
      env {
        name  = "OBJECT_STORE_BUCKET"
        value = google_storage_bucket.parcels.name
      }

      env {
        name  = "CE_TRANSPORT"
        value = "google-pubsub"
      }
      env {
        name  = "CE_CHANNEL"
        value = google_pubsub_topic.queue.name
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
        grpc {
          service = "relaynet.cogrpc.CargoRelay"
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        failure_threshold     = 3
        period_seconds        = 20
        timeout_seconds       = 3
        grpc {
          service = "relaynet.cogrpc.CargoRelay"
        }
      }
    }

    scaling {
      min_instance_count = var.cogrpc_server_min_instance_count
      max_instance_count = var.cogrpc_server_max_instance_count
    }
  }

  depends_on = [
    time_sleep.wait_for_id_key_creation,
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
    google_project_iam_binding.keystore_kms_user,
  ]
}

resource "google_cloud_run_service_iam_member" "cogrpc_public_access" {
  location = google_cloud_run_v2_service.cogrpc.location
  project  = google_cloud_run_v2_service.cogrpc.project
  service  = google_cloud_run_v2_service.cogrpc.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "cogrpc" {
  project = var.project_id
  region  = var.region

  name = "gateway-${var.instance_name}-cogrpc"

  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.cogrpc.name
  }
}
