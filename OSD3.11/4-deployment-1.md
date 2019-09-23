## Using S2I to build and deploy our application.

There are multiple methods to deploy applications in OpenShift. First we will deploy the application using the integrated Source-to-Image builder.

1. Add Secret to OpenShift
The example emulates a `.env` file and shows how easy it is to move these directly into an
OpenShift environment. Files can even be renamed in the Secret.  In your CLI enter the following command:
`$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/secret.yaml`

You will see the following respoonse
```secret "ostoy-secret" created```

2. Add ConfigMap to OpenShift
The example emulates an HAProxy config file, and is typically used for overriding
default configurations in an OpenShift application. Files can even be renamed in the ConfigMap
Enter the following into your CLI `$ oc create -f https://raw.githubusercontent.com/openshift-cs/ostoy/master/deployment/yaml/configmap.yaml`

```You will see the following response```
configmap "ostoy-config" created

3. Deploy the microservice
We deploy the microservice first to ensure that the SERVICE environment variables
will be available from the UI application. `--context-dir` is used here to only
build the application defined in the `microservice` directory in the git repo.
Using the `app` label allows us to ensure the UI application and microservice
are both grouped in the OpenShift UI
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

4. Deploy the UI Application
The applicaiton has been architected to rely on several environment variables to define external settings. We will attach the previously created Secret and ConfigMap afterward, along with creating a PersistentVolume
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

# Update Deployment to use a "Recreate" deployment strategy for consistent deployments
# with persistent volumes
$ oc patch dc/ostoy -p '{"spec": {"strategy": {"type": "Recreate"}}}'

deploymentconfig "ostoy" patched

# Set a Liveness probe on the Deployment to ensure the pod is restarted if something
# isn't healthy within the application
$ oc set probe dc/ostoy --liveness --get-url=http://:8080/health

deploymentconfig "ostoy" updated

# Attach Secret, ConfigMap, and PersistentVolume to deployment
# We are using the default paths defined in the application, but these paths
# can be overriden in the application via environment variables
# Attach Secret
$ oc set volume deploymentconfig ostoy --add \
    --secret-name=ostoy-secret \
    --mount-path=/var/secret

info: Generated volume name: volume-6fqmv
deploymentconfig "ostoy" updated

# Attach ConfigMap (using shorthand commands)
$ oc set volume dc ostoy --add \
    --configmap-name=ostoy-config \
    -m /var/config

info: Generated volume name: volume-2ct8f
deploymentconfig "ostoy" updated

# Create and attach PersistentVolume
$ oc set volume dc ostoy --add \
    --type=pvc \
    --claim-size=1G \
    -m /var/demo_files

info: Generated volume name: volume-rlbvv
persistentvolumeclaims/pvc-gbpx7
deploymentconfig "ostoy" updated

# Finally expose the UI application as an OpenShift Route
# Using OpenShift Dedicated's included TLS wildcard certicates, we can easily
# deploy this as an HTTPS application
$ oc create route edge --service=ostoy --insecure-policy=Redirect

route "ostoy" created

# Browse to your application!
$ python -m webbrowser "$(oc get route ostoy -o template --template='https://{{.spec.host}}')"
