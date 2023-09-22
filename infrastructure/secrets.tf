module "jwt_signing_key_private" {
  source      = "./modules/secrets_manager"
  description = "Private key for signing JWT in auth lambdas"
  name        = "jwt_signing_key"
  environment = var.environment
  owner       = var.owner
}

module "jwt_signing_key_public" {
  source      = "./modules/secrets_manager"
  description = "Public key for decoding JWT in auth lambdas"
  name        = "jwt_signing_key_pub"
  environment = var.environment
  owner       = var.owner
}