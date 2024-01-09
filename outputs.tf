output "bootstrap_job_name" {
  value = google_cloud_run_v2_job.bootstrap.name
}

output "load_balancer_ip_address" {
  value = module.load_balancer.external_ip
}
