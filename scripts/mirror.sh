#!/bin/bash
OCP_RELEASE=4.11.22
LOCAL_REGISTRY='quayhost:8443'
LOCAL_REPOSITORY='quay/ocp'
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
