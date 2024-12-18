# ovia-terraform-workspace
Just practicing...

#################################################
What are workspaces?
Workspaces allow us to separate our state and infrastructure without changing anything in our code 
when we want the same code base to deploy to multiple environments.
With workspaces, we can create different state files for each environment using the same set of 
configuration files/ code.

To create a variables.tf file for your Terraform code that supports different workspaces (default, dev, and test), you'll need to define variables that allow you to customize the configuration for each workspace. Specifically, you'll want to define a variable for instance_type that differs based on the workspace, and possibly other variables like ami_id and subnet_id.

Here’s an example variables.tf for your use case:

variables.tf

# Variable for AMI ID
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

# Variable for Instance Type
variable "instance_type" {
  description = "The type of EC2 instance"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.medium"
    test    = "t2.small"
  }
}

# Variable for Subnet ID
variable "subnet_id" {
  description = "The subnet ID to launch the EC2 instance in"
  type        = string
}
Explanation:
AMI ID: The ami_id variable is defined as a simple string, and you can provide its value based on your environment, either in terraform.tfvars or using -var when applying the configuration.

Instance Type: The instance_type variable is defined as a map (map(string)). This map contains values for default, dev, and test workspaces. You can adjust the instance types based on the workspace used.

Subnet ID: The subnet_id is a string variable to hold the subnet ID where the instance will be launched. You can set this value similarly to ami_id.

Example terraform.tfvars
You may also need to specify the actual values for ami_id and subnet_id. This is done in the terraform.tfvars or environment-specific .tfvars files.


# terraform.tfvars
ami_id = "ami-0123456789abcdef0"  # Replace with your AMI ID
subnet_id = "subnet-0123456789abcdef0"  # Replace with your subnet ID
Workspace-Specific Customization
In your aws_instance resource, you're already using the lookup function to select the appropriate instance_type based on the workspace:


resource "aws_instance" "ovia-instance" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, terraform.workspace)
  subnet_id     = var.subnet_id
}
This will automatically select the correct instance_type based on the workspace you're working in (e.g., t2.micro for the default workspace, t2.medium for dev, and t2.small for test).

How Workspaces Work
You can create and switch between workspaces using the following Terraform CLI commands:

List all workspaces:


terraform workspace list
Create a new workspace:


terraform workspace new dev
Switch to a workspace:


terraform workspace select dev
Conclusion
With the above configuration, when you switch between workspaces (default, dev, or test), Terraform will use the corresponding instance_type value for each workspace. You can easily extend this to other variables as needed for your environment.

To create environment-specific .tfvars files for the default, dev, and test workspaces, you will define a separate .tfvars file for each environment. These files will override the default values of your variables and provide workspace-specific settings.

Here are the three .tfvars files:

1. default.tfvars
This file contains the configuration for the default workspace. The values in this file will be used when the default workspace is selected.


# default.tfvars

ami_id = "ami-0123456789abcdef0"  # Replace with your default AMI ID
subnet_id = "subnet-abcdef01"  # Replace with your default subnet ID
instance_type = "t2.micro"  # Default instance type for the 'default' workspace
2. dev.tfvars
This file contains the configuration for the dev workspace. The values in this file will be used when the dev workspace is selected.


# dev.tfvars

ami_id = "ami-0987654321abcdef0"  # Replace with your dev AMI ID
subnet_id = "subnet-abcdef02"  # Replace with your dev subnet ID
instance_type = "t2.medium"  # Instance type for the 'dev' workspace
3. test.tfvars
This file contains the configuration for the test workspace. The values in this file will be used when the test workspace is selected.


# test.tfvars

ami_id = "ami-abcdef0123456789"  # Replace with your test AMI ID
subnet_id = "subnet-abcdef03"  # Replace with your test subnet ID
instance_type = "t2.small"  # Instance type for the 'test' workspace
Usage of the .tfvars Files
Select a workspace: First, you need to select the workspace where you want to apply the configuration. For example, to use the dev workspace, you would run:


terraform workspace select dev
Apply the configuration: Once you've selected the workspace, apply the Terraform configuration, and it will automatically use the corresponding .tfvars file. Terraform looks for .tfvars files based on the workspace you're in, but you can also explicitly specify a .tfvars file using the -var-file flag if needed.

For example, for the dev workspace:


terraform apply -var-file=dev.tfvars
Or if you're already in the dev workspace, Terraform will automatically use the dev.tfvars file without needing to specify it manually.

Switch workspaces: Similarly, when switching to test or default, the appropriate .tfvars file will be used.

To switch to the test workspace:


terraform workspace select test
terraform apply -var-file=test.tfvars
Notes:
Ensure that the AMI IDs and subnet IDs in the .tfvars files correspond to the actual resources in your AWS environment for each workspace.
The instance_type variable is defined in the variables.tf file as a map, and the lookup function in your Terraform code will automatically pick the correct instance type based on the workspace. The values in the .tfvars files will override the default settings if needed.

#####################################################

In a typical Terraform project, there are specific files and directories that should not be committed to your GitHub repository. These files contain sensitive information, state data, or are generated automatically by Terraform, and including them in version control can lead to security risks, unexpected behavior, or unnecessary bloat in your repository.

Here’s a breakdown of which files should not be committed and should be included in your .gitignore file:

1. State Files and State Lock Files
terraform.tfstate: This file contains the current state of your infrastructure and may contain sensitive data (such as passwords, keys, etc.). It should not be committed to the repository.
terraform.tfstate.d/: This directory contains state-related files, typically when using remote backends. These files should also not be committed.
.terraform.lock.hcl: This is the lock file used by Terraform to ensure consistent versions of providers are used. While it’s generally safe to commit this for consistency, some teams prefer to add it to .gitignore to prevent accidental commits.
.terraform.tfstate.lock.info: This is a lock file that is used to manage concurrent operations on the state file. It should not be committed.
2. Local Terraform Directories
.terraform/: This directory contains local caches, plugins, and other internal Terraform-related files. It should not be committed because it’s generated automatically by Terraform during execution.
3. Other Files
*.tfvars files (e.g., default.tfvars, dev.tfvars, test.tfvars): These files can contain sensitive data or environment-specific configuration values. Whether they should be committed depends on your use case, but it's generally safer not to commit them unless the values they contain are non-sensitive (such as non-sensitive configuration options). If the .tfvars files contain sensitive data (like subnet_id, ami_id, etc.), they should be added to .gitignore. Consider using environment variables or secret management tools for sensitive data.
Recommended .gitignore File
Here’s a typical .gitignore file for a Terraform project:


# Local Terraform files
.terraform/
terraform.tfstate
terraform.tfstate.d/
.terraform.lock.hcl
terraform.tfstate.lock.info

# Terraform variables files that may contain sensitive data
*.tfvars

# Editor directories and files (e.g., Visual Studio Code, etc.)
.vscode/
.idea/

# OS-specific files (e.g., macOS, Windows)
.DS_Store
Thumbs.db
Explanation:
.terraform/: Excludes the directory where Terraform stores local plugins, module caches, and other internal files.
terraform.tfstate and .terraform.tfstate.d/: Prevents committing your state files, which contain sensitive information about your infrastructure.
terraform.tfstate.lock.info: Excludes the state lock file.
*.tfvars: Excludes .tfvars files, which may contain sensitive information like API keys, credentials, or instance configurations.
What Should Be Committed?
You should commit the following to GitHub:

*.tf files: Your Terraform configuration files (e.g., ec2.tf, variables.tf, provider.tf) should be committed as they define the desired state of your infrastructure.
README.md or other documentation: Any project documentation that explains your Terraform configurations.
default.tfvars (if it’s safe): If default.tfvars contains default non-sensitive values, you may choose to commit it, but avoid committing environment-specific values like those in dev.tfvars or test.tfvars if they contain sensitive data.
By adding the files mentioned above to .gitignore, you ensure that sensitive and automatically generated files do not end up in your version control system.





