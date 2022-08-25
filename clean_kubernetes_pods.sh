#!/bin/bash
kubectl get po --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
kubectl get po --all-namespaces --field-selector 'status.phase==Evicted' -o json | kubectl delete -f -
kubectl get po --all-namespaces --field-selector 'status.phase==Pending' -o json | kubectl delete -f -
kubectl get po --all-namespaces --field-selector 'status.phase==Succeeded' -o json | kubectl delete -f -

