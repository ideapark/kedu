# Endpoints

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
