resource "google_service_account" "main" {
  project = var.project_id

  account_id   = "gateway-${var.instance_name}"
  display_name = "Awala Internet Gateway (${var.instance_name})"
}
