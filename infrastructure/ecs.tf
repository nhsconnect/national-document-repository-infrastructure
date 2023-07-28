module "ndr-ecs-fargate" {
  source                   = "./modules/ecs"
  ecs_cluster_name         = "${terraform.workspace}-ecs-cluster"
  vpc_id                   = module.ndr-vpc-ui.vpc_id
  public_subnets           = module.ndr-vpc-ui.public_subnets
  sg_name                  = "${terraform.workspace}-fargate-sg"
  ecs_launch_type          = "FARGATE"
  ecs_cluster_service_name = "${terraform.workspace}-ecs-cluster-service"

  environment = var.environment
  owner       = var.owner
}
