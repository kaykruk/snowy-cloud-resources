# Create an Auto Scaling Group & Application Load Balancer with AWS CloudFormation

# What is an Auto Scaling Group and Application Load Balancer?
Auto Scaling is a service that monitors and adjusts the number of instances according to changing demands. This service can add instances if the workload increases, and remove instances if the workload decreases. With Auto Scaling Groups (ASG) you can manage a group of EC2 instances based on defined scaling policies that are set.

# An Application Load Balancer (ALB) helps by distributing incoming traffic across multiple instances.

# Why Use CloudFormation?
AWS CloudFormation is an Infrastructure as Code (IaC) service that allows users to model and manage resources with programming language in an automated and secure way. CloudFormation can be used to provision simple to complex applications and multi-tier environments across multiple regions. And with the use of code templates in JSON or YAML format, users can take advantage of version control and effective collaboration. Using this tool, we are going to create a VPC, 3 public subnets and an Auto Scaling Group with Apache server hosting a custom page installed on each instance. The ASG will be set to a desired capacity of 3 instances, with 2 being the minimum and 5 the maximum. 
We’re also going to add a target policy for the ASG to scale after CPU utilization exceeds 50% and create an Application Load Balancer to distribute traffic to the ASG. 
Once finished, we are going to use the DNS name of the ALB to access the page and stress an instance above 50% to see if the scaling policy works.
