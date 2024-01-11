locals {
  gateway_db_name = "awala-gateway"
}

module "gateway" {
  source = "../.."

  instance_name    = "test"
  internet_address = var.internet_address

  project_id = var.google_project_id
  region     = var.google_region

  pohttp_server_domain = var.pohttp_server_domain
  poweb_server_domain  = var.poweb_server_domain
  cogrpc_server_domain = var.cogrpc_server_domain

  mongodb_db       = local.gateway_db_name
  mongodb_password = random_password.mongodb_gateway_user_password.result
  mongodb_uri      = local.mongodb_uri
  mongodb_user     = mongodbatlas_database_user.gateway.username

  depends_on = [time_sleep.wait_for_services]
}

resource "mongodbatlas_database_user" "gateway" {
  project_id = var.mongodbatlas_project_id

  username           = "awala-gateway"
  password           = random_password.mongodb_gateway_user_password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = local.gateway_db_name
  }
}

resource "random_password" "mongodb_gateway_user_password" {
  length = 32
}
