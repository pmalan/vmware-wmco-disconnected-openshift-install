#!/bin/bash
PULL_SECRET_PATH=pull-secret.json
for R in $(cat $PULL_SECRET_PATH | jq -r '.auths|keys[]'); do
  echo "Logging into $R";
  U=$(jq -r ".auths.\"$R\".auth" $PULL_SECRET_PATH | base64 -d | awk -F: '{print $1}')
  P=$(jq -r ".auths.\"$R\".auth" $PULL_SECRET_PATH | base64 -d | awk -F: '{print $2}')
  podman login -u $U -p $P $R
done