Terraform v1.6.0
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v4.67.0
+ provider registry.terraform.io/hashicorp/local v2.5.2
+ provider registry.terraform.io/hashicorp/tls v4.0.6



# Commands
terraform init
terraform init -upgrade
terraform fmt && terraform validate
terraform plan -out=tfplanv2 
terraform show -no-color tfplanv2 > tfplanv2.txt 2>&1
terraform apply "tfplanv2" > tfplanv2_apply.txt 2>&1

terraform plan -destroy -out=tfdestroy
terraform show tfdestroy > tfplanv2_destroy.txt 2>&1
terraform apply -destroy > tfplanv2_apply_destroy.txt 2>&1



terraform state list