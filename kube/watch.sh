#!/bin/bash

PODNAME="$(kubectl get pods | tail -1 | grep -o '^[^ ]*')"
export TERM=xterm
