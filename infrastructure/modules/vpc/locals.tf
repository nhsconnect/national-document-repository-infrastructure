locals {
  offset                    = contains(["ndrd"], terraform.workspace) ? 10 : contains(["ndrc"], terraform.workspace) ? 20 : contains(["ndrb"], terraform.workspace) ? 30 : contains(["ndra"], terraform.workspace) ? 40 : 10
  public_subnet_cidrs       = [for i in range(1, var.num_public_subnets + 1) : "10.0.${(i + local.offset)}.0/24"]
  private_subnet_cidrs      = [for i in range(1, var.num_private_subnets + 1) : "10.0.1${(i + local.offset)}.0/24"]
  public_subnet_cidrs_prod  = [for i in range(1, var.num_public_subnets + 1) : "10.0.${i}.0/24"]
  private_subnet_cidrs_prod = [for i in range(1, var.num_private_subnets + 1) : "10.0.10${i}.0/24"]
  is_production             = contains(["pre-prod", "prod"], terraform.workspace)
}
