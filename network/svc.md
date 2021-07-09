# Kubernetes Service

## Normal Service

- w/ selector

Endpoints controller will create endpoints according to the service
selector.

```bash
$kubectl get service/kubernetes -o yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2021-06-13T18:31:43Z"
  labels:
    component: apiserver
    provider: kubernetes
  name: kubernetes
  namespace: default
  resourceVersion: "204"
  uid: f77a3761-6849-4801-88fd-76a6bd789e7e
spec:
  clusterIP: 10.96.0.1
  clusterIPs:
  - 10.96.0.1
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: 6443
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

```bash
$kubectl get endpoints/kubernetes -o yaml
apiVersion: v1
kind: Endpoints
metadata:
  creationTimestamp: "2021-06-13T18:31:43Z"
  labels:
    endpointslice.kubernetes.io/skip-mirror: "true"
  name: kubernetes
  namespace: default
  resourceVersion: "208"
  uid: deae9e7d-245c-48c7-a2e5-32f30c994556
subsets:
- addresses:
  - ip: 192.168.65.4
  ports:
  - name: https
    port: 6443
    protocol: TCP
```

- w/o selector

No endpoints will be created automatically, users create endpoints by
hand such as a endpoint points to an external database.

## Headless Service

Sometimes you don't need load-balancing and a single Service IP. In
this case, you can create what are termed "headless" Services, by
explicitly specifying "None" for the cluster IP (.spec.clusterIP).

You can use a headless Service to interface with other service
discovery mechanisms, without being tied to Kubernetes'
implementation.

For headless Services, a cluster IP is not allocated, kube-proxy does
not handle these Services, and there is no load balancing or proxying
done by the platform for them. How DNS is automatically configured
depends on whether the Service has selectors defined:

- w/ selector

For headless Services that define selectors, the endpoints controller
creates Endpoints records in the API, and modifies the DNS
configuration to return A records (IP addresses) that point directly
to the Pods backing the Service.

- w/o selector

For headless Services that do not define selectors, the endpoints
controller does not create Endpoints records. However, the DNS system
looks for and configures either:

  * CNAME records for ExternalName-type Services.
  * A records for any Endpoints that share a name with the Service, for all other types.

## Service Type

```bash
kubectl explain service.spec.type
KIND:     Service
VERSION:  v1

FIELD:    type <string>

DESCRIPTION:
     type determines how the Service is exposed. Defaults to ClusterIP. Valid
     options are ExternalName, ClusterIP, NodePort, and LoadBalancer.
     "ClusterIP" allocates a cluster-internal IP address for load-balancing to
     endpoints. Endpoints are determined by the selector or if that is not
     specified, by manual construction of an Endpoints object or EndpointSlice
     objects. If clusterIP is "None", no virtual IP is allocated and the
     endpoints are published as a set of endpoints rather than a virtual IP.
     "NodePort" builds on ClusterIP and allocates a port on every node which
     routes to the same endpoints as the clusterIP. "LoadBalancer" builds on
     NodePort and creates an external load-balancer (if supported in the current
     cloud) which routes to the same endpoints as the clusterIP. "ExternalName"
     aliases this service to the specified externalName. Several other fields do
     not apply to ExternalName services. More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
```

- ClusterIP

Exposes the Service on a cluster-internal IP. Choosing this value
makes the Service only reachable from within the cluster. This is the
default ServiceType.

- NodePort

Exposes the Service on each Node's IP at a static port (the
NodePort). A ClusterIP Service, to which the NodePort Service routes,
is automatically created. You'll be able to contact the NodePort
Service, from outside the cluster, by requesting `<NodeIP>:<NodePort>`.

- LoadBalancer

Exposes the Service externally using a cloud provider's load
balancer. NodePort and ClusterIP Services, to which the external load
balancer routes, are automatically created.

- ExternalName

Maps the Service to the contents of the externalName field
(e.g. foo.bar.example.com), by returning a CNAME record with its
value. No proxying of any kind is set up.
