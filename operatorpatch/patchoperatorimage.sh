#!/bin/bash
export IMAGE_URL=bastion.pietersmalan.com:8443/openshift4-wincw/windows-machine-
config-rhel8-operator:dd60cd8d
podman pull $IMAGE_URL
podman create --name temp_container $IMAGE_URL
podman cp $PWD/containerd_conf.toml temp_container:/payload/containerd/container
d_conf.toml
podman commit temp_container bastion.pietersmalan.com:8443/openshift4-wincw/wind
ows-machine-config-rhel8-operator:patch
podman push bastion.pietersmalan.com:8443/openshift4-wincw/windows-machine-confi
g-rhel8-operator:patch
podman rm temp_container
