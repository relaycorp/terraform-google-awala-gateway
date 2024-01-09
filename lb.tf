module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "9.2.0"

  project = var.project_id

  name = "gateway-${var.instance_name}"

  ssl                             = true
  ssl_policy                      = google_compute_ssl_policy.main.id
  random_certificate_suffix       = true # In case the domain changes
  managed_ssl_certificate_domains = [var.pohttp_server_domain]

  backends = {
    pohttp = {
      description = "PoHTTP"
      groups = [
        {
          group = google_compute_region_network_endpoint_group.pohttp.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }

  http_forward = false
}

resource "google_compute_ssl_policy" "main" {
  name            = "gateway-${var.instance_name}"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}
