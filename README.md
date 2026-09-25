# Assignment: Infrastructure

Infrastructure as Code project that deploys:

- 1 Nginx load balancer
- 2 Apache web servers
- Round-robin load balancing
- Automated provisioning with Terraform and Ansible

## Prerequisites

- OpenStack account
- SSH key pair uploaded to OpenStack
- Terraform and Ansible installed

## Deploy

```sh
source ~/path/to/your-openrc.sh

export TF_VAR_key_name="name-keypair"
export TF_VAR_identity_file="~/.ssh/name.pem"

./deploy.sh
```

## Test

```sh
curl http://<LOAD_BALANCER_IP>:8082
```

To verify round-robin load balancing:

```sh
for i in {1..6}; do
  curl -s http://<LOAD_BALANCER_IP>:8082
done
```

## Cleanup

```sh
source ~/path/to/your-openrc.sh
cd deploy/terraform
terraform destroy -auto-approve
```