# service.spec.clusterIP

This collection explains how a service cluster IP gets allocated.

```bash
$kubectl explain service.spec.clusterIP
KIND:     Service
VERSION:  v1

FIELD:    clusterIP <string>

DESCRIPTION:
     clusterIP is the IP address of the service and is usually assigned
     randomly. If an address is specified manually, is in-range (as per system
     configuration), and is not in use, it will be allocated to the service;
     otherwise creation of the service will fail. This field may not be changed
     through updates unless the type field is also being changed to ExternalName
     (which requires this field to be blank) or the type field is being changed
     from ExternalName (in which case this field may optionally be specified, as
     describe above). Valid values are "None", empty string (""), or a valid IP
     address. Setting this to "None" makes a "headless service" (no virtual IP),
     which is useful when direct endpoint connections are preferred and proxying
     is not required. Only applies to types ClusterIP, NodePort, and
     LoadBalancer. If this field is specified when creating a Service of type
     ExternalName, creation will fail. This field will be wiped when updating a
     Service to type ExternalName. More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
```

## Where the service clusterIP gets allocated

Let's go through the lifecycle of creating a service object:

1. user using kubectl or sdk to provide service object definition to the cluster server
2. kube-apiserver get the request, do some logical on the object
3. kube-apiserver persists this service object into etcd storage
4. kube-proxy wathes this new service object, and reacts to do some iptables rules

First, service clusterIP is not provided by the end user, from the above steps,
we cloud infer that this clusterIP is allocated by the *kube-apiserver* before
it persists service object into etcd storage.

## How the service clusterIP gets allocated

```text
kube-apiserver --service-cluster-ip-range string     A CIDR notation IP range from which to assign service
                                                     cluster IPs. This must not overlap with any IP ranges
                                                     assigned to nodes or pods. Max of two dual-stack CIDRs
                                                     is allowed.
```

The *kube-apiserver* has a command line argument `--service-cluster-ip-range`
that tells what is the service IP range the cluster will allocate from.
