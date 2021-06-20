# kube-scheduler

- Overview

When a Pod is first created, it generally doesn’t have a nodeName field. The
nodeName indicates the node on which the Pod should execute. The Kubernetes
scheduler is constantly scanning the API server (via a watch request) for Pods
that don’t have a nodeName; these are Pods that are eligible for scheduling. The
scheduler then selects an appropriate node for the Pod and updates the Pod
definition with the nodeName that the scheduler selected. After the nodeName is
set, the kubelet running on that node is notified about the Pod’s existence
(again, via a watch request) and it begins to actually execute that Pod on that
node.
