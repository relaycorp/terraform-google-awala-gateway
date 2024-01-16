resource "google_service_account" "bootstrap" {
  project = var.project_id

  account_id   = "gateway-${var.instance_name}-bootstrap"
  display_name = "Awala Internet Gateway (Bootstrap, ${var.instance_name})"
}

resource "google_cloud_run_v2_job" "bootstrap" {
  name     = "gateway-${var.instance_name}-bootstrap"
  location = var.region

  template {
    task_count = 1

    template {

      timeout = "300s"

      service_account = google_service_account.bootstrap.email

      execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

      max_retries = 1

      containers {
        name  = "bootstrap"
        image = "${var.docker_image_name}:${var.docker_image_tag}"

        args = ["build/main/bin/generate-keypairs.js"]

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
          name  = "LOG_LEVEL"
          value = var.log_level
        }
        env {
          name  = "LOG_TARGET"
          value = "gcp"
        }

        resources {
          limits = {
            cpu    = 1
            memory = "512Mi"
          }
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_for_id_key_creation,
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
    google_project_iam_binding.keystore_kms_user,
  ]
  lifecycle {
    ignore_changes = [launch_stage]
  }
}

resource "google_cloud_run_v2_job_iam_binding" "endpoint_bootstrap_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_job.bootstrap.name
  role     = "roles/run.invoker"
  members  = [var.sre_iam_uri]
}
