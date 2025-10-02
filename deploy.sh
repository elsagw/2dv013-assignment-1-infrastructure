#!/bin/bash

# Deploy script for Assignment 1 - Infrastructure
set -e

# Check if we're in the right directory
if [ ! -f "deploy.sh" ] || [ ! -d "deploy/terraform" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "   Example: cd assignment-1-infrastructure && ./deploy.sh"
    exit 1
fi

echo "🚀 Starting Assignment 1 Infrastructure Deployment..."

# Load environment variables if .env exists
if [ -f .env ]; then
    echo "📁 Loading environment variables from .env..."
    source .env
else
    echo "⚠️  No .env file found. Using system environment variables."
fi

# Check if required tools are installed
echo "🔍 Checking required tools..."
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform not found."; exit 1; }
command -v ansible-playbook >/dev/null 2>&1 || { echo "❌ Ansible not found."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq not found."; exit 1; }

# Check directory structure
echo "📂 Checking project structure..."
if [ ! -d "deploy/terraform" ] || [ ! -d "deploy/ansible" ]; then
    echo "❌ Required directories not found!"
    exit 1
fi

# Step 1: Initialize and apply Terraform
echo "📦 Step 1: Creating infrastructure with Terraform..."
cd deploy/terraform

if [ ! -d ".terraform" ]; then
    terraform init
fi

terraform plan
terraform apply -auto-approve

# Step 2: Extract outputs from Terraform
echo "🔍 Step 2: Getting server IP addresses..."
LB_PUBLIC_IP=$(terraform output -raw loadbalancer_public_ip)
LB_PRIVATE_IP=$(terraform output -raw loadbalancer_private_ip)
WS1_IP=$(terraform output -json webserver_info | jq -r '.webserver1')
WS2_IP=$(terraform output -json webserver_info | jq -r '.webserver2')

echo "📍 Server IP addresses:"
echo "   Load Balancer Public:  $LB_PUBLIC_IP"
echo "   Webserver 1:           $WS1_IP"
echo "   Webserver 2:           $WS2_IP"

# Go back to root directory
cd ../../

# Step 3: Create Ansible inventory from template
echo "📝 Step 3: Creating Ansible inventory..."
sed -e "s/\${WEBSERVER1_IP}/$WS1_IP/g" \
    -e "s/\${WEBSERVER2_IP}/$WS2_IP/g" \
    -e "s/\${LOADBALANCER_PRIVATE_IP}/$LB_PRIVATE_IP/g" \
    -e "s/\${LOADBALANCER_PUBLIC_IP}/$LB_PUBLIC_IP/g" \
    -e "s|\${TF_VAR_identity_file}|$TF_VAR_identity_file|g" \
    deploy/ansible/inventory.tmpl > deploy/ansible/inventory-generated

# Step 4: Wait for SSH on all servers
echo "⏳ Step 4: Waiting for SSH on all servers..."
max_attempts=10
attempt=1

# Wait for load balancer first
echo "   Checking load balancer SSH..."
while [ $attempt -le $max_attempts ]; do
    if ssh -i $TF_VAR_identity_file -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$LB_PUBLIC_IP "echo 'SSH Ready'" >/dev/null 2>&1; then
        echo "   ✅ Load balancer SSH ready!"
        break
    else
        echo "   ⏳ Load balancer attempt $attempt/$max_attempts..."
        sleep 10
        ((attempt++))
    fi
done

# Wait for webservers via jumpserver
echo "   Checking webserver SSH via jumpserver..."
for server in "webserver1:$WS1_IP" "webserver2:$WS2_IP"; do
    server_name=$(echo $server | cut -d: -f1)
    server_ip=$(echo $server | cut -d: -f2)
    attempt=1
    
    echo "   Testing $server_name ($server_ip)..."
    while [ $attempt -le $max_attempts ]; do
        if ssh -i $TF_VAR_identity_file -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o ProxyJump=ubuntu@$LB_PUBLIC_IP ubuntu@$server_ip "echo 'SSH Ready'" >/dev/null 2>&1; then
            echo "   ✅ $server_name SSH ready!"
            break
        else
            echo "   ⏳ $server_name attempt $attempt/$max_attempts..."
            sleep 10
            ((attempt++))
        fi
        
        if [ $attempt -gt $max_attempts ]; then
            echo "   ⚠️  $server_name SSH not ready after $max_attempts attempts"
            echo "   Continuing anyway - Ansible will handle retries..."
        fi
    done
done

echo "✅ SSH validation complete!"

# Step 5: Run Ansible playbook with retries
echo "⚙️  Step 5: Configuring servers with Ansible..."
cd deploy/ansible

# First try - all servers
echo "   Attempting configuration of all servers..."
if ansible-playbook -i inventory-generated playbook.yml; then
    echo "✅ All servers configured successfully!"
else
    echo "⚠️  Some servers failed. Retrying with available servers only..."
    
    # Test which servers are reachable
    echo "   Testing server connectivity..."
    ansible all -i inventory-generated -m ping --one-line || true
    
    # Retry with a timeout and different strategy
    echo "   Retrying configuration..."
    ansible-playbook -i inventory-generated playbook.yml \
        --timeout=30 \
        --strategy=free \
        || echo "⚠️  Some servers may need manual intervention"
fi

cd ../../

echo "🎉 Deployment Summary"
echo "🌐 Your web application is available at: http://$LB_PUBLIC_IP:8082"
echo "🔧 SSH access: ssh ubuntu@$LB_PUBLIC_IP"
echo "📋 To destroy: cd deploy/terraform && terraform destroy"
