# Assignment: Infrastructure


## Part 1. - Platforms for automatic server configuration


Push to this repository on gitlab.lnu.se the necessary code for Terraform, Ansible, and a shell script called deploy.sh that, **by executing only the deploy.sh script** will allo the user to: 

1.  create a functional webserver on cscloud that can be accessed through a Public IP on port 8082 and that returns the webpage whose HTML code is provided together with this text **text by executing only the deploy.sh script**. 

1. create a second server with a mysql database that can be accessed through a public IP and port 3306 (this is the default for MySQL).

Some notes:

- This [project](https://gitlab.lnu.se/dipeab/2dv013-ht24-a1-provided) contains the code that we saw during the workshops. It already includes: 
    - The code that creates a server is provided in the *deploy/terraform* folder and it does not  hardcode private information. 
    - See on the file variables.tf in the *deploy/terraform* folder the minimum set of variables that you must use; otherwise, the users  will not be able to execute your code. Of course, you can use more variables to make the Terraform code more readable and cleaner.
    - The code that installs a webserver, copies an HTML file as its data, and changes the listening port to 8080 is provided in folder *deploy/ansible*. 
- Rule to follow: Do not hardcode any of your private information in those files. The users (and the assignment Examiner) have their own credentials for the provider “Openstack.”.
- The execution of deploy.sh should also output the public IP addresses to connect to the webserver and to the mysql server. It is OK if you simply use the Terraform “output” value.
- After executing the deploy.sh, a simple “terraform destroy” command should tear down the whole infrastructure.
- The purpose of asking for the deploy.sh script is to give you the freedom to handle the ansible-playbook command inside Terraform execution or as a second command after the “terraform apply -auto-approve” has provisioned the infrastructure.

**Important**: Assume that the user has already exported his/her variables for the identity_file and the key_name

### Evaluable aspects
**MUST** requirements (failing to satisfy one of these will fail the assignment):

- The two servers deploy and are accessible. The webserver on port 8082 and the database server on port 3306.
- No user-specific information is hardcoded on your code.
- No username/credentials or your private_key is pushed to the repository.

**SHOULD** requirements (you can fail one of them, but failing to satisfy two of these will fail the assignment):

- It should not be possible to contact the database server on port 8082 (otherwise it has more ports opened than necessary).
- It should not be possible to contact the webserver cannot be contacted on port 3306 (otherwise it has more ports opened than necessary).
- The port 8082 is written only once in your code. In the project provided it appears twice, once in the terraformm code and another time in the ansible code in *group_vars/all.yml* and you have to fix that weakness in the code.

**MIGHT** requirements (if you satisfy this requirement you are allowed to fail two of the previous three **should** requirements; if you do not satisfy it, no penalty):

- Use only one public IP. In that case, external users cannot access the database server directly. It should be possible to contact the webserver using the public IP on port 8082, and the webserver should be able to connect to the database server using the database server private IP and port 3306.

    - This requirement has been added to make you think how to configure the databaswe server if it does not have a public IP (you can use the webserver as [jump server](https://en.wikipedia.org/wiki/Jump_server). You can ask me during the week for help on how to configure it if you want to satisfy this requirement.

## Part 2. Continuous Delivery 

### 2.1. Explain, in your own words (max. 300 charactes):
A concrete risk of applying Continuous Deployment instead of Continuous Delivery on a concrete project that deploys a website. You can use as concrete project the course site that we deployed in the CI/CD workshop. What could go wrong in that project if we apply Continuous Deployment?

Add a file named "part2.txt" or "part2.md" on your repository root that answers that question. 

## Hand in via Merge Request

You hand in the assignment by making a Merge Request of your project against the lnu/submit-branch.

Pay extra attention to including a link to your Assignment Report and to assign the MR to the correct Milestone.