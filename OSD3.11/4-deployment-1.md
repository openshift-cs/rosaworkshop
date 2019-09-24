## Using S2I to build and deploy our application.

There are multiple methods to deploy applications in OpenShift. First we will deploy the application using the integrated Source-to-Image builder.

#### 1. Add Secret to OpenShift
The example emulates a `.env` file and shows how easy it is to move these directly into an
OpenShift environment. Files can even be renamed in the Secret.  In your CLI enter the following command:<br><br>
```
$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/secret.yaml

secret "ostoy-secret" created
```

#### 2. Add ConfigMap to OpenShift
The example emulates an HAProxy config file, and is typically used for overriding
default configurations in an OpenShift application. Files can even be renamed in the ConfigMap
Enter the following into your CLI 
```
$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/configmap.yaml`

configmap "ostoy-config" created
```

#### 3. Deploy the microservice
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

#### 4. Deploy the UI Application
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

#### 5. Update the Deployment 
We need to update the deployment to use a "Recreate" deployment strategy (as opposed to the default of `RollingUpdate` for consistent deployments with persistent volumes. Reasoning here is that the PV is backed by EBS and as such only supports the `RWO` method.  If the deployment is updated without all existing pods being killed it may not be able to schedule a new pod and create a PVC for the PV as it's still bound to the existing pod.
```
$ oc patch dc/ostoy -p '{"spec": {"strategy": {"type": "Recreate"}}}'

deploymentconfig "ostoy" patched
```

#### 6. Set a Liveness probe 
We need to create a Liveliness Probe on the Deployment to ensure the pod is restarted if something isn't healthy within the application.  Enter the following into the CLI:
```
$ oc set probe dc/ostoy --liveness --get-url=http://:8080/health

deploymentconfig "ostoy" updated
```

#### 7. Attach Secret, ConfigMap, and PersistentVolume to Deployment
We are using the default paths defined in the application, but these paths can be overriden in the application via environment variables

Attach Secret
```
$ oc set volume deploymentconfig ostoy --add \
    --secret-name=ostoy-secret \
    --mount-path=/var/secret

info: Generated volume name: volume-6fqmv
deploymentconfig "ostoy" updated
```

Attach ConfigMap (using shorthand commands)
```
$ oc set volume dc ostoy --add \
    --configmap-name=ostoy-config \
    -m /var/config

info: Generated volume name: volume-2ct8f
deploymentconfig "ostoy" updated
```

Create and attach PersistentVolume
```
$ oc set volume dc ostoy --add \
    --type=pvc \
    --claim-size=1G \
    -m /var/demo_files

info: Generated volume name: volume-rlbvv
persistentvolumeclaims/pvc-gbpx7
deploymentconfig "ostoy" updated
```

#### 8. Expose the UI application as an OpenShift Route
Using OpenShift Dedicated's included TLS wildcard certicates, we can easily deploy this as an HTTPS application
```
$ oc create route edge --service=ostoy --insecure-policy=Redirect

route "ostoy" created
```

#### 9. Browse to your application!
Enter the following into your CLI:

`$ python -m webbrowser "$(oc get route ostoy -o template --template='https://{{.spec.host}}')"`

or you can manually get the route for the application and copy/paste that into your browser via
`oc get routes`
