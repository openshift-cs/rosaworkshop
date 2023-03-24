<!---## Red Hat OpenShift Service on AWS (ROSA) information pages-->

### What is Red Hat OpenShift Service on AWS (ROSA)?
Red Hat OpenShift Service on AWS (ROSA) is a _fully_-managed turnkey application platform that allows you to focus on what matters most, delivering value to your customers by building and deploying applications. Red Hat and AWS SRE experts manage the underlying platform so you don’t have to worry about the complexity of infrastructure management. ROSA provides seamless integration with a wide range of AWS compute, database, analytics, machine learning, networking, mobile, and other services to further accelerate the building and delivering of differentiating experiences to your customers.

The latest version of ROSA makes use of AWS Security Token Service (STS) to obtain credentials to manage infrastructure in your AWS account. AWS STS is a global web service that allows the creation of temporary credentials for IAM users or federated users. ROSA uses this to assign IAM roles short-term, limited-privilege, security credentials. These credentials are associated with IAM roles that are specific to each component that makes AWS API calls. This better aligns with principals of least privilege and is much better aligned to secure practices in cloud service resource management. The ROSA CLI tool manages the STS credentials that are assigned for unique tasks and takes action upon AWS resources as part of OpenShift functionality. Please see the section "[ROSA with STS Explained](rosa-workshop/rosa/15-sts_explained.md)" for a detailed explanation.

A listing of the account-wide and per-cluster roles is provided in the [documentation](https://docs.openshift.com/rosa/rosa_architecture/rosa-sts-about-iam-resources.html).

### What information is on this site?
These pages are split into three sections.

1. One contains the steps to getting started on ROSA ("Getting started with ROSA").  
1. Another is about deploying an application to ROSA to get better familiar with the internals of OpenShift ("Deploy the application").
1. Lastly, some reference pages with a summary of a few key OpenShift concepts that will be used in the workshop, an FAQ, and an explanation of ROSA with STS.

### What will we do in this workshop?
In this workshop, you’ll go through a set of tasks that will help you understand the concepts of deploying and using container based applications on top of ROSA.

Some of the things you’ll be going through:

- Deploy a ROSA cluster using STS
- Perform common tasks like:
    - User access and elevated permissions
    - Managing worker nodes
    - Scaling and autoscaling
    - Upgrading
    - Delete the cluster
- Deploy a node.js based app via S2I and Kubernetes Deployment objects
- Set up a continuous delivery pipeline to automatically push changes to the source code
- Explore logging
- Experience self healing of applications
- Explore configuration management through configmaps, secrets and environment variables
- Use persistent storage to share data across pod restarts
- Explore networking within Kubernetes and applications
- Familiarization with OpenShift and Kubernetes functionality
- Automatically scale pods based on load via the Horizontal Pod Autoscaler
- Automatically scale the cluster based on load
- Integrate with an AWS S3 bucket to read or write objects

If you'd like a preview of the cluster deployment process, you can watch a short demo:

[Deploying a ROSA cluster](https://youtu.be/KbzUbXWs6Ck)

### Creating your first ROSA Cluster
If you'd like an easy to follow guide for creating your first ROSA cluster:

1. Please review the [prerequisites](https://docs.openshift.com/rosa/rosa_planning/rosa-sts-aws-prereqs.html) which contains important information about the AWS account requirements.  
1. Visit the "Getting Started with ROSA" tutorial starting with [Setting up your account](rosa-workshop/rosa/1-account_setup.md).


### Resources

- ROSA Product Pages:
    - <https://www.openshift.com/products/amazon-openshift>
    - <https://aws.amazon.com/rosa/>
    - <https://access.redhat.com/products/red-hat-openshift-service-aws>
- [AWS ROSA Getting Started Guide](https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started.html)
- [ROSA Documentation](https://docs.openshift.com/rosa/welcome/index.html) (only ROSA specific)
  	- [Service Definition](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html)
    - [Responsibility Assignment Matrix](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-policy-responsibility-matrix.html)
    - [Understanding Process and Security](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-policy-process-security.html)
    - [About Availability](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-policy-understand-availability.html)
    - [Updates Lifecycle](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-life-cycle.html)
    - [Limits and Scalability](https://docs.openshift.com/rosa/rosa_planning/rosa-limits-scalability.html)
    - [Planning Your Environment](https://docs.openshift.com/rosa/rosa_planning/rosa-planning-environment.html)
- [ROSA Roadmap](https://red.ht/rosa-roadmap)
- [OpenShift Container Platform Documentation](https://docs.openshift.com/container-platform/4.12/welcome/index.html) (for all other OpenShift related information)
- [Red Hat Support](https://support.redhat.com)
- [OpenShift Cluster Manager](https://console.redhat.com/OpenShift)
- [Learn about OpenShift](https://learn.openshift.com)
- [OpenShift Blog](https://www.openshift.com/blog)


**Note:** Anytime "ROSA" is used in this lab it stands for Red Hat OpenShift Service on AWS. The ROSA acronym will be mostly used.
