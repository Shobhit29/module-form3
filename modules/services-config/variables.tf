  variable "credential" {
    type = map(object({
      db_password = string
      db_password_policy = string
      image = string
    }))
   default = ({
   gateway = {
    db_password = "10350819-4802-47ac-9476-6fa781e35cfd"
    db_password_policy = "123-gateway-development"
    image= "form3tech-oss/platformtest-gateway"
   },
   payment = {
    db_password = "a63e8938-6d49-49ea-905d-e03a683059e7"
    db_password_policy = "123-gateway-development"
    image = "form3tech-oss/platformtest-payment"
   },
   account = {
    db_password = "965d3c27-9e20-4d41-91c9-61e6631870e7"
    db_password_policy = "123-account-development"
    image = "form3tech-oss/platformtest-account"     
   }
  })
}

variable "vault_docker_address" {
    type = string
    default= "http://vault-development:8200"
}  

variable "vault_address" {
  type      = string
  default= "http://localhost:8201"
}
variable "vault_token" {
  type      = string
  sensitive = true
  default= "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
}

variable "services" {
    type = list(string)
    default = ["account","payment","gateway"]
}
variable "environment" {
    type = string
    default = "development"
}