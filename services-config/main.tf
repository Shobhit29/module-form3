terraform {
  required_version = ">= 1.0.7"
  required_providers {
    vault = {
      version = "3.0.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

resource "vault_audit" "audit" {
  type     = "file"

  options = {
    file_path = "/vault/logs/audit"
  }
}


resource "vault_auth_backend" "auth_method" {
  type     = "userpass"
}

resource "vault_generic_secret" "generic_secret" {
  
  for_each = var.credential
  path = "secret/${var.environment}/${each.key}"

  data_json = jsonencode({
  "db_user": each.value.db_password
  "db_password": each.value.db_password
})
}

resource "vault_generic_endpoint" "generic_endpoint" {
   
  for_each = var.credential
  provider             = vault
  depends_on           = [vault_auth_backend.auth_method]
  path                 = "auth/userpass/users/${each.key}-${var.environment}"
  ignore_absent_fields = true

  data_json = jsonencode({
  "policies": ["${each.key}-${var.environment}"],
  "password": each.value.db_password_policy
})
}
resource "vault_policy" "policy" {
  provider = vault
  for_each = var.credential
  name     = "${each.key}-${var.environment}"

  policy = <<EOT

path "secret/data/${var.environment}/${each.key}" {
    capabilities = ["list", "read"]
}

EOT
}

resource "docker_container" "application" {

  for_each = var.credential
  image = "${each.value.image}"
  name  = "${each.key}_${var.environment}"

  env = [
    "VAULT_ADDR=${var.vault_docker_address}",
    "VAULT_USERNAME=${each.key}-${var.environment}",
    "VAULT_PASSWORD=${each.value.db_password_policy}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = "vagrant_${var.environment}"
  }

  lifecycle {
    ignore_changes = all
  }
}
