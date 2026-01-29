# Assignment: Infrastructure

This project creates a scalable web application with load balancing using Infrastructure as Code principles. It demonstrates cloud-native deployment patterns with automated provisioning and configuration.


## Overview

- **Load Balancer (Nginx):**
    - Receives all web requests on port `8082`
    - Distributes requests to web servers using round-robin
    - Only server accessible from the internet

- **Web Servers (Apache):**
    - Private servers serving content on port `80`
    - Each displays its own hostname in the response
    - Only reachable via the load balancer

**Traffic Flow Example:**
```
Request 1: User → Load Balancer → webserver1 → "delivered by webserver1"
Request 2: User → Load Balancer → webserver2 → "delivered by webserver2"
Request 3: User → Load Balancer → webserver1 → "delivered by webserver1"
```

## Features

- Two webservers (Apache) with unique content
- One load balancer (Nginx) on port 8082 with round-robin
- Separation of private/public IPs
- No hardcoded credentials (uses environment variables)
- Automatic provisioning and teardown (`deploy.sh`)


## Architecture

```shell
Internet → Load Balancer (Port 8082) → Web Servers (Port 80)
           nginx (172.27.x.x)          ├── webserver1 (192.168.4.x)
                                       └── webserver2 (192.168.4.x)

```


## Prerequisites

- OpenStack account (CSCloud/Cumulus access)
- SSH key pair uploaded to OpenStack
- Tools installed:
    - **macOS:**  
        `brew install terraform ansible`


## Quick Start

1. **Environment Setup**

     Create a `.env` file with your credentials:
     ```sh
     # OpenStack credentials
     export OS_AUTH_URL="https://cumulus.lnu.se:5000/v3"
     export OS_USERNAME="your-username"
     export OS_PASSWORD="your-password"
     export OS_PROJECT_NAME="your-project"
     export OS_USER_DOMAIN_NAME="Default"
     export OS_PROJECT_DOMAIN_NAME="Default"
     export OS_REGION_NAME="RegionOne"

     # SSH credentials
     export TF_VAR_key_name="your-keypair-name"
     export TF_VAR_identity_file="~/.ssh/your-private-key.pem"
     ```

     Create a `terraform.auto.tfvars` file with your credentials:
     ```sh
     # Example values - customize as needed for your environment
     network_name        = "my-assignment1-network"
     subnet_cidr         = "192.168.1.0/24"
     router_name         = "my-assignment1-router"
     security_group_name = "my-assignment1-secgroup"
     ```

2. **Deployment**

     Navigate to project root and run:
     ```sh
     source .env
     ./deploy.sh
     ```

## How It Works

When you run `./deploy.sh`:

1. **Terraform** provisions OpenStack infrastructure
   - Creates network, subnets, and security groups
   - Launches load balancer (Nginx) and webservers (Apache)
   - Generates Ansible inventory automatically from Terraform outputs

2. **Wait for SSH** ensures servers are ready
   - Script waits for the load balancer to be accessible via SSH
   - Prevents premature Ansible configuration attempts

3. **Ansible** configures all servers
   - Installs and configures Apache on webserver1 and webserver2
   - Installs and configures Nginx on the load balancer
   - Sets up round-robin load balancing
   - Each webserver displays its hostname in responses

4. **Deployment Complete**
   - All infrastructure is provisioned and configured
   - Application is ready to receive traffic on port 8082

### Expected Output
     Step 1: Creating infrastructure with Terraform...
     ...
     Step 2: Getting server IP addresses...
     Load Balancer Public:  172.27.x.x
     Load Balancer Private: 192.168.4.x

     Step 3: Waiting for SSH on load balancer...
     Load balancer SSH ready!

     Step 4: Configuring servers with Ansible...
     ...
     All servers configured successfully!

     Deployment Summary:
     Your web application is available at: http://172.27.x.x:8082
     SSH access: ssh ubuntu@172.27.x.x

3. **Testing**

     ```sh
     # Test load balancer (use the IP from deployment output)
     curl http://YOUR_PUBLIC_IP:8082

     # Round-robin test
     for i in {1..6}; do curl -s http://YOUR_PUBLIC_IP:8082 | grep delivered; done
     ```

    **Expected output:**
     ```
     Content proudly delivered by webserver2
     Content proudly delivered by webserver1  
     Content proudly delivered by webserver2
     Content proudly delivered by webserver1
     Content proudly delivered by webserver2
     Content proudly delivered by webserver1
     ```

4. **Cleanup**

     ```sh
     source .env
     cd deploy/terraform && terraform destroy -auto-approve
     ```

## Security Notes

- No credentials or private keys are included in the repository.  
- All sensitive data is loaded via `.env` and `terraform.auto.tfvars` and ignored by `.gitignore`.  
- Ports are restricted so that:
  - Only load balancer is exposed on port 8082
  - Web servers are only accessible internally on port 80
