resource "google_monitoring_notification_channel" "sres_email" {
  for_each = toset(var.alert_email_addresses)

  display_name = "Notify SREs (managed by Terraform workspace ${terraform.workspace})"
  type         = "email"

  labels = {
    email_address = each.value
  }
}
