# Kubernetes Education

![logo](logo.png)

> "Simplicity is a great virtue but it requires hard work to achieve it and
> education to appreciate it. And to make matters worse: complexity sells
> better." - Edsger W. Dijkstra

This is a series of collections that explain the internals of
*Kubernetes*. Only have we understood the complexity under the cover,
can we really appreciate the simplicity of *Kubernetes*.

Kubernetes starts from the small core concepts: *pods*, *replicasets*,
*services*. From the bottom to up, we have *deployments*,
*daemonsets*, *jobs*, *cronjobs*, etc. Those objects are the base of
more higher level concepts like *etcd cluster*. On the other
direction, pods are built from smaller concept of *container*, and
*container* is built from *isolations and namespaces*. I strongly
suggest you have this picture in your mind.

- [client-go](client-go)
- [kube-apiserver](kube-apiserver)
- [kube-scheduler](kube-scheduler)
- [kube-proxy](kube-proxy)
- [kubeadm](kubeadm)
- [kubectl](kubectl)
- [kubelet](kubelet)
- [network](network)
- [addon](addon)
- [ha](ha)
- [coredns](coredns)
- [etcd](etcd)
- [docker](docker)
- [ext](ext)
- [thirdparty](thirdparty)

[GitHub](https://github.com/ideapark/kedu)
