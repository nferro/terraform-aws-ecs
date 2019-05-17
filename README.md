# Introduction
This Terraform blueprint is an example on how to deploy an Nginx container on [Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) fronted by an [ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html#application-load-balancer-overview). 

This was mostly done as a learning exercise on AWS and it does aim to be a good example of Terraform best practices.

Security was also not a concern. Security Groups should be used to isolate the ECS instances from the Internet, only allowing traffic from within the VPC.

# Design
The Nginx Docker container will run on ECS, whose Instances will be managed by an Auto Scaling Group. 

For better resilience, there are two containers running on two Instances on different Availability Zones.


# Usage
Start by editing the credentials on [secrets.sample.tfvars](secrets.sample.tfvars) and save the file as something like `secrets.tfvars`.

Assuming you already have `terrafom` available on your computer, you create the cluster with:
```
terraform destroy -var-file=secrets.tfvars
```

When you're done, destroy everything with:
```
terraform apply -var-file=secrets.tfvars
```