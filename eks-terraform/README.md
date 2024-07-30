## Terraform Setup for an EKS Cluster.

The terraform files under `eks-terraform/` folder and automate the creation of the EKS cluster needed to run helm commands under the helm section..

The `eks-terraform` folder contains the following files;

|File                           | Description                                                                                     |
|-------------------------------|-------------------------------------------------------------------------------------------------|
|`backend.tf`                   | Specifies the backend storage bucket where the terraform state is remotely stored               |
|`sample.terraform.tfvars`      | Holds assigned values for the `variables.tf` staging env                                        |
|`main.tf`                      | Defines modules and resources for the infrastructure to be created in Google Cloud.             |
|`outputs.tf`                   | Return values that will be displayed after terraform runs successfully.                         |
|`variables.tf`                 | Defines valid variables for the templates which serve as parameters for the modules / resources.|
|`provider.tf`                  | Specifies terraform provider versions.                                                          |

### Prerequisites

- Terraform Version "~> 1.2.0"

- Setup `awscli`, `kubernetes-cli` and configure AWS CLI with `aws configure`

- Iam user with created `access` and `secret` keys

#### Terraform Configuration instructions

Create a dynamo table called `terraform-lock` with a `LockID` partition of type String
```
aws dynamodb create-table \
         --region ap-south-1 \
         --table-name terraform-lock \
         --attribute-definitions AttributeName=LockID,AttributeType=S \
         --key-schema AttributeName=LockID,KeyType=HASH \
         --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 
```

cd to `eks-terraform` folder

Create a `terraform.tfvars` file and add kv from the `sample.terraform.tfvars`

Run `terraform init -reconfigure` to initialise the terraform backend configuration

Run `terraform validate` to validate the terraform files. The response should be `Success! The configuration is valid.`

Run `terraform plan -out terraform.plan` to see the EKS cluster infrastructure resources that will be created.

Run `terraform apply terraform.plan` to create the resources

Save and take note of the output among which will is `cluster_name` to be used in the next command.

Enable connecting with kubectl to your cluster by running `aws eks --region us-east-2 update-kubeconfig --name cluster_name`
