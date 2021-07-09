# CNI: container network interface

`IP-PER-Pod`, every pod gets allocated an IP address, and the CNI plugin
is responsible for its allocation and assignment to a Pod.

The container runtime (e.g., Docker) calls the CNI plug-in executable
(e.g., Calico) to add or remove an interface to or from the
container’s networking namespace.

> There is a pause container in every Pod, it does nothing meaningful
> computationally. They merely serve as placeholders for each Pod’s
> container network. As such, they are the first container to be
> launched and the last to die in the life cycle of an individual Pod.

In addition to connecting a container to a network, CNI has
capabilities for IP Address Management (IPAM). IPAM ensures that CNI
always has a clear picture of which addresses are in use, as well as
those that are available for configuration of new interfaces.

## How to choose a network plugin

1. what is the topology of your network

The topology of your network dictates a large part of what you are
ultimately able to deploy within your environment. For instance, if
you are deploying to multiple availability zones within a public
cloud, you likely need to implement a plug-in that has support for
some form of encapsulation (also known as an overlay network).

2. which features are imperative for you organization

You need to consider which features are important for your
deployment. If there are hard requirements for mutual TLS between
Pods, you may want to use a plug-in that provides this capability. By
the same token, not every plug-in provides support for
NetworkPolicy. Be sure to evaluate the features that are offered by
the plug-in before you deploy your cluster.
