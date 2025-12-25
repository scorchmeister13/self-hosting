### Step CA Initialization
```
$ step ca init

✔ What would you like to name your new PKI? (e.g. Smallstep): Example Inc.
✔ What DNS names or IP addresses would you like to add to your new CA? (e.g. ca.smallstep.com[,1.1.1.1,etc.]): localhost
✔ What address will your new CA listen at? (e.g. :443): 127.0.0.1:8443
✔ What would you like to name the first provisioner for your new CA? (e.g. you@smallstep.com): bob@example.com
✔ What do you want your password to be? [leave empty and we will generate one]: abc123

Generating root certificate...
all done!

Generating intermediate certificate...
all done!

✔ Root certificate: /Users/bob/.step/certs/root_ca.crt
✔ Root private key: /Users/bob/.step/secrets/root_ca_key
✔ Root fingerprint: 702a094e239c9eec6f0dcd0a5f65e595bf7ed6614012825c5fe3d1ae1b2fd6ee
✔ Intermediate certificate: /Users/bob/.step/certs/intermediate_ca.crt
✔ Intermediate private key: /Users/bob/.step/secrets/intermediate_ca_key
✔ Default configuration: /Users/bob/.step/config/defaults.json
✔ Certificate Authority configuration: /Users/bob/.step/config/ca.json

Your PKI is ready to go.
```