resource "aws_instance" "ovia-instance" {
  ami = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)
}