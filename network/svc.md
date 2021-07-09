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
