# k8s.io/client-go

Programaticly interact with your kubernetes cluster. From the architecture
perspective, all the kubernetes components including `kube-proxy`,
`kube-scheduler`, `kube-controller-manager`, `kubelet`, `kubectl` talks to
`kube-apiserver` by `k8s.io/client-go` sdk. There is no such hidden apis just
invented for the kubernetes itself, that's a very valuable architecture
designing rules.

## client-go

- discovery

Discovery provides ways to discover server-supported API groups, versions and
resources.

- kubernetes

Interfaces of all the kubernetes builtin api objects.

- scale

Scale provides a polymorphic scale client capable of fetching and
updating Scale for any resource which implements the `scale`
subresource, as long as that subresource operates on a version of
scale convertable to `autoscaling.Scale`.

- lister

List kubernetes builtin api objects

- informer

Kubernetes api objects lifecycle event driven progamming. In another words,
watch api objects and react more quickly.

- Others

1. Legacy non-typed kubernetes client
2. Tools utility
3. Network transport
4. Third party authentication plugin
