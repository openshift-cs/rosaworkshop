<!---## Red Hat OpenShift Service on AWS (ROSA) information pages-->

### What is Red Hat OpenShift Service on AWS (ROSA)?
ROSA is a _fully_ managed Red Hat OpenShift cluster running natively on Amazon Web Services (AWS), which allows customers to quickly and easily build, deploy, and manage Kubernetes applications on the industry’s most comprehensive Kubernetes platform in the AWS public cloud. 

The latest version of ROSA makes use of AWS Secure Token Service (STS) for the ROSA cluster components. AWS STS is a global web service that allows the creation of temporary credentials for IAM users or federated users. ROSA uses this to assign IAM roles short-term, limited-privilege, security credentials. These credentials are associated with IAM roles that are specific to each component that makes AWS API calls. This better aligns with principals of least privilege and is much better aligned to secure practices in cloud service resource management. The ROSA CLI tool manages the STS credentials that are assigned for unique tasks and takes action upon AWS resources as part of OpenShift functionality. One limitation of using STS is that roles must be created for each ROSA cluster.

A listing of the account-wide and per-cluster roles is provided in the documentation.

### What information is on this site?
These pages are split into three sections. One contains the steps to getting started on ROSA ("Getting started with ROSA").  Another is about deploying an application to ROSA to get better familiar with the internals of OpenShift ("Deploy the application"). While the last is a summary of a few key OpenShift concepts that will be used in the workshop.

### What will we do in this workshop?
In this workshop, you’ll go through a set of tasks that will help you understand the concepts of deploying and using container based applications.

Some of the things you’ll be going through:

- Deploy a ROSA cluster using STS
- Deploy a node.js based app via S2I and Kubernetes Deployment objects
- Set up an continuous delivery pipeline to automatically push changes to the source code
- Explore logging
- Experience self healing of applications
- Explore configuration management through configmaps, secrets and environment variables
- Use persistent storage to share data across pod restarts
- Explore networking within Kubernetes and applications
- Familiarization with OpenShift and Kubernetes functionality
- Automatically scale pods based on load via the Horizontal Pod Autoscaler

If you'd like a preview of the cluster deployment process, you can watch a short demo:

<iframe width="560" height="315" src="https://www.youtube.com/embed/_3vaKfPHm1c" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Creating your first ROSA Cluster
If you'd like an easy to follow guide for creating your first ROSA cluster:

1. Please review the [prerequisites](https://docs.openshift.com/rosa/rosa_getting_started_sts/rosa-sts-aws-prereqs.html) which contains important information about the AWS account requirements.  
1. Visit the "Getting Started with ROSA" tutorial for [Setting up your account](rosa/1-account_setup.md).


### Resources

* ROSA Product Pages:
    * <https://www.openshift.com/products/amazon-openshift>
    * <https://aws.amazon.com/rosa/>
    * <https://access.redhat.com/products/red-hat-openshift-service-aws>
* [ROSA Documentation](https://docs.openshift.com/rosa/welcome/index.html) (only ROSA specific)
	- [Service Definition](https://docs.openshift.com/rosa/rosa_policy/rosa-service-definition.html)
    - [Responsibility Assignment Matrix](https://docs.openshift.com/rosa/rosa_policy/rosa-policy-responsibility-matrix.html)
    - [Understanding Process and Security](https://docs.openshift.com/rosa/rosa_policy/rosa-policy-process-security.html)
    - [About Availability](https://docs.openshift.com/rosa/rosa_policy/rosa-policy-understand-availability.html)
    - [Updates Lifecycle](https://docs.openshift.com/rosa/rosa_policy/rosa-life-cycle.html)
    - [Limits and Scalability](https://docs.openshift.com/rosa/rosa_planning/rosa-limits-scalability.html)
    - [Planning Your Environment](https://docs.openshift.com/rosa/rosa_planning/rosa-planning-environment.html)
* [ROSA Roadmap](https://red.ht/rosa-roadmap)
* [OpenShift Container Platform Documentation](https://docs.openshift.com/container-platform/4.8/welcome/index.html) (for all other OpenShift related information)
* [Red Hat Support](https://support.redhat.com)
* [OpenShift Cluster Manager](https://console.redhat.com/OpenShift)
* [Learn about OpenShift](https://learn.openshift.com)
* [OpenShift Blog](https://www.openshift.com/blog)


**Note:** Anytime "ROSA" is used in this lab it stands for Red Hat OpenShift Service on AWS. The ROSA acronym will be used mostly.