resource "google_compute_network" "main" {
  name = "gateway-${var.instance_name}"
}
