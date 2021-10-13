There are two ways to deploy a cluster with STS mode. One is automatic, which is quicker and will do the manual work for you. The other is manual, which will require you to execute some extra commands, but will allow you to inspect the roles and policies being created. This workshop will document both options. If you just want to get your cluster created quickly, please use the automatic section, but if you would rather explore the objects being created, then feel free to use manual. This is achieved via the `--mode` flag in the relevant commands.  

Valid options for `--mode` are:

- **manual:** Role and Policy documents will be created and saved in the current directory. You will need to manually run the commands that are provided  as the next step.  This will allow you to review the policy and roles before creating them.
- **auto:** Roles and policies will be created and applied automatically using the current AWS account, instead of having to manually run each command.

>**Note:** If no mode is selected the **auto** mode is the default.

For the purposes of this workshop either method will work. Though we do recommend the `auto` method as that is quicker and has less steps.

## Deployment flow
The overall flow that we will follow boils down to 4 (but really 3) steps.

1. `rosa create account-roles` - This is executed only <u>once</u> per account, per OpenShift version.  Once created this does *not* need to be executed again for more clusters of the same version.
1. `rosa create cluster`
1. `rosa create operator-roles`
1. `rosa create oidc-provider`

For each succeeding cluster in the same account for the same version, only steps 2-4 are needed.

## Automatic Mode
As mentioned above if you want the ROSA CLI to automate the creation of the roles and policies to create your cluster quickly, then use this method.

### Create account roles
If this is the <u>first time</u> you are deploying ROSA in this account and have <u>not yet created the account roles</u> for the OpenShift version you are deploying, then enable ROSA to create JSON files for account-wide roles and policies, including Operator policies. 

Run the following command (to see all available OpenShift versions run: `rosa list versions`):

    rosa create account-roles --mode auto --version 4.8 --yes

You will see an output like the following:

    I: Creating roles using 'arn:aws:iam::000000000000:user/rosa-user'
    I: Created role 'ManagedOpenShift-ControlPlane-Role' with ARN 'arn:aws:iam::000000000000:role/ManagedOpenShift-ControlPlane-Role'
    I: Created role 'ManagedOpenShift-Worker-Role' with ARN 'arn:aws:iam::000000000000:role/ManagedOpenShift-Worker-Role'
    I: Created role 'ManagedOpenShift-Support-Role' with ARN 'arn:aws:iam::000000000000:role/ManagedOpenShift-Support-Role'
    I: Created role 'ManagedOpenShift-Installer-Role' with ARN 'arn:aws:iam::000000000000:role/ManagedOpenShift-Installer-Role'
    I: Created policy with ARN 'arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-machine-api-aws-cloud-credentials'
    I: Created policy with ARN 'arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-cloud-credential-operator-cloud-crede'
    I: Created policy with ARN 'arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-image-registry-installer-cloud-creden'
    I: Created policy with ARN 'arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-ingress-operator-cloud-credentials'
    I: Created policy with ARN 'arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-cluster-csi-drivers-ebs-cloud-credent'
    I: To create a cluster with these roles, run the following command:
    rosa create cluster --sts


### Create the cluster
Run the following command to create a cluster with all the default options 

    rosa create cluster --cluster-name <cluster name> --sts

>**Note:** If you want to see all available options for your cluster use the `--help` flag or for interactive mode you can use `--interactive`.

For example: 

    $ rosa create cluster --cluster-name my-rosa-cluster --sts

You should see a response like the following:

    I: Creating cluster 'my-rosa-cluster'
    I: To view a list of clusters and their status, run 'rosa list clusters'
    I: Cluster 'my-rosa-cluster' has been created.
    I: Once the cluster is installed you will need to add an Identity Provider before you can login into the cluster. See 'rosa create idp --help' for more information.
    I: To determine when your cluster is Ready, run 'rosa describe cluster -c my-rosa-cluster'.
    I: To watch your cluster installation logs, run 'rosa logs install -c my-rosa-cluster --watch'.
    Name:                       my-rosa-cluster
    ID:                         1mlhulb3bo0l54ojd0ji000000000000
    External ID:                
    OpenShift Version:          
    Channel Group:              stable
    DNS:                        my-rosa-cluster.ibhp.p1.openshiftapps.com
    AWS Account:                000000000000
    API URL:                    
    Console URL:                
    Region:                     us-west-2
    Multi-AZ:                   false
    Nodes:
     - Master:                  3
     - Infra:                   2
     - Compute:                 2
    Network:
     - Service CIDR:            172.30.0.0/16
     - Machine CIDR:            10.0.0.0/16
     - Pod CIDR:                10.128.0.0/14
     - Host Prefix:             /23
    STS Role ARN:               arn:aws:iam::000000000000:role/ManagedOpenShift-Installer-Role
    Support Role ARN:           arn:aws:iam::000000000000:role/ManagedOpenShift-Support-Role
    Instance IAM Roles:
     - Master:                  arn:aws:iam::000000000000:role/ManagedOpenShift-ControlPlane-Role
     - Worker:                  arn:aws:iam::000000000000:role/ManagedOpenShift-Worker-Role
    Operator IAM Roles:
     - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-image-registry-installer-cloud-credentials
     - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-ingress-operator-cloud-credentials
     - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-cluster-csi-drivers-ebs-cloud-credentials
     - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-machine-api-aws-cloud-credentials
     - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-cloud-credential-operator-cloud-credential-oper
    State:                      waiting (Waiting for OIDC configuration)
    Private:                    No
    Created:                    Oct 12 2021 20:28:09 UTC
    Details Page:               https://console.redhat.com/openshift/details/s/1wupmiQy45xr1nN000000000000
    OIDC Endpoint URL:          https://rh-oidc.s3.us-east-1.amazonaws.com/1mlhulb3bo0l54ojd0ji000000000000


The default settings are as follows:

* 3 Master Nodes, 2 Infra Nodes, 2 Worker Nodes
    * See [here](https://docs.openshift.com/rosa/rosa_getting_started_sts/rosa-sts-aws-prereqs.html#rosa-ec2-instances_rosa-sts-aws-prerequisites) for more details.
* Region: As configured for the AWS CLI
* Networking IP ranges:
    * Machine CIDR: 10.0.0.0/16 
    * Service CIDR: 172.30.0.0/16
    * Pod CIDR: 10.128.0.0/14
* The most recent version of OpenShift available to `rosa`
* A single availability zone
* Public cluster (Public API)

> **NOTE:** The state will stay in “waiting” <u>until the next two steps below are completed</u>.

### Create operator roles
These roles need to be created <u>once per cluster</u>. To create the roles run the following:

    rosa create operator-roles --mode auto --cluster <cluster-name> --yes

### Create the OIDC provider
Run the following to create the OIDC provider:

    rosa create oidc-provider --mode auto --cluster <cluster-name> --yes

### Check installation status
1. You can run the following command to check the detailed status of the cluster

        rosa describe cluster --cluster <cluster-name>

    or you can also run the following for an abridged view of the status

        rosa list clusters

    You should notice the state change from “waiting” to “installing” to "ready". This will take about 40 minutes to run.
    
1. Once the state has changed to “ready” your cluster is now installed.  


## Manual Mode
As mentioned above if you want to be able to review the roles and policies created before applying them, you can use this manual method. Though it will require running a few extra commands to create the roles and policies.

In this version we will also make use of the `--interactive` mode so that it will be easier to follow along, though feel free to use the default cluster creation command above if you'd like.  See [here](https://docs.openshift.com/rosa/rosa_getting_started_sts/rosa_creating_a_cluster_with_sts/rosa-sts-interactive-mode-reference.html) for a description of the fields in this section.

### Create account roles
1. If this is the <u>first time</u> you are deploying ROSA in this account and have <u>not yet created the account roles</u> for the OpenShift version you are deploying, then enable ROSA to create JSON files for account-wide roles and policies, including Operator policies. This command will create the needed JSON files for the required roles and policies for your account in the current directory.  This will also output the `aws` commands you need to run in order to create these objects.

    Run the following command (to see all available OpenShift versions run: `rosa list versions`):

        rosa create account-roles --mode manual --version 4.8

    You will see an output like the following:

        I: All policy files saved to the current directory
        I: Run the following commands to create the account roles and policies:

        aws iam create-role \
        --role-name ManagedOpenShift-Worker-Role \
        --assume-role-policy-document file://sts_instance_worker_trust_policy.json \
        --tags Key=rosa_openshift_version,Value=4.8 Key=rosa_role_prefix,Value=ManagedOpenShift Key=rosa_role_type,Value=instance_worker

        aws iam put-role-policy \
        --role-name ManagedOpenShift-Worker-Role \
        --policy-name ManagedOpenShift-Worker-Role-Policy \
        --policy-document file://sts_instance_worker_permission_policy.json

        …

2. If you look at the contents of your current directory you will see the new files created.  We will be using the `aws` CLI to create each of these objects as displayed above.

        $ ls
        openshift_cloud_credential_operator_cloud_credential_operator_iam_ro_creds_policy.json  sts_instance_controlplane_permission_policy.json
        openshift_cluster_csi_drivers_ebs_cloud_credentials_policy.json             sts_instance_controlplane_trust_policy.json
        openshift_image_registry_installer_cloud_credentials_policy.json            sts_instance_worker_permission_policy.json
        openshift_ingress_operator_cloud_credentials_policy.json                    sts_instance_worker_trust_policy.json
        openshift_machine_api_aws_cloud_credentials_policy.json                     sts_support_permission_policy.json
        sts_installer_permission_policy.json                                        sts_support_trust_policy.json
        sts_installer_trust_policy.json


3. (Optional) If you'd like, you may open the files to review what you will be creating. For example if we open the `sts_installer_permission_policy.json` we can see:

        $ cat sts_installer_permission_policy.json
        {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:AllocateAddress",
                "ec2:AssociateAddress",
                "ec2:AssociateDhcpOptions",
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AttachNetworkInterface",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                [...]

    You can also see these contents in the [documentation](https://docs.openshift.com/rosa/rosa_getting_started_sts/rosa_creating_a_cluster_with_sts/rosa-sts-about-iam-resources.html).

4. Execute the `aws` commands presented from the above step.  You can copy and paste as long as you are in the same directory as the json files created.

### Create the cluster

5. After all the `aws` commands have been executed successfully run the following command to begin the ROSA cluster creation in interactive mode:

        rosa create cluster --interactive --sts

    See [here](https://docs.openshift.com/rosa/rosa_getting_started_sts/rosa_creating_a_cluster_with_sts/rosa-sts-interactive-mode-reference.html) for a description of the fields below.

    For the purpose of this tutorial please select the following values.  Please leave the default values for any of the ARNs:

    Cluster name: **my-rosa-cluster** <br>
    OpenShift version: **&lt;choose version&gt;** <br>
    External ID (optional): **&lt;leave blank&gt;**<br>
    Operator roles prefix: **&lt;accept default&gt;** <br>
    Multiple availability zones: **No** <br>
    AWS region: **&lt;choose region&gt;** <br>
    PrivateLink cluster: **No** <br>
    Install into an existing VPC: **No** <br>
    Enable Customer Managed key: **No** <br>
    Compute nodes instance type: **m5.xlarge** <br>
    Enable autoscaling: **No** <br>
    Compute nodes: **2** <br>
    Machine CIDR: **&lt;accept default&gt;** <br>
    Service CIDR: **&lt;accept default&gt;** <br>
    Pod CIDR: **&lt;accept default&gt;** <br>
    Host prefix: **&lt;accept default&gt;** <br>
    Disable Workload monitoring: **No** <br>

    You will see the following response along with the command to create this cluster in the future so that you don’t need to go through the interactive mode again.

        I: Creating cluster 'my-rosa-cluster'
        I: To create this cluster again in the future, you can run:
        rosa create cluster --cluster-name my-rosa-cluster --role-arn arn:aws:iam::000000000000:role/ManagedOpenShift-Installer-Role --support-role-arn arn:aws:iam::000000000000:role/ManagedOpenShift-Support-Role --master-iam-role arn:aws:iam::000000000000:role/ManagedOpenShift-ControlPlane-Role --worker-iam-role arn:aws:iam::000000000000:role/ManagedOpenShift-Worker-Role --operator-roles-prefix my-rosa-cluster --region us-west-2 --version 4.8.13 --compute-nodes 2 --machine-cidr 10.0.0.0/16 --service-cidr 172.30.0.0/16 --pod-cidr 10.128.0.0/14 --host-prefix 23
        I: To view a list of clusters and their status, run 'rosa list clusters'
        I: Cluster 'my-rosa-cluster' has been created.
        I: Once the cluster is installed you will need to add an Identity Provider before you can login into the cluster. See 'rosa create idp --help' for more information.
        I: To determine when your cluster is Ready, run 'rosa describe cluster -c my-rosa-cluster'.
        I: To watch your cluster installation logs, run 'rosa logs install -c my-rosa-cluster --watch'.
        Name:                       my-rosa-cluster
        ID:                         1mkesci269png3tck000000000000000
        External ID:                
        OpenShift Version:          
        Channel Group:              stable
        DNS:                        my-rosa-cluster.4h5l.p1.openshiftapps.com
        AWS Account:                000000000000
        API URL:                    
        Console URL:                
        Region:                     us-west-2
        Multi-AZ:                   false
        Nodes:
         - Master:                  3
         - Infra:                   2
         - Compute:                 2
        Network:
         - Service CIDR:            172.30.0.0/16
         - Machine CIDR:            10.0.0.0/16
         - Pod CIDR:                10.128.0.0/14
         - Host Prefix:             /23
        STS Role ARN:               arn:aws:iam::000000000000:role/ManagedOpenShift-Installer-Role
        Support Role ARN:           arn:aws:iam::000000000000:role/ManagedOpenShift-Support-Role
        Instance IAM Roles:
         - Master:                  arn:aws:iam::000000000000:role/ManagedOpenShift-ControlPlane-Role
         - Worker:                  arn:aws:iam::000000000000:role/ManagedOpenShift-Worker-Role
        Operator IAM Roles:
         - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-image-registry-installer-cloud-credentials
         - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-ingress-operator-cloud-credentials
         - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-cluster-csi-drivers-ebs-cloud-credentials
         - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-machine-api-aws-cloud-credentials
         - arn:aws:iam::000000000000:role/my-rosa-cluster-openshift-cloud-credential-operator-cloud-credential-ope
        State:                      waiting (Waiting for OIDC configuration)
        Private:                    No
        Created:                    Oct 12 2021 04:33:58 UTC
        Details Page:               https://console.redhat.com/openshift/details/s/1mkesci269png3tck0000000000000
        OIDC Endpoint URL:          https://rh-oidc.s3.us-east-1.amazonaws.com/1mkesci269png3tckknhh00000000000

> **NOTE:** The state will stay in “waiting” <u>until the next two steps below are completed</u>.

### Create operator roles
These roles need to be created <u>once per cluster</u>. To create the roles run the following:

    rosa create operator-roles --mode manual --cluster <cluster-name>

You will see an output like the following with all the commands that need to be executed.

    I: Run the following commands to create the operator roles:

    aws iam create-role \
        --role-name my-rosa-cluster-openshift-image-registry-installer-cloud-credentials \
        --assume-role-policy-document file://operator_image_registry_installer_cloud_credentials_policy.json \
        --tags Key=rosa_cluster_id,Value=1mkesci269png3tck000000000000000 Key=rosa_openshift_version,Value=4.8 Key=rosa_role_prefix,Value= Key=operator_namespace,Value=openshift-image-registry Key=operator_name,Value=installer-cloud-credentials

    aws iam attach-role-policy \
        --role-name my-rosa-cluster-openshift-image-registry-installer-cloud-credentials \
        --policy-arn arn:aws:iam::000000000000:policy/ManagedOpenShift-openshift-image-registry-installer-cloud-creden
    [...]


Run each of the `aws` commands presented.

### Create the OIDC provider
Run the following to create the OIDC provider:

    rosa create oidc-provider --mode manual --cluster <cluster-name>

This will display the `aws` commands that you need to run. Run the commands like the below sample:

    I: Run the following commands to create the OIDC provider:

    $ aws iam create-open-id-connect-provider \
    --url https://rh-oidc.s3.us-east-1.amazonaws.com/1mkesci269png3tckknhh0rfs2da5fj9 \
    --client-id-list openshift sts.amazonaws.com \
    --thumbprint-list a9d53002e97e00e043244f3d170d000000000000

    $ aws iam create-open-id-connect-provider \
    --url https://rh-oidc.s3.us-east-1.amazonaws.com/1mkesci269png3tckknhh0rfs2da5fj9 \
    --client-id-list openshift sts.amazonaws.com \
    --thumbprint-list a9d53002e97e00e043244f3d170d000000000000

Your cluster will now continue the installation process.  

### Check installation status
1. You can run the following command to check the detailed status of the cluster

        rosa describe cluster --cluster <cluster-name>

    or you can also run the following for an abridged view of the status

        rosa list clusters

    You should notice the state change from “waiting” to “installing” to "ready". This will take about 40 minutes to run.
    
1. Once the state has changed to “ready” your cluster is now installed.  

## Obtain the Console URL
To get the console URL run:

    rosa describe cluster -c <cluster-name> | grep Console

The cluster has now been successfully deployed. In the next step we will create an admin user to be able to use the cluster immediately.


*[ROSA]: Red Hat OpenShift Service on AWS
*[STS]: AWS Secure Token Service