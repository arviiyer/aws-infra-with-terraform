# Terraform AWS Infrastructure Setup

This project contains Terraform scripts to provision a secure and scalable AWS infrastructure. The setup includes a Virtual Private Cloud (VPC) with public and private subnets, an Application Load Balancer (ALB), EC2 instances, a bastion host, and NAT gateways. The infrastructure is designed to be robust, following AWS best practices.

## Architecture Overview

![Architecture Diagram](arviiyer/aws-infra-with-terraform/blob/main/terraform-aws-infra.png)

The diagram above illustrates the high-level architecture of the infrastructure:

- **VPC**: A Virtual Private Cloud with public and private subnets across multiple availability zones.
- **Public Subnets**: Subnets that house the bastion host and Application Load Balancer.
- **Private Subnets**: Subnets for EC2 instances running a simple web server.
- **Bastion Host**: An EC2 instance in a public subnet used to securely access instances in private subnets.
- **NAT Gateways**: Allow instances in private subnets to access the internet while remaining private.
- **Application Load Balancer**: Distributes traffic across EC2 instances in private subnets.
- **Security Groups**: Restrict access to the instances, allowing only necessary traffic.

## Prerequisites

Before you begin, ensure you have the following:

- **AWS Account**: You need an AWS account with the appropriate permissions to create and manage resources.
- **Terraform**: Install Terraform (v1.0 or later).
- **AWS CLI**: Install the AWS CLI and configure it with your AWS credentials.
- **SSH Key Pair**: A key pair to access the EC2 instances. If you don't have one, you can generate it using `ssh-keygen`.

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/terraform-aws-infra.git
   cd terraform-aws-infra
   ```

2. **Configure Terraform Backend (Optional)**

   If you want to use a remote backend for storing your Terraform state, configure the `backend` block in `main.tf`.

3. **Initialize Terraform**

   Initialize the Terraform project, which will download the required providers and set up the environment.

   ```bash
   terraform init
   ```

4. **Review and Apply the Configuration**

   - Review the configuration by running:

     ```bash
     terraform plan
     ```

   - Apply the configuration to create the infrastructure:

     ```bash
     terraform apply
     ```

   - Confirm the action when prompted.

5. **Outputs**

   After deployment, Terraform will output the public IP of the bastion host and the private IPs of the EC2 instances.

   ```bash
   terraform output
   ```

## Accessing the Infrastructure

### SSH into the Bastion Host

To access the private EC2 instances, first SSH into the bastion host:

```bash
ssh -A -i ~/.ssh/id_rsa ec2-user@<Bastion_Host_Public_IP>
```

![Bastion Host SSH Screenshot](path/to/your/bastion-ssh-screenshot.png)

### SSH into Private Instances

From the bastion host, you can SSH into the private instances:

```bash
ssh ec2-user@<Private_Instance_IP>
```

![Private Instance SSH Screenshot](path/to/your/private-instance-ssh-screenshot.png)

### Testing the Web Server

The private EC2 instances run a simple web server that returns "Hello World" followed by the instance ID. You can access the web server through the Application Load Balancer:

- **ALB DNS Name**: Get the ALB DNS name from the AWS console or output after applying the Terraform script.
- Open the DNS name in your browser to see the "Hello World" message.

![ALB Web Server Screenshot](path/to/your/alb-web-server-screenshot.png)

## Costs and Cleanup

**Warning**: Running AWS resources incurs costs. To avoid unnecessary charges, destroy the infrastructure when not in use:

```bash
terraform destroy
```

This command will remove all resources created by Terraform.

## Estimated Costs

### Disclaimer

Deploying this infrastructure on AWS may incur costs depending on the resources provisioned and the duration they are active. Below is an estimate of the potential costs:

- **EC2 Instances (4 t2.micro instances)**:
  - Estimated Cost: ~$0.0116 per hour per instance (on-demand pricing)
  - Total for 4 instances: ~$0.0464 per hour
- **Application Load Balancer**:
  - Estimated Cost: ~$0.0225 per hour plus data transfer costs
- **NAT Gateways (3 NAT Gateways)**:
  - Estimated Cost: ~$0.045 per hour per NAT Gateway
  - Total for 3 NAT Gateways: ~$0.135 per hour
- **Elastic IPs**:
  - Free while attached to running instances; ~$0.005 per hour if unattached.

### Total Estimated Cost Per Hour:
- **Rough Estimate**: ~$0.204 per hour

### Additional Notes:
- **Free Tier**: If your account is eligible for the AWS Free Tier, some of these costs may be covered. For example, t2.micro instances might be free for up to 750 hours per month.
- **Data Transfer**: Data transfer costs can add up, especially if the infrastructure handles significant traffic.

**Important**: These estimates are subject to change based on AWS pricing updates, region-specific costs, and actual usage. Always check the latest pricing on the [AWS Pricing Calculator](https://calculator.aws/#/) or the [AWS Pricing page](https://aws.amazon.com/pricing/).

## Potential Enhancements

- **Monitoring**: Integrate CloudWatch for monitoring and alarms.
- **Auto Scaling**: Implement auto-scaling for the EC2 instances.
- **Database Layer**: Add an RDS instance for a database backend.
- **CI/CD Integration**: Set up GitHub Actions or Terraform Cloud for continuous deployment.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Terraform by HashiCorp
- AWS for providing robust cloud infrastructure services