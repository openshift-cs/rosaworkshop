## Introduction to the workshop

### What is Red Hat OpenShift Service on AWS (ROSA)?

ROSA is a _fully_ managed Red Hat OpenShift service running natively on Amazon Web Services (AWS), which allows customers to quickly and easily build, deploy, and manage Kubernetes applications on the industry’s most comprehensive Kubernetes platform in the AWS public cloud. 

You can learn more at: <https://www.openshift.com/products/amazon-openshift> or at
<https://aws.amazon.com/rosa/>

### What will we do in this workshop?
In this lab, you’ll go through a set of tasks that will help you understand the concepts of deploying and using container based applications on top of ROSA.

Some of the things you’ll be going through:

- Create your own ROSA Cluster
- Deploy a node.js based app via S2I and Kubernetes Deployment objects
- Set up an continuous delivery pipeline to automatically push changes to the source code
- Explore logging
- Experience self healing of applications
- Explore configuration management through configmaps, secrets and environment variables
- Use persistent storage to share data across pod restarts
- Explore networking within Kubernetes and applications
- Familiarization with OpenShift and Kubernetes functionality
- Automatically scale pods based on load via the Horizontal Pod Autoscaler

You’ll be doing the majority of the labs using the OpenShift CLI, but you can also accomplish them using the OpenShift web console.
