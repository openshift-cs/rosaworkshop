# Red Hat OpenShift Service on AWS - FAQ

## General

### What is Red Hat OpenShift Service on AWS (ROSA)?
Red Hat Openshift Service on AWS (ROSA) is a fully-managed turnkey application platform that allows you to focus on what matters most, delivering value to your customers by building and deploying applications. Red Hat SRE experts manage the underlying platform so you don’t have to worry about the complexity of infrastructure management.

### Where can I go to get more information/details?
- [ROSA Webpage](https://www.openshift.com/products/amazon-openshift)
- [ROSA Workshop](https://www.rosaworkshop.io)
- [ROSA Documentation](https://docs.openshift.com/rosa/welcome/index.html)

### What are the benefits of Red Hat OpenShift Service on AWS (Key Features)?
- **Native AWS service:** Access and use Red Hat OpenShift on demand with a self-service on-boarding experience through the AWS management console.
- **Flexible, consumption-based pricing:** Scale as per your business needs and pay as you go with flexible pricing with an on-demand hourly or annual billing model.
- **Single bill for Red Hat OpenShift & AWS usage:**  Customers will receive a single bill from AWS for both Red Hat OpenShift and AWS consumption.
- **Fully integrated support experience:** Installation, management, maintenance, and upgrades are performed by Red Hat site reliability engineers (SRE) with joint Red Hat and Amazon support and a 99.95% SLA.
- **AWS service integration:** AWS has a robust portfolio of cloud services, such as compute, storage, networking, database, analytics, and machine learning, which are directly accessible via Red Hat OpenShift Service on AWS. This makes it easier to build, operate, and scale globally on demand through a familiar management interface.

Additional key features of Red Hat OpenShift Service on AWS:

- **Maximum Availability:** Deploy clusters across multiple Availability Zones in supported Regions to maximize availability to maintain high availability for your most demanding mission-critical applications and data.
- **Cluster node scaling:** Easily add or remove compute nodes to match resource demand
- **Optimized clusters:** Choose from memory-optimized, compute-optimized, or general purpose EC2 instance types, with clusters sized to meet your needs. See [AWS compute types](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-aws-compute-types_rosa-service-definition).
- **Global availability:** Please refer to the [product regional availability page](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-regions-az_rosa-service-definition) page for an up-to-date view of where Red Hat OpenShift Service on AWS is available.

### What are the differences between Red Hat OpenShift Service on AWS and Kubernetes?
Everything you need to deploy and manage containers is bundled with ROSA, including container management, automation (Operators), networking, load balancing, service mesh, CI/CD, firewall, monitoring, registry, authentication, and authorization capabilities. These components are tested together for unified operations as a complete platform. Automated cluster operations, including over-the-air platform upgrades, further enhance your Kubernetes experience.

### What exactly am I responsible for and what is Red Hat / AWS responsible for?
In short, anything that is related to deploying the cluster or keeping the cluster running will be Red Hat’s or AWS’s responsibility, and anything relating to the applications, users, or data is the customers responsibility.  Please see our [responsibility matrix](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-policy-responsibility-matrix.html) for more details.

### How does it work?
Red Hat OpenShift Service on AWS (ROSA) has infrastructure components (virtual machines, storage disks, etc.) and a software component (OpenShift). When you provision ROSA clusters you will incur the infrastructure and OpenShift charges at the pay-as-you-go hourly rate. Refer to the Red Hat OpenShift Service on AWS pricing page for more information. You can also do 1 or 3 year commits for even deeper discounts.

### Where can I see a roadmap or make feature requests for the service?
You can visit our [ROSA roadmap](https://red.ht/rosa-roadmap) to stay up to date with the status of features currently in development. Please feel free to open a new issue if you have any suggestions for the product team.

## Pricing

### How is the pricing of Red Hat OpenShift Service on AWS calculated?
See here for pricing information: [ROSA Pricing](https://aws.amazon.com/rosa/pricing/)

Red Hat OpenShift Service on AWS has three components to its cost.

  - First there is an hourly cluster fee, which is $0.03/cluster/hour (or approximately $263/cluster/year.)
  - The second component is the pricing per worker node, which is:
      - $0.171 per 4vCPU/hour for on-demand consumption (or approximately $1498/node/year.)
      - $0.114 per 4vCPU/hour for a 1-year RI commitment (or approximately $998/node/year.)
      - $0.076 per 4vCPU/hour for a 3-year RI commitment (or approximately $665/node/year.)
  - Third, are the underlying AWS infrastructure costs, like EC2 instances, network traffic, S3 buckets, etc. See here for [provisioned resources](https://docs.openshift.com/rosa/rosa_planning/rosa-sts-aws-prereqs.html#rosa-aws-policy-provisioned_rosa-sts-aws-prereqs).

_*OpenShift pricing for Red Hat OpenShift Service on AWS is the same for all supported AWS regions. Pricing listed above does not include infrastructure expenses._

**ON-DEMAND PRICING EXAMPLE**

If you have a 10 worker node cluster of type m5.xlarge, running on-demand for a year, the OpenShift cost for Red Hat OpenShift Service on AWS would be approximately:

$0.03 /cluster/hour X 1 cluster X 24 hours/day X 365.25 days/year = $263<br>
$0.171 /node/hour X 10 worker nodes X 24 hours/day X 365 days/year = $14,969.60<br>
Your total cost in this case would be $15,242<br>

_Pricing for Red Hat OpenShift Service on AWS is in addition to the costs of Amazon EC2 for control plane, infra & worker nodes and other AWS services used._

### When pricing out my EC2 instances, do I need to use RHEL for the operating system?
No, being that ROSA includes Red Hat Enterprise Linux CoreOS (RHCOS) as the operating system, you only need to choose Linux.
For clarity, ROSA cluster creation handles the setup of all the RHCOS nodes entirely.

### Does Red Hat OpenShift Service on AWS qualify for the AWS EDP Program?
Yes, Red Hat OpenShift Service on AWS fully qualifies for 100% of the spend on the AWS Enterprise Discount Program.

### Can I use spot/preemptible VMs?
Yes, additional MachinePools can be configured with Spot instances. Using Amazon EC2 Spot instances allows you to take advantage of unused capacity at a significant cost savings. Please see the [Creating a machine pool](https://docs.openshift.com/rosa/rosa_cluster_admin/rosa_nodes/rosa-managing-worker-nodes.html#creating_machine_pools_cli_rosa-managing-worker-nodes) section in the documentation for more information.

### Is there an upfront commitment?
There is no required upfront commitment. ROSA clusters can be provisioned on-demand, with pay-as-you-go billing, for both AWS & OpenShift expenses. In this case, there is no upfront commitment. One year & three year RI pricing is also available to take advantage of pricing discounts.

### How can I start using Red Hat OpenShift Service on AWS?
You can acquire the service directly from the AWS console. As with other AWS services, such as EC2, just spin up your OpenShift clusters and you will be charged based on your consumption. You can also contact your Red Hat or AWS representative. Here is a [short video](https://www.youtube.com/embed/KbzUbXWs6Ck) that demonstrates the process to deploy a ROSA cluster.

### Do I need to sign/have a contract with Red Hat?
No. You do not need to have a contract with Red Hat to use ROSA. You will need a Red Hat account for use on console.redhat.com which includes accepting our Enterprise Agreement and Online services terms.

### Can I bring my own license to the service (e.g. Red Hat Cloud Access)?
No. Billing occurs directly through AWS, preventing OpenShift Container Platform or OpenShift Dedicated subscriptions from being used with Red Hat OpenShift Service on AWS.

### Can I migrate my existing OpenShift Subscriptions to AWS?
  - OpenShift (OCP, OSD, OKE) subscriptions cannot be used with ROSA.
  - It is not possible to transfer the unused part of your Red Hat OpenShift subscription to ROSA.
  - Subscriptions included with a purchase of an IBM CloudPak cannot be used with ROSA.
  - ROSA subscriptions can only be purchased directly from AWS & AWS resellers.

### Can I purchase middleware subscriptions on-demand for my ROSA clusters?
Middleware subscriptions (e.g, Integration or Runtimes) are purchased from Red Hat yearly via the standard process.  Currently, there is no on-demand purchasing ability for your ROSA clusters.

### What are the regions where SREs have residency to operate?
Please see the [Red Hat Subprocessor List](https://access.redhat.com/articles/5528091).


## Service questions

### Which AWS regions is the service available in?
Please refer to the [product regional availability](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-regions-az_rosa-service-definition) page for an up-to-date view of where Red Hat OpenShift Service on AWS is available.

### Which compliance certifications does ROSA have so far?
Red Hat OpenShift Service on AWS is currently compliant with SOC-1, SOC-2 type 1 & type 2, ISO-27001, & PCI-DSS. We are also currently working towards FedRAMP High, HIPAA, ISO 27017 and ISO 27018 as well.

### Can a cluster have worker nodes across multiple AWS regions?
No, all nodes in a Red Hat OpenShift Service on AWS cluster must be located in the same AWS region; this follows the same model as that of OCP. For clusters configured for multiple availability zones control plane nodes and worker nodes will be distributed across the availability zones.

### What is the minimum number of worker nodes that a ROSA cluster can have?
For a ROSA cluster the minimum is 2 worker nodes for single AZ and 3 for multiple AZ.

### Where can I find the product documentation for ROSA?
ROSA documentation can be found [here](https://docs.openshift.com/rosa).

### Can an admin manage users and quotas?
Yes, a Red Hat OpenShift Service on AWS customer administrator can manage users and quotas in addition to accessing all user created projects. Please see for example [resource quotas per project](https://docs.openshift.com/container-platform/4.10/applications/quotas/quotas-setting-per-project.html).

### When will features of the latest version of Kubernetes be supported in ROSA via OpenShift 4?
Customers are able to upgrade to the newest version of OpenShift in order to inherit the features from that version of OpenShift (see [life cycle dates](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-life-cycle.html#rosa-life-cycle-dates_rosa-life-cycle)). Note, that since ROSA is an opinionated installation of OpenShift Container Platform, not all features may be available on ROSA. Please review the [Service Definition](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html).

### How can customers get support for the service?
ROSA is supported by AWS and Red Hat, and you have the option to contact support from either company to begin troubleshooting. Any escalations that are necessary will be facilitated as necessary by AWS and Red Hat to engage the best team to address the issues.

  - [Red Hat Support](https://access.redhat.com/)
  - [AWS Support](https://aws.amazon.com/premiumsupport/) (Customer must have valid AWS support contract)

You can also visit the [Red Hat Customer Portal](http://access.redhat.com/) to search or browse through the Red Hat Knowledgebase of articles and solutions relating to Red Hat products or to submit a support case to Red Hat Support. Or you can open up a ticket directly from [OpenShift Cluster Manager](https://console.redhat.com/openshift) (OCM).  See the [ROSA documentation](https://docs.openshift.com/rosa/rosa_support/rosa-getting-support.html) for more details about obtaining support.

### What happens if I do not upgrade my cluster before the "end of life" date?
Nothing will happen to an existing ROSA cluster. Your ROSA cluster will continue to operate though it will be in a "limited support" status. In short, this means that the SLA for that cluster will no longer be applicable, but you can still get support for that cluster.  Please see [Limited support status](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-life-cycle.html#rosa-limited-support_rosa-life-cycle) for more details.

### What is the SLA?
Please refer to the [Red Hat OpenShift Service on AWS SLA](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-sla_rosa-service-definition) page for details.

### How will customers be notified when new features/updates are available?
Updates will go through the regular communication channels, including AWS updates and email.

### What version of OpenShift is running?
Red Hat OpenShift Service on AWS is a managed service which is based on OpenShift Container Platform. You can view the current version and [life cycle dates](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-life-cycle.html#rosa-life-cycle-dates_rosa-life-cycle) in the ROSA documentation.

### Is Open Service Broker for AWS (OBSA) supported?  
Yes, you can use OSBA with Red Hat OpenShift Service on AWS.  See [Open Service Broker for AWS](https://aws.amazon.com/partners/servicebroker/) for more information. Though a more recent development is the [AWS Controller for Kubernetes](https://github.com/aws-controllers-k8s/community). This is the preferred method.

### What is the underlying node OS used?
As with all OpenShift v4.x offerings, the control plane, infra and worker nodes run Red Hat Enterprise Linux CoreOS (RHCOS).

### What is the process for customers wishing to ‘offboard’ their deployment in ROSA - is there a process?  
Customers can stop using the service anytime and move their applications to on-prem, private cloud or other cloud providers.  Standard reserved instances (RI) policy applies for unused RI.   

### What authentication mechanisms are supported with ROSA?
OpenID Connect (a profile of OAuth2), Google OAuth, GitHub OAuth, GitLab, and LDAP.

### How will events such as product updates and scheduled maintenance be communicated?
Red Hat will provide updates via email and Red Hat console service log.

### Does ROSA have a hibernation or shut-down feature for any nodes in the cluster to save costs on infrastructure or to retain a configured cluster for long-term?
No, not at this time. The shutdown/hibernation feature is an OpenShift platform feature not yet mature enough for widespread cloud services use.


## Deeper/Technical Questions

### Is SRE access to clusters secured by MFA?
Yes, all SRE access is secured by MFA. See [SRE access](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-policy-process-security.html#rosa-policy-sre-access_rosa-policy-process-security) in the documentation for more details.

### What encryption keys, if any, are used in a new ROSA cluster?
We encrypt EBS volumes that we use for ROSA, using a key stored in KMS. Customers have the option to provide their own KMS keys at cluster creation time as well.

### Is data on my cluster encrypted?
By default, there is encryption at rest. The AWS Storage platform automatically encrypts your data before persisting it, and decrypts the data before retrieval. See [AWS EBS Encryption](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) details.
There is also the ability to encrypt etcd in the cluster, and that would combine with AWS storage encryption, resulting in double the encryption (redundant), which adds up to 20% performance hit. For further details see [etcd encryption](https://docs.openshift.com/rosa/rosa_policy/rosa-service-definition.html#rosa-sdpolicy-etcd-encryption_rosa-service-definition).

### When can etcd encryption be done with a ROSA cluster?
Only at cluster creation time, can etcd encryption be enabled.
Note that this incurs additional overhead with negligible security risk mitigation.
See the prior question about EBS encryption.

### How is etcd encryption configured in a ROSA cluster?
The same as in OCP. The aescbc cypher is used and the setting is patched during cluster deployment. [Relevant Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/). For further details see [etcd encryption](https://docs.openshift.com/rosa/rosa_policy/rosa-service-definition.html#rosa-sdpolicy-etcd-encryption_rosa-service-definition).

### What infrastructure is provisioned as part of a new OSD cluster?
ROSA makes use of a number of different cloud services such as virtual machines, storage, load balancers, etc. You can see a defined list in the [AWS prerequisites](https://docs.openshift.com/rosa/rosa_planning/rosa-sts-aws-prereqs.html#rosa-aws-policy-provisioned_rosa-sts-aws-prereqs).

### I see there are two "kinds" of ROSA clusters. One uses an IAM user with admin permissions and the other AWS STS. Which should I choose?
AWS STS. These aren't "kinds" but rather credential methods. Basically, "how do you grant Red Hat the permissions needed in order to perform the required actions in your AWS account?". The roadmap forward is focused on STS, and the IAM user method will eventually be deprecated. This better aligns with principles of least privilege and is much better aligned to secure practices in cloud service resource management. Please see the section "[ROSA with STS Explained](15-sts_explained.md)" for a detailed explanation.

### I’m seeing a number of permission or failure errors related to prerequisite tasks or cluster creation, what might be the problem?
Please check for a newer version of the ROSA CLI. Every release of the ROSA CLI lands in two places: [Github](https://github.com/openshift/rosa/releases) and the [Red Hat signed binary releases](https://www.openshift.com/products/rosa/download).

### What are the available storage options?
Please refer to the [storage](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-storage_rosa-service-definition) section of the service definition.

### What options are available to use shared storage in containers?
AWS EFS (Using AWS EFS CSI Driver, OpenShift includes the CSI driver out of the box in 4.10.). See [Setting up AWS EFS for Red Hat OpenShift Service on AWS](https://docs.openshift.com/rosa/storage/persistent_storage/osd-persistent-storage-aws.html).

### Can I deploy into an already existing VPC and choose the specific subnets?
Yes.  At install time you are able to select whether you’d like to deploy to an existing VPC and then choose that VPC.  You will then be able to select the desired subnets and also provide a valid CIDR range (encompassing the subnets) the installer will handle using those subnets. Please see the [VPC](https://docs.openshift.com/rosa/rosa_planning/rosa-sts-aws-prereqs.html#rosa-vpc_rosa-sts-aws-prereqs) section in the documentation for further details.

### Which network plugin is used in Red Hat OpenShift Service on AWS?
Red Hat OpenShift Service on AWS uses the default OpenShift SDN network provider configured to NetworkPolicy mode. OVN-Kubernetes is on our roadmap.

### Is cross-namespace networking supported?
Cluster admins in ROSA can customize cross-namespace networking (including denying it) on a per project basis using NetworkPolicy objects. Refer to [Configuring multitenant isolation with network policy](https://docs.openshift.com/container-platform/4.10/networking/network_policy/multitenant-network-policy.html) on how to configure.

### Can more than one ROSA cluster be set up in one VPC?
Yes, ROSA allows multiple clusters to share the same VPC. Essentially, the number of clusters would be limited by what AWS resource quota remains, as well as any chosen CIDR ranges that must not overlap. See [CIDR Range Definitions](https://docs.openshift.com/rosa/networking/cidr-range-definitions.html) for more information.

### Can I use Prometheus/Grafana to monitor containers and manage capacity?
Yes, using OpenShift User Workload Monitoring. This is a check-box option in OpenShift Cluster Manager (console.redhat.com/openshift)

### Can I see audit logs output from the cluster control-plane?
If the Cluster Logging Operator Add-on has been added to the cluster then audit logs are available through CloudWatch.  If it has not, then a support request would allow you to request some audit logs. Small targeted and time-boxed logs can be requested for export and sent to a customer. The selection of audit logs available are at the discretion of SRE in the category of platform security and compliance. Requests for exports of a cluster’s entirety of logs will be rejected.

### Can I use an AWS Permissions Boundary around the policies for my cluster?
Yes, using AWS Permissions Boundary is supported.

### Do ROSA worker nodes share the same AMI as other OpenShift products?
ROSA worker nodes use a different AMI from OSD and OCP. Control Plane and Infra node AMIs are common across products in the same version.

### Are backups taken for clusters?
Only non-STS clusters have SRE managed backups at this time, which means that ROSA STS clusters don’t have backups. You can also see our [backup policy](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-backup-policy_rosa-service-definition). It is imperative for users to have their own backup policies for applications and data.

### Is ROSA GDPR Compliant?
Yes: [https://www.redhat.com/en/gdpr](https://www.redhat.com/en/gdpr)

### Does the ROSA CLI accept Multi-region KMS keys for EBS encryption?
Not at this time. This feature is in our backlog. Though we do accept single region KMS keys for EBS Encryption as long as it is defined at cluster creation time.

### Can I define a custom domain and certificate for my applications?
Yes. See [Configuring custom domains for applications](https://docs.openshift.com/rosa/applications/deployments/osd-config-custom-domains-applications.html) for more information.

### How are the ROSA domain certificates managed?
Red Hat infrastructure (Hive) manages certificate rotation for default application ingress (apps.*.openshiftapps.com)

### What features are upcoming for ROSA?
The current ROSA roadmap can be seen at: [https://red.ht/rosa-roadmap](https://red.ht/rosa-roadmap)

### What kind of instances are supported for worker nodes?
See [AWS compute types](https://docs.openshift.com/rosa/rosa_architecture/rosa_policy_service_definition/rosa-service-definition.html#rosa-sdpolicy-aws-compute-types_rosa-service-definition) in the service definition for the up to date list of supported instance types.  Additionally, spot instances are supported.

### Does ROSA support an air-gapped, disconnected environment where the ROSA cluster does not have internet access?  
No, the ROSA cluster must have egress to the internet to access our registry, S3, send metrics etc. The service requires a number of [egress endpoints](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-aws-prereqs.html#osd-aws-privatelink-firewall-prerequisites). Ingress can be limited to PrivateLink (for Red Hat SRE) and VPN or similar for customer access.

### Is node autoscaling available?
Yes. Autoscaling allows you to automatically adjust the size of the cluster based on the current workload. See [About autoscaling nodes on a cluster](https://docs.openshift.com/rosa/rosa_cluster_admin/rosa_nodes/rosa-nodes-about-autoscaling-nodes.html) in the documentation for more details.

### What is the maximum number of worker nodes that a cluster can support?
The maximum number of worker nodes is 180 per ROSA cluster.  See here for [limits and scalability](https://docs.openshift.com/rosa/rosa_planning/rosa-limits-scalability.html) considerations and more details on node counts.
