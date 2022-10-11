# VMWare IPI with Windows Machine Operator in a disconnected Openshift

## Preparation

### Standard Openshift preparation
- DNS
- DHCP

#### Setup Quay Mirror Registry
1. Download Quay Mirror Registry - https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz
2. Get a signed certificate, wild card certs does work.
3. Prepare a user on target machine to host Quay
  1. Make sure the user has sudo priviledges (visudo + wheel group)
  2. As the user do the following:
      
      ssh-keygen
      
      ssh-copy-id quayhostname
      
      sudo ./mirror-registry install -initUser quay --initPassword quayquay --quayHostname quayhostname --sslCert cert.pem --sslKey privkey.pem 
     
   3. Create a new repository to host the mirror, using the web interface. In the following example I am using "ocp"

#### Setup Mirror process
1. Download the Openshift Installer, client and mirror plugin:
  
      mkdir ~/bin
  
      cd ~/bin
  
      wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-install-linux.tar.gz
  
      wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/oc-mirror.tar.gz
  
      wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
  
      tar xvf openshift-client-linux.tar.gz
  
      tar xvf openshift-install-linux.tar.gz
  
      tar xvf oc-mirror.tar.gz
  
  

2. Configure security for pulling and pushing images:

      mkdir ~/mirror
      cd ~/mirror
      <put your pullsecret copied form https://console.redhat.com/openshift/downloads in a file called pull-secret>
      cat ./pull-secret | jq . > pull-secret.json
      echo -n '<quay>:<quayquay>' | base64 -w0
      
      Append the list of auths by adding the following to pull-secret.json, credentails is the output from the last eco command:
      
      "auths": {
        "<mirror_registry>": { 
          "auth": "<credentials>", 
          "email": "you@example.com"
      },
      
3. Create the following script, update required values OCP_RELEASE and LOCAL_REPOSITORY (from step 3 from setting up Quay). 
   Also comment out the relevant commands if you are going to use a fully disconnected Quay mirror.
   OCP_RELEASE can be obtained by running "oc version"

    OCP_RELEASE=4.11.22
    LOCAL_REGISTRY='quayhost:8443'
    LOCAL_REPOSITORY='ocp/ocp411'
    LOCAL_SECRET_JSON='pull-secret.json'
    PRODUCT_REPO='openshift-release-dev'
    RELEASE_NAME='ocp-release'
    ARCHITECTURE=x86_64
    REMOVABLE_MEDIA_PATH=$PWD/dump/

    # Example to extract to local directory, to dump the images, transfer and use following command on remote to import
    #oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}

    # Example to upload images from local directory, in the case of total disconnected install 
    #oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}

    # Registry to Registry mirror process
    oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}

    #oc adm release extract -a ${LOCAL_SECRET_JSON} --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}"

4. Capture the output, of the mirror command. At the bottom take note of the 2 sets of configuration:

[openshift@bastion mirror]$ . ./mirror.sh 
info: Mirroring 172 images to bastion.pietersmalan.com:8443/quay/ocp ...
bastion.pietersmalan.com:8443/
  quay/ocp
    blobs:
......
phase 0:
  bastion.pietersmalan.com:8443 quay/ocp blobs=351 mounts=0 manifests=172 shared=5

info: Planning completed in 33.71s
......
info: Mirroring completed in 2m31.1s (96.06MB/s)

Success
Update image:  bastion.pietersmalan.com:8443/quay/ocp:4.11.7-x86_64
Mirror prefix: bastion.pietersmalan.com:8443/quay/ocp
Mirror prefix: bastion.pietersmalan.com:8443/quay/ocp:4.11.7-x86_64

To use the new mirrored repository to install, add the following section to the install-config.yaml:

imageContentSources:
- mirrors:
  - bastion.pietersmalan.com:8443/quay/ocp
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - bastion.pietersmalan.com:8443/quay/ocp
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev


To use the new mirrored repository for upgrades, use the following to create an ImageContentSourcePolicy:

apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: example
spec:
  repositoryDigestMirrors:
  - mirrors:
    - bastion.pietersmalan.com:8443/quay/ocp
    source: quay.io/openshift-release-dev/ocp-release
  - mirrors:
    - bastion.pietersmalan.com:8443/quay/ocp
    source: quay.io/openshift-release-dev/ocp-v4.0-art-dev



