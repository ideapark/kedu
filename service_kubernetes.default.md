# Demystify Service kubernetes.default.svc.cluster.local

Have you ever paid attention to a special service located at default namespace?
Yes, I am talking about the service `kubernetes.default.svc.cluster.local`. In
this collection, I will walk you through the unknown side of this special
service.

## Why is it special?

Please spin up a fresh kubernetes cluster using
[`Kind`](https://kind.sigs.k8s.io/) or [`Docker Desktop`](https://www.docker.com/products/docker-desktop) (as is my case).

```bash
$ kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d11h
```

We found the following questions:

1. its name is `kubernetes` and located in namespace `default`
2. it's the first service created by the kubernetes itself
3. it's ip is of type ClusterIP and the value is `10.96.0.1`
4. it's port is 443, seems like a https endpoint
5. it's `2d11h` old

## Explain technology details in the underground

First, this service is used to expose the kubernetes cluster's `kube-apiserver`
to be comsumed by any authorized and authenticated user (I means programmer like
you) or program (pods running inside this cluster). So the first question is
almost clear that it was choosen by purpose, to be widely known (for the name
`kubernetes`) and accessable (for the namespace `default`).

Second, let's do something evil:

```bash
$ kubectl delete all --all
service "kubernetes" deleted

$ kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   1s
```

The service was deleted, but created automatically again! A clerver guy may
quickly speak out that: I know, it's the controller. But keep this in mind that
there is no such service controller in the `kube-controller-manager` component.
Instead, the controller is running in the `kube-apiserver`.

[link to source](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/controller.go#L51)

Keep going through the source, you could find that the `kubernetes` service ip
was passed in here:

[link to source](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/controller.go#L121)

And dig further, I found if the `kube-apiserver` was not passed in this ip or ip
is not in service ip range, it will pick the first ip address (`10.96.0.1`) from
the service ip range (as is our case is `10.96.0.0/16`).

[link to source](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/instance.go#L304)

[link to source](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/services.go#L47)

The other questions should be self-explanatory now, that's the complexity behind
the simplicity `kubernetes.default.svc.cluster.local`.

## Buy me a coffee

- wechat

![wechat](assets/wechat.png)

- alipay

![alipay](assets/alipay.png)
