#!/bin/bash

PODNAME="$(kubectl get pods | tail -1 | grep -o '^[^ ]*')"
kubectl exec -it "$PODNAME" -- /bin/bash -c "apk add curl bash && curl https://raw.githubusercontent.com/paperbenni/instantMC/master/kube/reboot.sh | bash"