# terraform-aws-web-server
Terraform AWS Infrastructure Deployment

Deploys a basic AWS infrastructure for hosting a web server using Terraform, including a VPC, public subnet, EC2 instance with Apache, and Elastic IP in us-east-2.

Infrastructure
- VPC: CIDR 10.0.0.0/16, public subnet 10.0.1.0/24 in us-east-2a.
- Internet Gateway & Route Table: Enables internet access.
- Security Group: Allows HTTP (80), HTTPS (443), SSH (22) from 0.0.0.0/0.
- EC2 Instance: t2.micro Ubuntu with Apache2, serving a "Hello World" page.
- Elastic IP: Static public IP for the EC2 instance.

