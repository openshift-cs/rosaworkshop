<script async defer src="https://buttons.github.io/buttons.js"></script>
## Leveraging source-to-image (S2I) webhooks for CICD
If we'd like to automatically trigger a build and deploy anytime we change the source code we can do that by using a webhook.

See [Triggering Builds](https://docs.openshift.com/dedicated/3/dev_guide/builds/triggering_builds.html) for more details

#### 1. Fork the repository
In order to trigger S2I builds when you push code into your GitHib repo, you’ll need to setup the GitHub webhook.  And in order to setup the webhooks, you’ll first need to fork the application into your personal GitHub repository.

<!-- Place this tag where you want the button to render. -->
<a class="github-button" href="https://github.com/openshift-cs/ostoy/fork" data-icon="octicon-repo-forked" data-size="large" aria-label="Fork openshift-cs/ostoy on GitHub">Fork</a>

#### 2. Get trigger secret
Retrieve the GitHub webhook trigger secret using the command below. You’ll need use this secret in the GitHub webhook URL.

`oc get bc ostoy -o=jsonpath='{.spec.triggers..github.secret}'`

You will get a response similar to:
```$ oc get bc ostoy -o=jsonpath='{.spec.triggers..github.secret}'
o_3x9M1qoI2Wj_czRWiK```

Note the secret as you will need to use it shortly.

#### 3. Retrieve the GitHub webhook trigger URL
You will need to get the GitHub webhook trigger url from the buildconfig.  Use following command to retrieve it

`oc describe bc ostoy`

You will get a response with much data but look for the line that looks like

```
Webhook GitHub:
	URL:	https://api.demo1234.openshift.com:443/apis/build.openshift.io/v1/namespaces/ostoy-s2i/buildconfigs/ostoy/webhooks/<secret>/github
```
#### 4. Replace the secret
In the URL retrieved in the last step replace the `<secret>` text with the actual secret you recieved in step 2 above.  Your URL will look like:

`https://api.demo1234.openshift.com:443/apis/build.openshift.io/v1/namespaces/ostoy-s2i/buildconfigs/ostoy/webhooks/o_3x9M1qoI2Wj_czRWiK/github`

#### 5. Setup webhook URL in GitHub repository
