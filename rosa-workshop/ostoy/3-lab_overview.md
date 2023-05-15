### Resources

- The source code for this app is available here: <https://github.com/openshift-cs/ostoy>
- OSToy front-end container image: <https://quay.io/ostoylab/ostoy-frontend>
- OSToy microservice container image: <https://quay.io/ostoylab/ostoy-microservice>
- Deployment Definition YAMLs:
	- [ostoy-frontend-deployment.yaml](yaml/ostoy-frontend-deployment.yaml)
	- [ostoy-microservice-deployment.yaml](yaml/ostoy-microservice-deployment.yaml)
- S3 bucket manifest for ACK S3: [s3-bucket.yaml](yaml/s3-bucket.yaml)

!!! note
		In order to simplify the deployment of the app we have included all the objects needed in the above deployment manifests as an "all-in-one" manifest.  Though in reality, an enterprise would most likely want to have a different manifest file for each Kubernetes object.

### About OSToy

OSToy is a simple Node.js application that we will deploy to ROSA. It is used to help us explore the functionality of Kubernetes. This application has a user interface where you can:

- write messages to the log (stdout / stderr)
- intentionally crash the application to view self-healing
- toggle a liveness probe and monitor OpenShift behavior
- read config maps, secrets, and env variables
- if connected to shared storage, read and write files
- check network connectivity, intra-cluster DNS, and intra-communication with an included microservice
- increase the load to view automatic scaling of the pods to handle the load (via the Horizontal Pod Autoscaler)
- connect to an AWS S3 bucket to read and write objects (Optional)

### OSToy Application Diagram

![OSTOY Architecture](images/3-ostoy-arch.png)

### Familiarization with the Application UI

1. Shows the pod name that served your browser the page.
2. **Home:** The main page of the application where you can perform some of the functions listed which we will explore.
3. **Persistent Storage:**  Allows us to write data to the persistent volume bound to this application.
4. **Config Maps:**  Shows the contents of configmaps available to the application and the key:value pairs.
5. **Secrets:** Shows the contents of secrets available to the application and the key:value pairs.
6. **ENV Variables:** Shows the environment variables available to the application.
7. **Networking:** Tools to illustrate networking within the application.
8. **Pod Auto Scaling:** Tool to increase the load of the pods and test the HPA.
9. **ACK S3:** Integrate with AWS S3 to read and write objects to a bucket. (Optional)

	!!! important
		In order see the "ACK S3" section of OSToy, you must complete the [ACK section](13-ack.md) of this workshop. If you decide not to complete that section, the OSToy application will work regardless.

10. **About:** Shows some more information about the application.

	![Home Page](images/3-ostoy-homepage.png)

*[ROSA]: Red Hat OpenShift Service on AWS
*[IdP]: Identity Provider
*[OCM]: OpenShift Cluster Manager
