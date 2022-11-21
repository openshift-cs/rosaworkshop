
## Amazon Controller for Kubernetes (ACK)

The [Amazon Controller for Kubernetes](https://aws-controllers-k8s.github.io/community/docs/community/overview/) (ACK) allows you to create and use AWS services directly from
Kubernetes. You can deploy your applications, including any required AWS services directly within the Kubernetes framework using a familiar structure to declaratively define and create AWS services like S3 buckets or RDS databases.

In order to illustrate the use of the ACK on ROSA, we will walk through a simple example of creating an S3 bucket, integrating that with OSToy, upload a file to it, and view the file in our application. Interestingly, this part of the lab will also touch upon the concept of granting your applications access to AWS services (though that is worthy of a workshop of its own).

### Section overview

To make the process clearer, here is an overview of the procedure we are going to follow. There are two main "parts".

1. **ACK Controller for the cluster** - This allows you to create/delete buckets in the S3 service through the use of a Kubernetes Custom Resource for the bucket.
    1. Install the controller (in our case an Operator)
    1. Create the needed service account and AWS IAM role for the ACK controller
    1. Associate AWS IAM role with the service account
1. **Application access** - Granting access to our application container/pod to access our S3 bucket.
    1. Create needed service account and AWS IAM role for the ACK controller
    1. Associate AWS IAM role with the service account
    1. Update application to use the service account

### Install an ACK controller

There are a few ways to do this, but we will use an Operator to make it easy. The Operator installation will also create an `ack-system` namespace and a service account `ack-s3-controller` for you.

1. Login to your OpenShift cluster's web console (if you aren't already).
1. On the left menu, click on "Operators > OperatorHub".
1. In the filter box enter "S3" and select the "AWS Controller for Kubernetes - Amazon S3"

    ![create](images/13-ack-operator.png)

1. If you get a pop-up saying that it is a community operator, just click "Continue".
1. Click "Install" in the top left.
1. Ensure that "All namespaces on the cluster" is selected for "Installation mode".
1. Ensure that "ack-system" is selected for "Installed Namespace".
1. Under "Update approval" ensure that "Manual" is selected.

    !!! warning
        Make sure to select "Manual Mode" so that changes to the Service Account do not get overwritten by an automatic operator update.

1. Click "Install" on the bottom. The settings should look like the below image.

    ![create_s3_controller](images/13-ack-install.png)

1. Click "Approve".
1. You will see that installation is taking place. The installation won't complete until the next step is finished. So please proceed.

### Set up access for the controller

To deploy a service in your AWS account our ACK controller will need credentials for those AWS services (or S3 in our case).  There are a few options for doing so, but the recommended approach is to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) (IRSA) that automates the management and rotation of temporary credentials that the service account can use. As stated on the [ACK documentation page](https://aws-controllers-k8s.github.io/community/docs/user-docs/irsa/):

> Instead of creating and distributing your AWS credentials to the containers or using the Amazon EC2 instance’s role, you can associate an IAM role with a Kubernetes service account. The applications in a Kubernetes pod container can then use an AWS SDK or the AWS CLI to make API requests to authorized AWS services.

To get the credentials, pods receive a valid OIDC JSON web token (JWT) and pass it to the AWS STS `AssumeRoleWithWebIdentity` API operation in order to receive IAM temporary role credentials.

The mechanism behind IRSA/STS in ROSA relies on the EKS pod identity mutating webhook which modifies pods that require AWS IAM access.  Since we are using ROSA w/STS this webhook is already installed.

!!! note
    Using IRSA allows us to adhere to the following best practices:

      1. **Principle of least privilege** - We are able to create finely tuned IAM permissions for AWS roles that only allow the access required.  Furthermore, these permissions are limited to the service account associated with the role and therefore only pods that use that service account have access.
      1. **Credential Isolation** - a pod can only retrieve credentials for the IAM role associated with the service account that the pod is using and no other.
      1. **Auditing** - In AWS, any access of AWS resources can be viewed in CloudTrail.

Usually one would need to provision an OIDC provider, but since one is deployed with ROSA w/STS we can use that one.

#### Create an IAM role and policy for the ACK controller

1. Create a new directory on your local machine to work from. Name it as you'd like.

    ```
    mkdir rosaworkshop && cd rosaworkshop
    ```

1. Download the [setup-s3-ack-controller.sh](resources/setup-s3-ack-controller.sh) script which automates the process for you, or use:

    ```
    wget https://raw.githubusercontent.com/openshift-cs/rosaworkshop/master/rosa-workshop/ostoy/resources/setup-s3-ack-controller.sh
    ```

    Don't worry, you will perform these steps later (for the application) but basically the script creates an AWS IAM role with an AWS S3 policy and associates that IAM role with the service account. Feel free to read the script.

1. Run the script

    ```
    ./setup-s3-ack-controller.sh
    ```

1. When the script is complete it will restart the deployment which will update the service controller pods with the IRSA environment variables.

1. Confirm that the environment variables are set. Run:

    ```
    oc describe pod ack-s3-controller -n ack-system | grep "^\s*AWS_"
    ```

    You should see a response like:

    ```
    AWS_ROLE_ARN:                 arn:aws:iam::000000000000:role/ack-s3-controller
    AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    ```

1. The ACK controller should now be set up successfully. You can confirm this in the OpenShift Web Console under "Operators > Installed operators".

    ![success](images/13-ack-oper-installed.png)

    !!! Info
        If after a minute you still do not see the Operator installation as successful and you do not see the IRSA environment variables, you may need to manually restart the deployment:

        ```
        oc rollout restart deployment ack-s3-controller -n ack-system
        ```

We can now create/delete buckets through Kubernetes using the ACK. In the next section we will enable our application to use the S3 bucket that we will create.

### Set up access for our application

#### Create a service account

Next, we need to create a service account so that OSToy can read the contents of the S3 bucket that we will create and to create objects in that bucket.

1. Switch back to your OSToy project. If your project is named differently, then use the name for your project.

    ```
    oc project ostoy
    ```

#### Create the AWS IAM role for accessing the AWS service

1. Get your AWS account ID

    ```
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ```

1. Get the OIDC provider

    ```
    export OIDC_PROVIDER=$(oc get authentication.config.openshift.io cluster -o jsonpath='{.spec.serviceAccountIssuer}' | sed 's/https:\/\///')
    ```

1. Create the trust policy file

    ```
    cat <<EOF > ./ostoy-sa-trust.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "${OIDC_PROVIDER}:sub": "system:serviceaccount:ostoy:ostoy-s3-sa"
            }
          }
        }
      ]
    }
    EOF
    ```

1. Create the AWS IAM role to be used with your service account

    ```
    aws iam create-role --role-name "ostoy-s3-sa-role" --assume-role-policy-document file://ostoy-sa-trust.json
    ```

####  Attach the S3 policy to the IAM role for the service account

1. Get the Full Access policy ARN

    ```
    export POLICY_ARN=$(aws iam list-policies  --query 'Policies[?PolicyName==`AmazonS3FullAccess`].Arn' --output text)
    ```

2. Attach that policy to the AWS IAM role

    ```
    aws iam attach-role-policy --role-name "ostoy-s3-sa-role" --policy-arn "${POLICY_ARN}"
    ```

#### Create the service account for our pod

1. Get the ARN for the AWS IAM role we created so that it will be included as an annotation when creating our service account.

    ```
    export APP_IAM_ROLE_ARN=$(aws iam get-role --role-name=ostoy-s3-sa-role --query Role.Arn --output text)
    ```

1. Create the service account manifest. Replace the namespace value with your namespace if it is different. 

    ```
    cat <<EOF > ostoy-serviceaccount.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ostoy-s3-sa
      namespace: ostoy
      annotations:
        eks.amazonaws.com/role-arn: "$APP_IAM_ROLE_ARN"
    EOF
    ```

1. Create the service account

    ```
    oc create -f ostoy-serviceaccount.yaml
    ```

1. Confirm that is was successful.

    ```
    oc describe serviceaccount ostoy-s3-sa -n ostoy
    ```

    You should see an output like the one below with the correct annotation:

    ``` yaml hl_lines="4"
    Name:                ostoy-s3-sa
    Namespace:           ostoy
    Labels:              <none>
    Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::000000000000:role/ostoy-s3-sa-role
    Image pull secrets:  ostoy-s3-sa-dockercfg-b2l94
    Mountable secrets:   ostoy-s3-sa-dockercfg-b2l94
    Tokens:              ostoy-s3-sa-token-jlc6d
    Events:              <none>
    ```

### Create an S3 bucket

1. Create a manifest file for your bucket. Copy the yaml file below and save it as `s3-bucket.yaml`. Or download it from [here](yaml/s3-bucket.yaml). Please replace `<namespace>` with your namespace/project for OSToy.

    For example, the value for name should be `ostoy-bucket` if our project is `ostoy`.

    !!! warning
        The OSToy application expects to find a bucket that is named based on the namespace that OSToy is in. Like "<namespace\>-bucket". If you place anything other than the namespace of OSToy, this feature will not work.

    ``` yaml hl_lines="4 6"
    apiVersion: s3.services.k8s.aws/v1alpha1
    kind: Bucket
    metadata:
      name: <namespace>-bucket
    spec:
      name: <namespace>-bucket
    ```

1. Create the bucket.

    ```
    oc create -f s3-bucket.yaml
    ```

1. Confirm the bucket was created

    ```
    aws s3 ls | grep <namespace>-bucket
    ```


### Redeploy the OSToy app with the new service account

1. Open the `ostoy-frontend-deployment.yaml` file (or download it [here](yaml/ostoy-frontend-deployment.yaml)) and uncomment `spec.template.spec.serviceAccount`, so it likes like the example below. Save the file.

    !!! note
        If you followed the steps above exactly then the service account name is the same. If you used a *different* service account name in the previous steps, you will need to replace the name with the one you created.

    ``` yaml hl_lines="4" linenums="29"
    spec:
      # Uncomment to use with ACK portion of the workshop
      # If you chose a different service account name please replace it.
      serviceAccount: ostoy-s3-sa
      containers:
      - name: ostoy-frontend
        image: quay.io/ostoylab/ostoy-frontend:1.5.0
        imagePullPolicy: IfNotPresent
    ```

1. Apply the change

    ```
    oc apply -f ostoy-frontend-deployment.yaml -n ostoy
    ```

1. Give it a minute to update the pod.

### Confirm that the IRSA environment variables are set

When AWS clients or SDKs connect to the AWS APIs, they detect `AssumeRoleWithWebIdentity` security tokens to assume the IAM role. See the [AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html) documentation for more details.

As we did for the ACK controller we can use the following command to describe the pods and verify that the `AWS_WEB_IDENTITY_TOKEN_FILE` and `AWS_ROLE_ARN` environment variables exist for our application which means that our application can successfully authenticate to use the S3 service:

```
oc describe pod ostoy-frontend -n ostoy | grep "^\s*AWS_"
```

We should see a response like:

```
AWS_ROLE_ARN:                 arn:aws:iam::000000000000:role/ostoy-s3-sa
AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

### See the bucket contents through OSToy

Use our app to see the contents of our S3 bucket.

1. Switch to the browser tab for the OSToy application and hit refresh.
1. A new menu item will appear. Click on "ACK S3" in the left menu in OSToy.
1. You will see a page that lists the contents of the bucket, which at this point should be empty.

    ![view bucket](images/13-ack-views3contents.png)

1. Move on to the next step to add some files.

### Create files in your S3 bucket

For this step we will use OStoy to create a file and upload it to the S3 bucket. While S3 can accept any kind of file, for this workshop we'll use text files so that the contents can easily be rendered in the browser.

1. Click on "ACK S3" in the left menu in OSToy.
1. Scroll down to the section underneath the "Existing files" section, titled "Upload a text file to S3".
1. Enter a file name for your file.
1. Enter some content for your file.
1. Click "Create file".

    ![create file](images/13-ack-creates3obj.png)

1. Scroll up to the top section for existing files and you should see your file that you just created there.
1. Click on the file name to view the file.

    ![viewfilecontents](images/13-ack-viewobj.png)

1. Now to confirm that this is not just some smoke and mirrors, let's confirm directly via the AWS CLI. Run the following to list the contents of our bucket.

    ```
    aws s3 ls s3://ostoy-bucket
    ```

    We should see our file listed there:

    ``` hl_lines="2"
    $ aws s3 ls s3://ostoy-bucket
    2022-10-31 22:20:51         51 OSToy.txt
    ```
