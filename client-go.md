# k8s.io/client-go

Programaticly interact with your kubernetes cluster. From the architecture
perspective, all the kubernetes components including `kube-proxy`,
`kube-scheduler`, `kube-controller-manager`, `kubelet`, `kubectl` talks to
`kube-apiserver` by `k8s.io/client-go` sdk. There is no such hidden apis just
invented for the kubernetes itself, that's a very valuable architecture
designing rules.
