module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "10.0.0"

  project = var.project_id

  name = "gateway-${var.instance_name}"

  ssl                       = true
  ssl_policy                = google_compute_ssl_policy.main.id
  random_certificate_suffix = true # In case the domain changes
  managed_ssl_certificate_domains = [
    var.pohttp_server_domain,
    var.poweb_server_domain,
    var.cogrpc_server_domain,
  ]

  create_url_map = false
  url_map        = google_compute_url_map.main.self_link

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

    poweb = {
      description = "PoWeb"
      groups = [
        {
          group = google_compute_region_network_endpoint_group.poweb.id
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

resource "google_compute_url_map" "main" {
  name            = "gateway-${var.instance_name}"
  default_service = module.load_balancer.backend_services["pohttp"].self_link

  host_rule {
    hosts        = [var.pohttp_server_domain]
    path_matcher = "pohttp"
  }
  path_matcher {
    name            = "pohttp"
    default_service = module.load_balancer.backend_services["pohttp"].self_link
  }

  host_rule {
    hosts        = [var.poweb_server_domain]
    path_matcher = "poweb"
  }
  path_matcher {
    name            = "poweb"
    default_service = module.load_balancer.backend_services["poweb"].self_link
  }
}

resource "google_compute_ssl_policy" "main" {
  name            = "gateway-${var.instance_name}"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}
