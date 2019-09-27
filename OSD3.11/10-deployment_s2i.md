## Using S2I to build and deploy our application.

There are multiple methods to deploy applications in OpenShift. Let's explore usingthe application using the integrated Source-to-Image builder. As mentioned in the [concepts](/OSD3.11/2-concepts.md) section, S2I is a tool for building reproducible, Docker-formatted container images. 

#### 0. Retrieve the login command (if not logged in via CLI)
If not logged in via the CLI, click on the dropdown arrow next to your name in the top-right of the cluster console and select *Copy Login Command*.

![CLI Login](/images/4-cli-login.png)

Then go to your terminal and paste that command and press enter.  You will see a similar confirmation message if you successfully logged in.

```
$ oc login https://api.demo1234.openshift.com --token=HS1QpKXXXXXXXXXXX
Logged into "https://api.demo1234.openshift.com" as "0kashi" using the token provided.

You have access to the following projects and can switch between them with 'oc project <projectname>':

    aro-demo
  * aro-shifty
  ...
```
#### 1. Create a project
Create a new project for us to work in for this part. Let's call is `ostoy-s2i`.  You can create a new project by running `oc new-project ostoy-s2i`.


#### 2. Add Secret to OpenShift
The example emulates a `.env` file and shows how easy it is to move these directly into an
OpenShift environment. Files can even be renamed in the Secret.  In your CLI enter the following command:<br><br>
```
$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/secret.yaml

secret "ostoy-secret" created
```

#### 3. Add ConfigMap to OpenShift
The example emulates an HAProxy config file, and is typically used for overriding
default configurations in an OpenShift application. Files can even be renamed in the ConfigMap
Enter the following into your CLI 
```
$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/configmap.yaml`

configmap "ostoy-config" created
```

#### 4. Deploy the microservice
We deploy the microservice first to ensure that the SERVICE environment variables
will be available from the UI application. `--context-dir` is used here to only
build the application defined in the `microservice` directory in the git repo.
Using the `app` label allows us to ensure the UI application and microservice
are both grouped in the OpenShift UI.  Enter the following into the CLI
```
$ oc new-app https://github.com/openshift-cs/ostoy \
    --context-dir=microservice \
    --name=ostoy-microservice \
    --labels=app=ostoy

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
```
#### 5. Check the status of the application
Before moving onto the next step we should be sure that the microservice was created and is running correctly.  To do this run:

```
$ oc status
In project ostoy-s2i on server https://api.bu-demo.openshift.com:443

svc/ostoy-microservice - 172.30.119.88:8080
  dc/ostoy-microservice deploys istag/ostoy-microservice:latest <-
    bc/ostoy-microservice source builds https://github.com/openshift-cs/ostoy on openshift/nodejs:10 
    deployment #1 deployed about a minute ago - 1 pod
``` 

Wait until you see that it was successfully deployed. You can also check this through the web UI.

#### 6. Deploy the UI Application
The applicaiton has been architected to rely on several environment variables to define external settings. We will attach the previously created Secret and ConfigMap afterward, along with creating a PersistentVolume.  Enter the following into the CLI:
```
$ oc new-app https://github.com/openshift-cs/ostoy \
    --env=MICROSERVICE_NAME=OSTOY_MICROSERVICE

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
```

#### 7. Update the Deployment 
We need to update the deployment to use a "Recreate" deployment strategy (as opposed to the default of `RollingUpdate` for consistent deployments with persistent volumes. Reasoning here is that the PV is backed by EBS and as such only supports the `RWO` method.  If the deployment is updated without all existing pods being killed it may not be able to schedule a new pod and create a PVC for the PV as it's still bound to the existing pod.
```
$ oc patch dc/ostoy -p '{"spec": {"strategy": {"type": "Recreate"}}}'

deploymentconfig "ostoy" patched
```

#### 8. Set a Liveness probe 
We need to create a Liveliness Probe on the Deployment to ensure the pod is restarted if something isn't healthy within the application.  Enter the following into the CLI:
```
$ oc set probe dc/ostoy --liveness --get-url=http://:8080/health

deploymentconfig "ostoy" updated
```

#### 9. Attach Secret, ConfigMap, and PersistentVolume to Deployment
We are using the default paths defined in the application, but these paths can be overriden in the application via environment variables

- Attach Secret
```
$ oc set volume deploymentconfig ostoy --add \
    --secret-name=ostoy-secret \
    --mount-path=/var/secret

info: Generated volume name: volume-6fqmv
deploymentconfig "ostoy" updated
```

- Attach ConfigMap (using shorthand commands)
```
$ oc set volume dc ostoy --add \
    --configmap-name=ostoy-config \
    -m /var/config

info: Generated volume name: volume-2ct8f
deploymentconfig "ostoy" updated
```

- Create and attach PersistentVolume
```
$ oc set volume dc ostoy --add \
    --type=pvc \
    --claim-size=1G \
    -m /var/demo_files

info: Generated volume name: volume-rlbvv
persistentvolumeclaims/pvc-gbpx7
deploymentconfig "ostoy" updated
```

#### 10. Expose the UI application as an OpenShift Route
Using OpenShift Dedicated's included TLS wildcard certicates, we can easily deploy this as an HTTPS application
```
$ oc create route edge --service=ostoy --insecure-policy=Redirect

route "ostoy" created
```

#### 11. Browse to your application!
Enter the following into your CLI:

`$ python -m webbrowser "$(oc get route ostoy -o template --template='https://{{.spec.host}}')"`

or you can manually get the route for the application and copy/paste that into your browser via
`oc get routes`
