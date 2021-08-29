# Endpoints

Endpoints represent a service endpoint. for example, a nginx instance
port tcp:80. A kubernetes service may have many endpoints backing it,
these endpoints will come and go, but the service is stable from the
point of the service consumer.

Endpoints are tightly coupled with Service, Kubernetes will
create/delete endpoints when service create/delete respectively. You
can also create it by hand. but these endpoints' life-cycle are not
managed by the endpoint controller.

Service and endpoints together will be watched by the `kube-proxy`,
and used to manage the iptables rules to do NAT from service IP to
endpoints IP.

# EndpointSlice

*EndpointSlices* provide a more scalable and extensible way to track
network endpoints.

Since all the network endpoints for a service were stored in a single
Endpoints resource, those resources could get quite large. That
affected the performance of Kubernetes components (notably the control
plane) and resulted in significant amounts of network traffic and
processing when Endpoints changed. EndpointSlices help you mitigate
those issues as well as provide an extensible platform for additional
features such as topological routing.

``` shell
$ kubectl get endpointslice/kedu-m99cs -o yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  namespace: default
  generateName: kedu-
  name: kedu-m99cs
  labels:
    app: kedu
    endpointslice.kubernetes.io/managed-by: endpointslice-controller.k8s.io
    kubernetes.io/service-name: kedu
  ownerReferences:
  - apiVersion: v1
    blockOwnerDeletion: true
    controller: true
    kind: Service
    name: kedu
addressType: IPv4
ports:
- name: ""
  port: 8080
  protocol: TCP
endpoints:
- addresses:
  - 10.1.1.20
  conditions:
    ready: true
  nodeName: docker-desktop
  targetRef:
    kind: Pod
    name: kedu-6cffc79f4-6rcf2
    namespace: default
```

`endpointslice.kubernetes.io/managed-by`, which indicates the entity
managing an EndpointSlice. The endpoint slice controller sets
`endpointslice-controller.k8s.io` as the value for this label on all
EndpointSlices it manages. Other entities managing EndpointSlices
should also set a unique value for this label.

`kubernetes.io/service-name` indicates ownership of the EndpointSlice.

# EndpointSlice mirroring

In some cases, applications create custom `Endpoints` resources. To
ensure that these applications do not need to concurrently write to
both `Endpoints` and `EndpointSlice` resources, the cluster's control
plane mirrors most `Endpoints` resources to corresponding
`EndpointSlices`.

The control plane mirrors `Endpoints` resources unless:

1. the Endpoints resource has a `endpointslice.kubernetes.io/skip-mirror` label set to true.
2. the Endpoints resource has a `control-plane.alpha.kubernetes.io/leader` annotation.
3. the corresponding Service resource does not exist.
4. the corresponding Service resource has a non-nil selector.

The control plane tries to fill `EndpointSlices` as full as possible,
but does not actively rebalance them. The logic is fairly
straightforward:

1. Iterate through existing `EndpointSlices`, remove `endpoints` that are no longer desired and update matching `endpoints` that have changed.
2. Iterate through `EndpointSlices` that have been modified in the first step and fill them up with any new `endpoints` needed.
3. If there's still new `endpoints` left to add, try to fit them into a previously unchanged slice and/or create new ones.

Importantly, the third step prioritizes limiting `EndpointSlice`
updates over a perfectly full distribution of `EndpointSlices`. As an
example, if there are 10 new endpoints to add and 2 `EndpointSlices`
with room for 5 more endpoints each, this approach will create a new
`EndpointSlice` instead of filling up the 2 existing
`EndpointSlices`. In other words, a single `EndpointSlice` creation is
preferrable to multiple `EndpointSlice` updates.
