# terraform-aws-web-server
Terraform AWS Infrastructure Deployment

Deploys a basic AWS infrastructure for hosting a web server using Terraform, including a VPC, public subnet, EC2 instance with Apache, and Elastic IP in us-east-2.

Infrastructure
- VPC: CIDR 10.0.0.0/16, public subnet 10.0.1.0/24 in us-east-2a.
- Internet Gateway & Route Table: Enables internet access.
- Security Group: Allows HTTP (80), HTTPS (443), SSH (22) from 0.0.0.0/0.
- EC2 Instance: t2.micro Ubuntu with Apache2, serving a "Hello World" page.
- Elastic IP: Static public IP for the EC2 instance.

Setup
1.  Secure AWS credentials: Replace hardcoded access_key and secret_key in main.tf with environment variables
2.  Initialize Terraform: terraform init
3.  Deploy: terraform apply

Usage
1. Access the web server at http://<public-ip> (output by Terraform)
2. SSH into the instance: ssh -i /path/to/main-key.pem ubuntu@<public-ip>
3. Destroy resources: terraform destroy

Security Notes
- Avoid hardcoded credentials in main.tf.
- Restrict SSH access to your IP (replace 0.0.0.0/0 with YOUR_IP/32).
