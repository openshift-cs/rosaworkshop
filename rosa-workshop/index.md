<!---## Red Hat OpenShift Service on AWS (ROSA) information pages-->

### What is Red Hat OpenShift Service on AWS (ROSA)?
ROSA is a _fully_ managed Red Hat OpenShift service running natively on Amazon Web Services (AWS), which allows customers to quickly and easily build, deploy, and manage Kubernetes applications on the industry’s most comprehensive Kubernetes platform in the AWS public cloud. 

The latest version of ROSA makes use of AWS Secure Token Service (STS) for the ROSA cluster components. AWS STS is a global web service that allows the creation of temporary credentials for IAM users or federated users. ROSA uses this to assign IAM roles short-term, limited-privilege, security credentials. These credentials are associated with IAM roles that are specific to each component that makes AWS API calls. This better aligns with principals of least privilege and is much better aligned to secure practices in cloud service resource management. The ROSA CLI tool manages the STS credentials that are assigned for unique tasks and takes action upon AWS resources as part of OpenShift functionality. One limitation of using STS is that roles must be created for each ROSA cluster.

A listing of the account-wide and per-cluster roles is provided in the documentation.


### What information is on this site?
These pages are split into two sections. One contains the steps to getting started on ROSA ("Getting started with ROSA").  While the other is about deploying an application to ROSA to get better familiar with the internals of OpenShift ("OpenShift Internals Lab") and deploy your first application on ROSA.

### Creating your first ROSA Cluster
If you'd like an easy to follow guide for creating your first ROSA cluster you've come to the right place.

1. First please review the [prerequisites](https://docs.openshift.com/rosa/rosa_getting_started/rosa-aws-prereqs.html) which contains important information about the AWS account requirements.  
1. Then visit the Getting Started tutorial for [Setting up your account](rosa/1-account_setup.md).

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
* [OpenShift Container Platform Documentation](https://docs.openshift.com/container-platform/4.7/welcome/index.html) (for all other OpenShift related information)
* [Red Hat Support](https://support.redhat.com)
* [OpenShift Cluster Manager](https://console.redhat.com/OpenShift)
* [Learn about OpenShift](https://learn.openshift.com)
* [OpenShift Blog](https://www.openshift.com/blog)


**Note:** Anytime "ROSA" is used in this lab it stands for Red Hat OpenShift Service on AWS. The ROSA acronym will be used mostly.