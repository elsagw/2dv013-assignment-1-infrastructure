# Assignment: Infrastructure


## Part 1. - Platforms for automatic server configuration

This [project](https://gitlab.lnu.se/dipeab/2dv013-ht26-a1-provided) contains code that creates an instance an configures a simple web application and a database. It includes: 

- The baseline Terraform code that provisions infrastructure is provided in the *deploy/terraform* folder without hardcoding private information. 
- The baseline Ansible code that configures the web application and a database is provided in the folder *deploy/ansible*. Currently, the application and database are co-located on the same server; that is, the webapp connects to the database via `127.0.0.1` (the IP address of the database is currently hardcoded on variable `db_ip_address` at *deploy/ansible/group_vars/all.yml*).
- The code of the web application is located at *deploy/ansible/files/app.py* and it uses a configuration file to read the information about the access to the datdabase. That configuration file is located at *deploy/ansible/templates/config.ini.j2* and the playbookA1.yml already contains the tasks that places that configuration file on the web application.
- The web application just shows some status of the database and a counter of the number of received requests. 

- Moreover, the same [project](https://gitlab.lnu.se/dipeab/2dv013-ht26-a1-provided) contains additional help. It includes:
    - The Terraform and Ansible execution are connected. The connection between the two tools is described in the file *deploy/terraform/04-configure.tf*. In this file:
        - The inventory file is created by Terraform (lines 2-9).
        - The `ansible-playbook` is called by Terraform in the "ansible-deploy" element, which is a `null_resource` with a `local-exec` inside (lines 32-48, commented in case you prefer another way to handle the execution sequence).
        - Even if we write that the `ansible-playbook` depends on the creation of a server instance, Terraform sees the instance as *Running* while it is still booting. In that case, SSH may not be ready, causing Ansible to fail. An example to address this in Terraform is available in the `wait_ssh` block (lines 12-29).
    - A shell script called `deploy.sh` is provided that allows to execute the full provisioning and configuration process with a single command from the root project. 



In this assignment, you have to push to your project repository on gitlab.lnu.se the necessary modification of the code at the provided [project](https://gitlab.lnu.se/dipeab/2dv013-ht26-a1-provided) that, **by executing only the deploy.sh script** at the project root directory, will create a web application and database where: 

1. The provided single-server infrastructure is separated into an **infrastructure that uses two servers** on Cumulus: a `webapp` server running the web application and a `database` server running PostgreSQL.

2. The web application is configured to listen on port **8080** instead of on the current port 80 (the port where the web application listes is configured currelty harcoded on the last line of the app.py at *deploy/ansible/files/app.py*).

3. Ensure the web application on the `webapp` server successfully connects over the private network to PostgreSQL on the `database` server, updating and displaying the visit counter and database version on the web page.

### Some notes and help:


- See the file `00-variables.tf` in the *deploy/terraform* folder. Keep all variables for clarity, but the minimum required are `identity_file` and `key_name`. You will need to add new variables to avoid hardcoding parameters like port numbers across multiple files.

- Rule to follow: Do not hardcode any of your private information in those files. The users (and the assignment Examiner) have their own credentials for the provider “openstack.”
- The execution of `deploy.sh` should output the public IP address to connect to your web application and the private IPs of the servers. Using Terraform `output` values is recommended, as the `05-output.tf` currently does for the single provisioned server.
- After executing `deploy.sh`, a simple `terraform destroy` command should tear down the whole infrastructure.
- The purpose of asking for the `deploy.sh` script is to give you the freedom to handle the `ansible-playbook` command inside Terraform execution (as in the commented lines in `deploy/terraform/04-configure.tf`) or as an independent command after `terraform apply -auto-approve` has provisioned the infrastructure.

**Important**: Assume that the user has already defined his/her variables for the `identity_file` and the `key_name` at `00-variables.tf`. If you use a `tfvars` file locally, remember not to push it to the repository because it contains your user-specific information! (the provided `.gitignore` already avoids pushing it by default)

### Evaluable aspects
**MUST** requirements (failing to satisfy one of these will fail the assignment):

- Both servers (`webapp` and `database`) are deployed and accessible. It will be checked that the web application is accessible on port 8080 from the University VPN, and that the web application successfully reads and writes data to the database server over the private network.

- No user-specific information is hardcoded in your code (e.g., your key name, that is the reason why the variable `key_name` at `00-variables.tf` will read the value from the environment variables).

- No Cumulus username/credentials or private keys are pushed to the repository.

**SHOULD** requirements (you can fail one of them, but failing to satisfy two of these will fail the assignment):

- The web application port number (**8080**) is hardcoded **only once** across the entire codebase (Terraform, Ansible templates, and Python app). Use variables and templating to propagate this value wherever needed. Note that port 80 currently appears hardcoded three times across the baseline files (twice in Terraform and once in Python), creating an error-prone setup when the developer wants to modify it (remember the issues in the last minutes of the CI/CD workshop when updating information in the website that was hardoced twice in its source code and it was error-prone).

- It should not be possible to reach any server on port 80 (or any unneeded port), even if no service is listening on the port.

- The database server should not expose PostgreSQL (port 5432) to the public internet; access must be restricted to the internal network / `webapp` server (note that the baseline terraform code does not open the port 5432).

**MIGHT** requirements (if you satisfy this requirement, you are allowed to fail two of the previous three **should** requirements; if you do not satisfy it, no penalty):

- Use only one public IP. Assign a public IP solely to the `webapp` server, leaving the `database` server on a purely private network. 
    
    - This requires configuring Ansible to manage a machine with only a private IP via a [jump server / bastion](https://en.wikipedia.org/wiki/Jump_server). Refer to `deploy/terraform/templates/inventory_jump_server.tmpl` in the provided repository for guidance on setting up jump hosts in Ansible.

## Part 2. Continuous Delivery 

### 2.1. Explain, in your own words (max. 300 characters):
A concrete risk and a concrete benefit of applying Continuous Deployment instead of Continuous Delivery on a concrete project. You can use the site that we deployed in the CI/CD workshop as a concrete project. What could go wrong in that project if we apply Continuous Deployment? What could be better in that project if we apply Continuous Deployment?

Add a file named "part2.txt" or "part2.md" to your repository root that answers that question. 

## Assignment Hand in via Merge Request

You hand in the assignment by making a Merge Request of your project against the `lnu/submit-branch`.