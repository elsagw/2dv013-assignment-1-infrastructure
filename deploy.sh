#!/bin/bash

ansible-galaxy collection install -r ansible/requirements.yml

cd terraform
tofu init
tofu apply -auto-approve
