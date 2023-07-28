module "ndr-document-store" {
  source      = "./modules/s3/"
  bucket_name = "document-store"

  environment = var.environment
  owner       = var.owner
}