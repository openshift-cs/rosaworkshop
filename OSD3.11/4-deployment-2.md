## Deploy via a Kubernetes Deployment

Another way to deploy the application would be to have the images for the front-end and back-end microservice containers already created (via CI/CD) and stored in an image repository.  You can then create Kubernetes deployments (YAML) and use those to deploy the application.  We will do that here.

1. Retrieve login command

If not logged in via the CLI, click on the dropdown arrow next to your name in the top-right and select *Copy Login Command*.

![CLI Login](/images/4-cli-login.png)

Then go to your terminal and paste that command and press enter.  You will see a similar confirmation message if you successfully logged in.

```sh
[okashi@ok-vm ostoy]# oc login https://api.demo1234.openshift.com --token=HS1QpKXXXXXXXXXXX
Logged into "https://api.demo1234.openshift.com" as "0kashi" using the token provided.

You have access to the following projects and can switch between them with 'oc project <projectname>':

    aro-demo
  * aro-shifty
  ...
```

### Create new project

Create a new project called "OSToy" in your cluster.

Use the following command

`oc new-project ostoy`

You should receive the following response

```sh
[okashi@ok-vm ostoy]# oc new-project ostoy
Now using project "ostoy" on server "https://api.demo1234.openshift.com:443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app centos/ruby-25-centos7~https://github.com/sclorg/ruby-ex.git

to build a new example application in Ruby.
```

Equivalently you can also create this new project using the web UI by selecting "Application Console" at the top  then clicking on "+Create Project" button on the right.

![UI Create Project](/images/4-createnewproj.png)

### Download YAML configuration

Download the Kubernetes deployment object yamls from the following locations to your local machine, in a directory of your choosing (just remember where you placed them for the next step).

Feel free to open them up and take a look at what we will be deploying. For simplicity of this lab we have placed all the Kubernetes objects we are deploying in one "all-in-one" yaml file.  Though in reality there are benefits to separating these out into individual yaml files.

[ostoy-fe-deployment.yaml](/yaml/ostoy-fe-deployment.yaml)

[ostoy-microservice-deployment.yaml](/yaml/ostoy-microservice-deployment.yaml)

### Deploy backend microservice

The microservice application serves internal web requests and returns a JSON object containing the current hostname and a randomly generated color string.

In your command line deploy the microservice using the following command:

`oc apply -f ostoy-microservice-deployment.yaml`

You should see the following response:
```
[okashi@ok-vm ostoy]# oc apply -f ostoy-microservice-deployment.yaml
deployment.apps/ostoy-microservice created
service/ostoy-microservice-svc created
```

### Deploy the front-end service

The frontend deployment contains the node.js frontend for our application along with a few other Kubernetes objects to illustrate examples.

 If you open the *ostoy-fe-deployment.yaml* you will see we are defining:

- Persistent Volume Claim
- Deployment Object
- Service
- Route
- Configmaps
- Secrets

In your command line deploy the frontend along with creating all objects mentioned above by entering:

`oc apply -f ostoy-fe-deployment.yaml`

You should see all objects created successfully

```sh
[okashi@ok-vm ostoy]# oc apply -f ostoy-fe-deployment.yaml
persistentvolumeclaim/ostoy-pvc created
deployment.apps/ostoy-frontend created
service/ostoy-frontend-svc created
route.route.openshift.io/ostoy-route created
configmap/ostoy-configmap-env created
secret/ostoy-secret-env created
configmap/ostoy-configmap-files created
secret/ostoy-secret created
```

### Get route

Get the route so that we can access the application via `oc get route`

You should see the following response:

```sh
NAME           HOST/PORT                                                      PATH      SERVICES              PORT      TERMINATION   WILDCARD
ostoy-route   ostoy-route-ostoy.apps.abcd1234.eastus.azmosa.io             ostoy-frontend-svc   <all>                   None
```

Copy `ostoy-route-ostoy.apps.abcd1234.eastus.azmosa.io` above and paste it into your browser and press enter.  You should see the homepage of our application.

![Home Page](/media/managedlab/10-ostoy-homepage.png)