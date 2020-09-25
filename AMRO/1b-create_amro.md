## Creating an Amazon Red Hat OpenShift Cluster

This guide is going to take a direct and guided approach to creating an Amazon Red Hat OpenShift cluster.  It is based on the following two documents:
- [Getting started with Amazon Red Hat OpenShift](https://docs.openshift.com/moa/4/getting_started_moa/creating-first-moa-cluster.html)
- [MOA Command-line tool](https://github.com/openshift/moactl)

#### 1. Select the AWS account that you want to use
If you are using AWS organizations and you need to have a Service Control Policy (SCP) applied to the AWS account you plan to use, see the [Red Hat Requirements for Customer Cloud Subscriptions](https://www.openshift.com/dedicated/ccs#scp) for details on the minimum required SCP.

You will need the following pieces of information from your account:  

- AWS Access Key ID
- AWS Secret Access Key

#### 2. Install the AWS CLI

Skip this step if it is already installed and configured.

Follow the AWS documentation on how to install the [aws-cli](https://aws.amazon.com/cli/) for your operating system.

![CLI Tools](images/1b-aws-cli.png)

Then make sure to configure the `aws` cli to connect with your account.  The simplest way is to run the following

`aws configure`

This will ask you for 4 pieces of information (enter the information relevant to your account, below is a sample).

````
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: table
````

See the [AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config) for further detials.

Verify that the `aws` CLI is correctly installed and configured by running the following command:

`aws ec2 describe-regions`

If correctly configured you will see a response like:

```
---------------------------------------------------------------------------------
|                                DescribeRegions                                |
+-------------------------------------------------------------------------------+
||                                   Regions                                   ||
|+-----------------------------------+-----------------------+-----------------+|
||             Endpoint              |      OptInStatus      |   RegionName    ||
|+-----------------------------------+-----------------------+-----------------+|
||  ec2.eu-north-1.amazonaws.com     |  opt-in-not-required  |  eu-north-1     ||
||  ec2.ap-south-1.amazonaws.com     |  opt-in-not-required  |  ap-south-1     ||
||  ec2.eu-west-3.amazonaws.com      |  opt-in-not-required  |  eu-west-3      ||
||  ec2.eu-west-2.amazonaws.com      |  opt-in-not-required  |  eu-west-2      ||
||  ec2.eu-west-1.amazonaws.com      |  opt-in-not-required  |  eu-west-1      ||
||  ec2.ap-northeast-2.amazonaws.com |  opt-in-not-required  |  ap-northeast-2 ||
||  ec2.ap-northeast-1.amazonaws.com |  opt-in-not-required  |  ap-northeast-1 ||
||  ec2.sa-east-1.amazonaws.com      |  opt-in-not-required  |  sa-east-1      ||
||  ec2.ca-central-1.amazonaws.com   |  opt-in-not-required  |  ca-central-1   ||
||  ec2.ap-southeast-1.amazonaws.com |  opt-in-not-required  |  ap-southeast-1 ||
||  ec2.ap-southeast-2.amazonaws.com |  opt-in-not-required  |  ap-southeast-2 ||
||  ec2.eu-central-1.amazonaws.com   |  opt-in-not-required  |  eu-central-1   ||
||  ec2.us-east-1.amazonaws.com      |  opt-in-not-required  |  us-east-1      ||
||  ec2.us-east-2.amazonaws.com      |  opt-in-not-required  |  us-east-2      ||
||  ec2.us-west-1.amazonaws.com      |  opt-in-not-required  |  us-west-1      ||
||  ec2.us-west-2.amazonaws.com      |  opt-in-not-required  |  us-west-2      ||
|+-----------------------------------+-----------------------+-----------------+|
```
#### 3. Install `moactl` which is the Amazon Red Hat OpenShift CLI

Download the [latest release](https://github.com/openshift/moactl/releases/latest) of `moactl` for your operating system.

Rename the executable file to "**moactl**".

Add `moactl` to your path.

Verify the installation by running:

`moactl`

You will get an output like:

```
Command line tool for MOA.

Usage:
  moactl [command]

Available Commands:
  completion  Generates bash completion scripts
  create      Create a resource from stdin
  delete      Delete a specific resource
  describe    Show details of a specific resource
  edit        Edit a specific resource
  help        Help about any command
  init        Applies templates to support Managed OpenShift on AWS clusters
  list        List all resources of a specific type
  login       Log in to your Red Hat account
  logout      Log out
  logs        Show logs of a specific resource
  verify      Verify resources are configured correctly for cluster install
  version     Prints the version of the tool

Flags:
      --debug     Enable debug mode.
  -h, --help      help for moactl
  -v, --v Level   log level for V logs

Use "moactl [command] --help" for more information about a command.
```

> **NOTE:** If you are on a MAC or Linux machine you might need to make `moactl` executable by running `chmod +x moactl`

Run the following command to verify that your AWS account has the necessary permissions:

`moactl verify permissions`

You will see an output similar to:

```
I: Validating SCP policies...
I: AWS SCP policies ok
```

Verify that your account has the necessary quota to deploy an Amazon Red Hat OpenShift cluster:

`moactl verify quota --region=<enter region>`

Example
```
$ moactl verify quota --region=us-west-2
I: Validating AWS quota...
I: AWS quota ok
```

> **NOTE:** If you need to increase your quota, navigate to your AWS console, and request a quota increase for the service that failed.

#### 4. Prepare your AWS account for cluster deployment.

Run the following command to log into your Red Hat account:

`moactl login`

You will see:
```
To login to your Red Hat account, get an offline access token at https://cloud.redhat.com/openshift/token/moa
? Copy the token and paste it here: <my-offline-access-token>
```

Go to the URL provided, log into your Red Hat account if needed, copy the token and then paste it in the CLI. 

![OCM Token](images/1b-ocm-token.png)

If successful, you will see a response like:
```
I: Logged in as 'rh-amro-user' on 'https://api.openshift.com'
```

Run the following command to verify your Red Hat and AWS credentials are setup correctly. Check that your AWS Account ID, Default Region and ARN match what you expect.

`moactl whoami`

You will see a response like:
```
AWS Account ID:               000000000000
AWS Default Region:           us-east-2
AWS ARN:                      arn:aws:iam::000000000000:user/aws-user
OCM API:                      https://api.openshift.com
OCM Account ID:               1DzGIdIhqEWyt8UUXQhSoWaaaaa
OCM Account Name:             Your Name
OCM Account Username:         you@domain.com
OCM Account Email:            you@domain.com
OCM Organization ID:          1HopHfA2hcmhup5gCr2uH5aaaaa
OCM Organization Name:        Red Hat
OCM Organization External ID: 0000000
```

If all looks accurate then run the following command to initialize your AWS account.  This step runs a CloudFormation template that prepares your AWS account for cluster deployment and management. This step typically takes 1-2 minutes to complete.

`moactl init`

You will see:

```
I: Logged in as 'rh-amro-user' on 'https://api.openshift.com'
I: Validating AWS credentials...
I: AWS credentials are valid!
I: Validating SCP policies...
I: AWS SCP policies ok
I: Validating AWS quota...
I: AWS quota ok
I: Ensuring cluster administrator user 'osdCcsAdmin'...
I: Admin user 'osdCcsAdmin' created successfuly!
I: Verifying whether OpenShift command-line tool is available...
E: OpenShift command-line tool is not installed.
Go to https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/ to download the OpenShift client and add it to your PATH.
```

#### 5. Create the cluster

To create a cluster with all default values simply enter:

`moactl create cluster --cluster-name=<enter a cluster name>`

You will then see a response like:

```
I: Creating cluster with identifier '1fthat0id8pl5sXXXXX2e8sistgd9lb3' and name 'amroworkshop-cluster'
I: To view list of clusters and their status, run 'moactl list clusters'
I: Cluster 'amroworkshop-cluster' has been created.
I: Once the cluster is installed you will need to add an Identity Provider before you can login into the cluster. See 'moactl create idp --help' for more information.
I: To determine when your cluster is Ready, run 'moactl describe cluster -c amroworkshop-cluster'.
I: To watch your cluster installation logs, run 'moactl logs install -c amroworkshop-cluster --watch'.
Name:          amroworkshop-cluster
ID:            1fthat0id8pl5sXXXXX2e8sistgd9lb3
External ID:   
AWS Account:   000000000000
API URL:       
Console URL:   
Nodes:         Master: 3, Infra: 3, Compute: 4
Region:        us-west-2
State:         pending (Preparing account)
Channel Group: stable
Created:       Sep 25 2020 03:26:45 UTC
```

The default settings are as follows:

- The AWS region you have configured for the AWS CLI
- The most recent version of OpenShift available to moactl
- A single availability zone
- Public cluster (Public API)
- Master nodes: 3
- Infra nodes: 3
- Compute nodes: 4 (m5.xlarge instance types)

You can also create the cluster in interactive mode where you can define each parameter by running the command as follows:

`moactl create cluster --interactive`

You will then be prompted with values to enter for each parameter.

#### 6. Check the status of your cluster

Run the following to see the status:

`moactl describe cluster -c amroworkshop-cluster`

You will see the following:
```
Name:          amroworkshop-cluster
ID:            1fthat0id8pl5sXXXXX2e8sistgd9lb3
External ID:   7edb1066-XXXX-XXXX-XXXX-65350329339e
AWS Account:   000000000000
API URL:       
Console URL:   
Nodes:         Master: 3, Infra: 3, Compute: 4
Region:        us-west-2
State:         installing 
Channel Group: stable
Created:       Sep 25 2020 03:26:45 UTC
```

Once the "State" is **ready** then the cluster is ready to use.

#### 7. Accessing your new Amazon Red Hat OpenShift Cluster
To log in to your cluster, you must configure an Identity Provider (IdP). This procedure uses GitHub as an example IDP. To view other supported IdPs, run `moactl create idp --help`.

You can see the documentation here for [Registering a GitHub application](https://docs.openshift.com/dedicated/4/authentication/identity_providers/configuring-github-identity-provider.html#identity-provider-registering-github_configuring-github-identity-provider)

We will use GitHub as our IdP since it is a quick way to get started.

> **NOTE:** If you are familiar with GitHub and Organizations and already have an Organization you want to use you can skip this section (next 5 steps)

Access your GitHub account then go to your Organizations via this link: [https://github.com/settings/organizations](https://github.com/settings/organizations)

Click on the "New Organization" button on the top right.

Choose a plan or the "free" plan.

Give the Organization a name (I used "AMRO-Auth" for this example) and an email address (you can use yours).

Skip the next step of adding other users since you will automatically be part of this. Click through until the Organization is created.

Once you have the organization you want to use go back to your terminal and run the following command to set up the GitHub IdP for your cluster:

`moactl create idp --cluster=<cluster name> --interactive`

Select **github**.

Give it a name or take the default.  This is the name of the IdP that users will have to click on in order to access the cluster from the web console. ("GitHub-Auth" in this example).

For "Restrict to members of" select **organizations**.

Then enter the name of the organization you want to use (or the one we just created) ("AMRO-Auth" in this example).

The CLI will then give you a link to open.  

```
$ moactl create idp --cluster=<cluster name> --interactive
I: Interactive mode enabled.
Any optional fields can be left empty and a default will be selected.
? Type of identity provider: github
? Identity provider name: GitHub-Auth
? Restrict to members of: organizations
? GitHub organizations: AMRO-Auth
? To use GitHub as an identity provider, you must first register the application:
  - Open the following URL:
    https://github.com/organizations/AMRO-Auth/settings/applications/new?oauth_application%5Bcallback_url%5D=https%3A%2F%2Foauth-openshift.apps.amroworkshop-cluster.a0b1.p1.openshiftapps.com%2Foauth2callback%2FGitHub-Auth&oauth_application%5Bname%5D=amroworkshop-cluster&oauth_application%5Burl%5D=https%3A%2F%2Fconsole-openshift-console.apps.amroworkshop-cluster.a0b1.p1.openshiftapps.com
  - Click on 'Register application'
```

Open that link in a new tab.  It will prefill all the fields needed to register a new OAuth application.  Click the green **Register application** button.

In the following page it will give you a **Client ID** and a **Client Secret**.

Copy the **Client ID**.  Go back to the CLI and paste it and press enter.

Do the same for the **Client Secret**.

Press enter for "Enterprise Hostname" as it is optional.

Select **Claim** for "Mapping Method".

The IDP can take 1-2 minutes to be configured within your cluster.

Run the following command to verify that your IDP has been configured correctly:

`moactl list idps --cluster <cluster name>`

You will see your IdP listed:

```
NAME           TYPE      AUTH URL
GitHub-Auth    GitHub    https://oauth-openshift.apps.amroworkshop-cluster.a0b1.p1.openshiftapps.com/oauth2callback/GitHub-Auth
```

To access the cluster enter the console URL into a new browser tab.  This URL was shown at the end of the IdP command or you can run:

`moactl describe cluster -c ok-amroworkshop-0924 | grep console`

![Login](images/1b-login-idp.png)

Click on our IdP name in this case **GitHub-Auth**.

Then proceed to login as you would to your GitHub account and you should see the OpenShift Web Console.

#### 8. Login to your cluster with the `oc` CLI

Once logged in, click on the dropdown arrow next to your name in the top-right and select *Copy Login Command*.

![CLI Login](images/4-cli-login.png)

A new tab will open and select the authentication method you are using (in our case it's *GitHub-Auth*).

Click *Display Token*.

Copy the command under where it says "Log in with this token". Then go to your terminal and paste that command and press enter.  You will see a similar confirmation message if you successfully logged in.

```shell
$ oc login --token=mNmmpfqlCDRfwjjNW1vKPkXXXXXXXXXXXXXXXXXXX --server=https://api.amroworkshop-cluster.a0b1.p1.openshiftapps.com:6443
Logged into "https://api.amroworkshop-cluster.a0b1.p1.openshiftapps.com:6443" as "0kashi" using the token provided.

You don't have any projects. You can try to create a new project, by running

    oc new-project <projectname>

```


Run a simple oc command to verify everything is setup properly and you are logged in.
```
$ oc version
Client Version: 4.5.2
Server Version: 4.5.11
Kubernetes Version: v1.18
```

Congratulations! You have deployed and configured your very own OpenShift cluster!