# kube-apiserver builtin controllers

In addition to the basics of operating the HTTP RESTful service, the API server
has a few internal services that implement parts of the Kubernetes API.
Generally, these sorts of control loops are run in a separate binary known as
the *kube-controller-manager*. But there are a few control loops that have to be
run inside the *kube-apiserver*.

- apiserverleasegc
- clusterauthenticationtrust
- crdregistration

[more](https://github.com/kubernetes/kubernetes/tree/master/pkg/controlplane/controller)
