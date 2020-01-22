## Introduction to the workshop

### What is OpenShift Dedicated?

OpenShift Dedicated (OSD) is an OpenShift cluster provided as a managed cloud service, configured for high availability (HA), and dedicated to a single customer (single-tenant). OpenShift Dedicated is managed by Red Hat Operations, providing increased security and years of operational experience working with OpenShift in both development and production. OpenShift Dedicated also comes with award-winning 24x7 Red Hat Premium Support.

You can learn more at: <https://www.openshift.com/dedicated>

### What will we do in this workshop?
In this lab, you’ll go through a set of tasks that will help you understand the concepts of deploying and using container based applications on top of OpenShift Dedicated 4.

Some of the things you’ll be going through:

- Deploy a node.js based app via S2I and Kubernetes Deployment objects
- Set up an continuous delivery pipeline to automatically push changes to the source code
- Explore logging in OSD
- Experience self healing of applications
- Explore configuration management through configmaps, secrets and environment variables
- Use persistent storage to share data across pod restarts
- Explore networking within Kubernetes and applications
- Familiarization with OpenShift and Kubernetes functionality
- Automatically scale pods based on load via the Horizontal Pod Autoscaler

You’ll be doing the majority of the labs using the OpenShift CLI, but you can also accomplish them using the OpenShift Dedicated web console.
