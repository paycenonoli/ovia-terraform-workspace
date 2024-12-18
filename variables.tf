variable "ami_id" {
    description = "The AMI to use for the EC2 instance"
    type = string
}

variable "instance_type" {
    description = "The type of EC2 instance"
    type = map(any)
    default = {
        default = "t2.nano"
        dev = "t2.micro"
        test = "t2.small"
    }
}

