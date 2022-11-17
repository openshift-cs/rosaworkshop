## Using S2I to build and deploy our application

There are multiple methods to deploy applications in OpenShift. Let's explore using the integrated Source-to-Image (S2I) builder. As mentioned in the [concepts](2-concepts.md) section, S2I is a tool for building reproducible, Docker-formatted container images.

### Before Starting

#### Retrieve the login command
If you are not logged in via the CLI, click on the dropdown arrow next to your name in the top-right of the cluster console and select *Copy Login Command*.

Follow the steps from [Step 1](4-deployment.md#1-retrieve-the-login-command) of the Deployment section.

#### Fork the repository
In the next section we will trigger automated builds based on changes to the source code. In order to trigger S2I builds when you push code into your GitHub repo, you’ll need to setup the GitHub webhook.  And in order to setup the webhook, you’ll first need to fork the application into your personal GitHub repository.

Click the button to fork the repository:

[Fork the repository :material-source-fork:](https://github.com/openshift-cs/ostoy/fork){ .md-button .md-button--primary }


!!! note
    Going forward you will need to replace any reference to "<username\>" in any of the URLs for commands with your own GitHub username.

#### Create a project
Create a new project for this part. Let's call it `ostoy-s2i`.  

You can create a new project from the CLI by running the below command or use the OpenShift Web Console.

    oc new-project ostoy-s2i

### Steps to Deploy OSToy imperatively using S2I

#### Add Secret to OpenShift
The example emulates a `.env` file and shows how easy it is to move these directly into an OpenShift environment. Files can even be renamed in the Secret.  In your CLI enter the following command:

    oc create -f https://raw.githubusercontent.com/<username>/ostoy/master/deployment/yaml/secret.yaml


#### Add ConfigMap to OpenShift
The example emulates an HAProxy config file, and is typically used for overriding default configurations in an OpenShift application. Files can even be renamed in the ConfigMap.

Enter the following into your CLI

    oc create -f https://raw.githubusercontent.com/<username>/ostoy/master/deployment/yaml/configmap.yaml


#### Deploy the microservice
We deploy the microservice first to ensure that the SERVICE environment variables will be available from the UI application. `--context-dir` is used here to only build the application defined in the `microservice` directory in the git repo. Using the `app` label allows us to ensure the UI application and microservice are both grouped in the OpenShift UI.  

Enter the following into the CLI

    oc new-app https://github.com/<username>/ostoy \
        --context-dir=microservice \
        --name=ostoy-microservice \
        --labels=app=ostoy \
        --as-deployment-config=true

You will see a response like:

    Creating resources with label app=ostoy ...
      imagestream "ostoy-microservice" created
      buildconfig "ostoy-microservice" created
      deploymentconfig "ostoy-microservice" created
      service "ostoy-microservice" created
    Success
      Build scheduled, use 'oc logs -f bc/ostoy-microservice' to track its progress.
      Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
       'oc expose svc/ostoy-microservice'
      Run 'oc status' to view your app.

#### Check the status of the microservice
Before moving onto the next step we should be sure that the microservice was created and is running correctly.  To do this run:

    oc status

You will see a response like:

    In project ostoy-s2i on server https://api.myroscluster.g14t.p1.openshiftapps.com:6443

    svc/ostoy-microservice - 172.30.47.74:8080
      dc/ostoy-microservice deploys istag/ostoy-microservice:latest <-
        bc/ostoy-microservice source builds https://github.com/0kashi/ostoy on openshift/nodejs:14-ubi8
        deployment #1 deployed 34 seconds ago - 1 pod


Wait until you see that it was successfully deployed. You can also check this through the web UI.

#### Deploy the frontend UI
The application has been architected to rely on several environment variables to define external settings. We will attach the previously created Secret and ConfigMap afterward, along with creating a PersistentVolume.  Enter the following into the CLI:

    oc new-app https://github.com/<username>/ostoy \
        --env=MICROSERVICE_NAME=OSTOY_MICROSERVICE \
        --as-deployment-config=true

You will see a response like:

    Creating resources ...
      imagestream "ostoy" created
      buildconfig "ostoy" created
      deploymentconfig "ostoy" created
      service "ostoy" created
    Success
      Build scheduled, use 'oc logs -f bc/ostoy' to track its progress.
      Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
       'oc expose svc/ostoy'
      Run 'oc status' to view your app.


#### Update the Deployment
We need to update the deployment to use a "Recreate" deployment strategy (as opposed to the default of `RollingUpdate`) for consistent deployments with persistent volumes. Reasoning here is that the PV is backed by EBS and as such only supports the `RWO` method.  If the deployment is updated without all existing pods being killed it may not be able to schedule a new pod and create a PVC for the PV as it's still bound to the existing pod. If you will be using EFS you do not have to change this.

    oc patch dc/ostoy -p '{"spec": {"strategy": {"type": "Recreate"}}}'


#### Set a Liveness probe
We need to create a Liveness Probe on the Deployment to ensure the pod is restarted if something isn't healthy within the application.  Enter the following into the CLI:

    oc set probe dc/ostoy --liveness --get-url=http://:8080/health

#### Attach Secret, ConfigMap, and PersistentVolume to Deployment
We are using the default paths defined in the application, but these paths can be overridden in the application via environment variables

- Attach Secret

        oc set volume deploymentconfig ostoy --add \
          --secret-name=ostoy-secret \
          --mount-path=/var/secret

- Attach ConfigMap (using shorthand commands)

        oc set volume dc ostoy --add \
          --configmap-name=ostoy-config \
          -m /var/config

- Create and attach PersistentVolume

        oc set volume dc ostoy --add \
          --type=pvc \
          --claim-size=1G \
          -m /var/demo_files

#### Expose the UI application as an OpenShift Route
Using the included TLS wildcard certificates, we can easily deploy this as an HTTPS application

    oc create route edge --service=ostoy --insecure-policy=Redirect


#### Browse to your application
Enter the following into your CLI:

    python -m webbrowser "$(oc get route ostoy -o template --template='https://{{.spec.host}}')"

or you can get the route for the application by using `oc get route` and copy/paste the route into your browser
