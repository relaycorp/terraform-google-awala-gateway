resource "google_project_iam_binding" "error_reporting_sre_access" {
  project = var.project_id
  role    = "roles/errorreporting.user"
  members = [var.sre_iam_uri]
}
