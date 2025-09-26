# Assignment: Infrastructure


## Part 1. - Platforms for automatic server configuration


Push to your project repository on gitlab.lnu.se the necessary code for Terraform, Ansible, and a shell script called deploy.sh that, **by by executing only the deploy.sh script** will allow the user to: 

1. Create two functional webservers (`webserver1` and `webserver2`) on Cumulus that listen on the default port 80 and return the content that you prefer. To make the evaluation of the presence of two servers easier, make sure that the content is slightly different from each server; you have a simple example of how to do it in the following notes

1. Create a server with an nginx that listens on port 8082 and acts as a load balancer following the Round-Robin method for the two webservers above.

# Some notes:

- This [project](https://gitlab.lnu.se/dipeab/2dv013-ht25-a1-provided) contains the code that we saw during the workshops. It includes: 
    - The Terraform code that creates a server is provided in the *deploy/terraform* folder, and it does not hardcode private information. 
    - The code that installs a webserver, copies an HTML file as its data, and changes the listening port of the server is provided in the folder *deploy/ansible*. 
- Moreover the same [project](https://gitlab.lnu.se/dipeab/2dv013-ht25-a1-provided) contains additional help. You do not need to know about it now because it will be explained on Wednesday's workshop. It includes:
    - The Terraform and Ansible execution are connected. The connection between the two tools is described in the file *deploy/terraform/04-configure.tf*. On this file:
        - The inventory file is created by Terraform (lines 2-9)
        - The `ansible-playbook` is called by Terraform in the "ansible-deploy" element, which is a null_resource with a local-exec inside (lines 32-48, commented in case you prefer another way to make the sequence of Terraform and Ansible execution)
        - Even if we write that the `ansible-playbook` playbook depends on the creation of a server instance, it happens that Terraform sees the instance as *Running* even if it is still booting. In that case, the instance has not started its SSH server yet, and Ansible receives an error when it tries to connect to configure. There are several ways to address this "inconvenience", either by modifying the Ansible code or the Terraform code. You see an example to address the "inconvenience" in Terraform code in the wait_ssh block (lines 12-29)

    - See the file variables.tf in the *deploy/terraform* folder. There are some variables there. It is recommended that you keep all of them for clarity of the code, but the bare minimum that you must keep is the `identity_file` and `key_name` (more information about them later). Otherwise, the users will not be able to execute your code. Of course, you can use more variables to make the Terraform code more readable and cleaner. 

- Rule to follow: Do not hardcode any of your private information in those files. The users (and the assignment Examiner) have their own credentials for the provider “OpenStack.”
- The execution of deploy.sh should also output the public IP addresses to connect to your. It is OK if you simply use the Terraform “output” value.
- After executing the deploy.sh, a simple “terraform destroy” command should tear down the whole infrastructure.
- The purpose of asking for the deploy.sh script is to give you the freedom to handle the ansible-playbook command inside Terraform execution (as in the commented lines in deploy/terraform/04-configure.tf) or as an independent command after the “terraform apply -auto-approve” has provisioned the infrastructure.
- Instructions for configuring nginx as a load balancer [here](https://nginx.org/en/docs/http/load_balancing.html) (both short and detailed enough for our purposes) and, if you are interested, more detailed [here](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/#proxy-http-traffic-to-a-group-of-servers).
    - The Round-Robin is the default method in nginx. You do not need to add anything specific to make nginx follow that method. It is important to follow it for the evaluation of your assignment because we can be sure that each of the two consecutive requests for a page is served by a different server. 
    - In the Ansible code, there is a task *Customize output for the server that delivers it*. Keep it for your webservers to be able to test that both are load-balanced. 

**Important**: Assume that the user has already defined his/her variables for the identity_file and the key_name. An explanation of the use of variables in Terraform will be provided during Wednesday's seminar. If you want to explore the use of variables yourself, this [guide](https://spacelift.io/blog/terraform-tfvars) is quite good. I recommend that you set them either using environment variables in point 2 in the previous guide (that's how it will be shown on Wednesday) or with `tfvars` file in point 3 in the previous guide. If you use a tfvars file, remember not to push it to the repository because it contains your user-specific information!

### Evaluable aspects
**MUST** requirements (failing to satisfy one of these will fail the assignment):

- The three servers are deployed and are accessible. It will be checked that the load balancer is accessible on 8082 from the University VPN and the webservers on port 80 from their local network. 

- No user-specific information is hardcoded in your code; for instance, the name of your key or the name of your identity file .pem. This is important because in your future projects, you will not be the only developer involved, so do not push to the repository any information that is specific to you. This is why we needed some variables above. 

- No username/credentials or your private_key is pushed to the repository

**SHOULD** requirements (you can fail one of them, but failing to satisfy two of these will fail the assignment):

- It should not be possible to contact the webservers server on port 8082 (otherwise they have more ports opened than necessary)

- It should not be possible to contact the load balancer on port 80 (otherwise, it has more ports opened than necessary)

- The numbers 80 and 8082 for the ports to use are written only once in your code. For example, in the project provided, port 80 appears twice, once in the Terraform code to open the port and again in the inventory template; you have to fix that weakness in the code.

**MIGHT** requirements (if you satisfy this requirement, you are allowed to fail two of the previous three **should** requirements; if you do not satisfy it, no penalty):

- Use only one public IP. The load balancer is the only server that can have a public IP. In that case, external users cannot access the webservers directly (as it should happen in a real application). It should be possible to contact the load balancer using the public IP on port 8082, and the load balancer should balance the load to the webservers using their private IPs.
    
    - This requirement will create difficulties for you to configure, using Ansible, a machine that has only a private IP. This difficulty can be solved by defining a [jump server](https://en.wikipedia.org/wiki/Jump_server) in the Ansible properties. If you are interested in satisfying this requirement, take a look at the `deploy/terraform/templates/inventory_jump_server.tmpl` file, and you can ask me during the week for help on how to configure the jump server in Ansible.

## Part 2. Continuous Delivery 

### 2.1. Explain, in your own words (max. 300 characters):
A concrete risk and a concrete benefit of applying Continuous Deployment instead of Continuous Delivery on a concrete project. You can use the site that we deployed in the CI/CD workshop as a concrete project. What could go wrong in that project if we apply Continuous Deployment? What could be better in that project if we apply Continuous Deployment?

Add a file named "part2.txt" or "part2.md" to your repository root that answers that question. 

## Hand in via Merge Request

You hand in the assignment by making a Merge Request of your project against the lnu/submit-branch.

Pay extra attention to including a link to your Assignment Report and to assigning the MR to the correct Milestone.