## Prerequisites

#### 1. OC Command Line Interface
You will need to [download and install](https://docs.openshift.com/dedicated/cli_reference/get_started_cli.html#installing-the-cli) the latest OpenShift CLI (oc).  

> **NOTE:** You can access the command line tools page by clicking on the *Questionmark > Command Line Tools*:

![CLI Tools](images/0-cli_tools_page.png)

**Why use `oc` over `kubectl`**<br>
Being Kubernetes, one can definitely use `kubectl` with their OpenShift cluster.  `oc` is specific to OpenShift in that it includes the standard set of features from `kubectl` plus additional support for OpenShift functionality.  See [Differences between OC and Kubectl](https://docs.openshift.com/container-platform/3.11/cli_reference/differences_oc_kubectl.html) for more details.

#### 2. A GitHub Account
You will need your own GitHub account for some portions of this lab.  If you do not already have a GitHub account please visit <https://github.com/join> to create your account.

#### 3. Install Git
Install Git on your workstation.  See the official [Git documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for instructions per your workstation’s operating system.
