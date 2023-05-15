# Integrating with AWS Services

So far, our OSToy application has functioned independently without relying on any external services. While this may be nice for a workshop environment, it's not exactly representative of real-world applications. Many applications require external services like databases, object stores, or messaging services.

In this section, we will learn how to integrate our OSToy application with other AWS services, specifically AWS S3 Storage. By the end of this section, our application will be able to securely create and read objects from S3.

To achieve this, we will use the Amazon Controller for Kubernetes (ACK) to create the necessary services for our application directly from Kubernetes.  We will utilize IAM Roles for Service Accounts (IRSA) to manage access and authentication.

To demonstrate this integration, we will use OSToy to create a basic text file and save it in an S3 Bucket. Finally, we will confirm that the file was successfully added and can be read from the bucket.

## Amazon Controller for Kubernetes (ACK)

The [Amazon Controller for Kubernetes](https://aws-controllers-k8s.github.io/community/docs/community/overview/) (ACK) allows you to create and use AWS services directly from
Kubernetes. You can deploy your applications, including any required AWS services directly within the Kubernetes framework using a familiar structure to declaratively define and create AWS services like S3 buckets or RDS databases.

In order to illustrate the use of the ACK on ROSA, we will walk through a simple example of creating an S3 bucket, integrating that with OSToy, upload a file to it, and view the file in our application. Interestingly, this part of the workshop will also touch upon the concept of granting your applications access to AWS services (though that is worthy of a workshop of its own).

## IAM Roles for Service Accounts (IRSA)

To deploy a service in your AWS account our ACK controller will need credentials for those AWS services (or S3 in our case).  There are a few options for doing so, but the recommended approach is to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) (IRSA) that automates the management and rotation of temporary credentials that the service account can use. As stated on the [ACK documentation page](https://aws-controllers-k8s.github.io/community/docs/user-docs/irsa/):

> Instead of creating and distributing your AWS credentials to the containers or using the Amazon EC2 instance’s role, you can associate an IAM role with a Kubernetes service account. The applications in a Kubernetes pod container can then use an AWS SDK or the AWS CLI to make API requests to authorized AWS services.

Summarized, it is an AWS feature that enables you to assign IAM roles directly to Kubernetes service accounts.

To get the credentials, pods receive a valid OIDC JSON web token (JWT) and pass it to the AWS STS `AssumeRoleWithWebIdentity` API operation in order to receive IAM temporary role credentials.

The mechanism behind IRSA/STS in ROSA relies on the EKS pod identity mutating webhook which modifies pods that require AWS IAM access.  Since we are using ROSA w/STS this webhook is already installed.

!!! note
    Using IRSA allows us to adhere to the following best practices:

      1. **Principle of least privilege** - We are able to create finely tuned IAM permissions for AWS roles that only allow the access required.  Furthermore, these permissions are limited to the service account associated with the role and therefore only pods that use that service account have access.
      1. **Credential Isolation** - a pod can only retrieve credentials for the IAM role associated with the service account that the pod is using and no other.
      1. **Auditing** - In AWS, any access of AWS resources can be viewed in CloudTrail.

Usually one would need to provision an OIDC provider, but since one is deployed with ROSA w/STS we can use that one.

## Section overview

To make the process clearer, here is an overview of the procedure we are going to follow. There are two main "parts".

1. **ACK Controller for the cluster** - This allows you to create/delete buckets in the S3 service through the use of a Kubernetes Custom Resource for the bucket.
    1. Install the controller (in our case an Operator) which will also create the required namespace and the service account.
    1. Run a script which will:
        1. Create the AWS IAM role for the ACK controller and assign the S3 policy
        1. Associate the AWS IAM role with the service account
1. **Application access** - Granting access to our application container/pod to access our S3 bucket.
    1. Create a service account for the application
    1. Create an AWS IAM role for the application and assign the S3 policy
    1. Associate the AWS IAM role with the service account
    1. Update application deployment manifest to use the service account

## Install an ACK controller

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

## Set up access for the controller

### Create an IAM role and policy for the ACK controller

1. Run the [setup-s3-ack-controller.sh](resources/setup-s3-ack-controller.sh) script which automates the process for you, or use:

    ```
    curl https://raw.githubusercontent.com/openshift-cs/rosaworkshop/master/rosa-workshop/ostoy/resources/setup-s3-ack-controller.sh | bash
    ```

    Don't worry, you will perform these steps later (for the application) but basically the script creates an AWS IAM role with an AWS S3 policy and associates that IAM role with the service account. 
    
    If you're not feeling risky then feel free to download it first and read the script before you run it.

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

## Set up access for our application

In this section we will create an AWS IAM role and service account so that OSToy can read and write objects to the S3 bucket that we will create. 

Before starting, create a new unique project for OSToy.

```
oc new-project ostoy-$(uuidgen | cut -d - -f 2 | tr '[:upper:]' '[:lower:]')
```

Also, save the name of the namespace/project that OSToy is in to an environment variable to simplify command execution.

```
export OSTOY_NAMESPACE=$(oc config view --minify -o 'jsonpath={..namespace}')
```

### Create an AWS IAM role

1. Get your AWS account ID.

    ```
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ```

1. Get the OIDC provider. Replace "<cluster-name\>" with the name of your cluster.

    ```
    export OIDC_PROVIDER=$(rosa describe cluster -c <cluster-name> -o yaml | awk '/oidc_endpoint_url/ {print $2}' | cut -d '/' -f 3,4)
    ```

1. Create the trust policy file.

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
              "${OIDC_PROVIDER}:sub": "system:serviceaccount:${OSTOY_NAMESPACE}:ostoy-sa"
            }
          }
        }
      ]
    }
    EOF
    ```

1. Create the AWS IAM role to be used with your service account

    ```
    aws iam create-role --role-name "ostoy-sa-role" --assume-role-policy-document file://ostoy-sa-trust.json
    ```

### Attach the S3 policy to the IAM role

1. Get the S3 Full Access policy ARN

    ```
    export POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3FullAccess`].Arn' --output text)
    ```

2. Attach that policy to the AWS IAM role

    ```
    aws iam attach-role-policy --role-name "ostoy-sa-role" --policy-arn "${POLICY_ARN}"
    ```

### Create the service account for our pod

1. Get the ARN for the AWS IAM role we created so that it will be included as an annotation when creating our service account.

    ```
    export APP_IAM_ROLE_ARN=$(aws iam get-role --role-name=ostoy-sa-role --query Role.Arn --output text)
    ```

1. Create the service account via manifest. Note the annotation to reference our AWS IAM role.

    ``` hl_lines="8"
    cat <<EOF | oc apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ostoy-sa
      namespace: ${OSTOY_NAMESPACE}
      annotations:
        eks.amazonaws.com/role-arn: "$APP_IAM_ROLE_ARN"
    EOF
    ```

    !!! warning
        Do not change the name of the service account from "ostoy-sa".  Otherwise you will have to change the trust relationship for the AWS IAM role.

1. Grant the service account the `restricted` role.

    ```
    oc adm policy add-scc-to-user restricted system:serviceaccount:${OSTOY_NAMESPACE}:ostoy-sa
    ```

1. Confirm that is was successful.

    ```
    oc describe serviceaccount ostoy-sa -n ${OSTOY_NAMESPACE}
    ```

    You should see an output like the one below with the correct annotation:

    ```hl_lines="4"
    Name:                ostoy-sa
    Namespace:           ostoy
    Labels:              <none>
    Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::000000000000:role/ostoy-sa-role
    Image pull secrets:  ostoy-sa-dockercfg-b2l94
    Mountable secrets:   ostoy-sa-dockercfg-b2l94
    Tokens:              ostoy-sa-token-jlc6d
    Events:              <none>
    ```

## Create an S3 bucket

1. Create the S3 bucket using a manifest file. Run the command below or download it from [here](yaml/s3-bucket.yaml), then run it.

    !!! warning
        The OSToy application expects to find a bucket that is named based on the namespace/project that OSToy is in. Like "<namespace\>-bucket". If you place anything other than the namespace of your OSToy project, this feature will not work. For example, if our project is "ostoy", the value for `name` must be "ostoy-bucket".

        You must also consider that because Amazon S3 requires that bucket names be globally unique, you must run OSToy in a project that is unique as well. Which is why we created a new project for this section.

    ``` hl_lines="5 8"
    cat <<EOF | oc apply -f -
    apiVersion: s3.services.k8s.aws/v1alpha1
    kind: Bucket
    metadata:
      name: ${OSTOY_NAMESPACE}-bucket
      namespace: ${OSTOY_NAMESPACE}
    spec:
      name: ${OSTOY_NAMESPACE}-bucket
    EOF
    ```

1. Confirm the bucket was created.

    ```
    aws s3 ls | grep ${OSTOY_NAMESPACE}-bucket
    ```


## Redeploy the OSToy app with the new service account

1. We now need to run our pod with the service account we created.  Patch the `ostoy-frontend` deployment to add it.

    ```
    oc patch deploy ostoy-frontend -n ${OSTOY_NAMESPACE} --type=merge --patch '{"spec": {"template": {"spec":{"serviceAccount":"ostoy-sa"}}}}'
    ```

1. In effect we are making our deployment manifest look like the example below by specifying the service account.

    ``` yaml hl_lines="4" linenums="29"
    spec:
      # Uncomment to use with ACK portion of the workshop
      # If you chose a different service account name please replace it.
      serviceAccount: ostoy-sa
      containers:
      - name: ostoy-frontend
        image: quay.io/ostoylab/ostoy-frontend:1.6.0
        imagePullPolicy: IfNotPresent
    [...]
    ```

1. Also deploy the microservice.

    ```
    oc apply -f https://raw.githubusercontent.com/openshift-cs/rosaworkshop/master/rosa-workshop/ostoy/yaml/ostoy-microservice-deployment.yaml
    ```

1. Give it a minute to update the pod.

## Confirm that the IRSA environment variables are set

When AWS clients or SDKs connect to the AWS APIs, they detect `AssumeRoleWithWebIdentity` security tokens to assume the IAM role. See the [AssumeRoleWithWebIdentity](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html) documentation for more details.

As we did for the ACK controller we can use the following command to describe the pods and verify that the `AWS_WEB_IDENTITY_TOKEN_FILE` and `AWS_ROLE_ARN` environment variables exist for our application which means that our application can successfully authenticate to use the S3 service:

```
oc describe pod ostoy-frontend -n ${OSTOY_NAMESPACE} | grep "^\s*AWS_"
```

We should see a response like:

```
AWS_ROLE_ARN:                 arn:aws:iam::000000000000:role/ostoy-sa
AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

## See the bucket contents through OSToy

Use our app to see the contents of our S3 bucket.

1. Get the route for the newly deployed application.

    ```
    oc get route ostoy-route -n ${OSTOY_NAMESPACE} -o jsonpath='{.spec.host}{"\n"}'
    ```

1. Open a new browser tab and enter the route from above. Ensure that it is using `http://` and not `https://`.
1. A new menu item will appear. Click on "ACK S3" in the left menu in OSToy.
1. You will see a page that lists the contents of the bucket, which at this point should be empty.

    ![view bucket](images/13-ack-views3contents.png)

1. Move on to the next step to add some files.

## Create files in your S3 bucket

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
    aws s3 ls s3://${OSTOY_NAMESPACE}-bucket
    ```

    We should see our file listed there:

    ``` hl_lines="2"
    $ aws s3 ls s3://ostoy-bucket
    2023-05-04 22:20:51         51 OSToy.txt
    ```
