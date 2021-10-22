# Extending Kubernetes

- cluster daemons for automation

Such as monitoring and logging agents, they can be created as
DaemonSet kubernetes objects. But we should notice that our users will
quickly come to rely on them, and thus the operational importance of
cluster daemon add-ons can be significant. Also, the daemon objects
lifecycle will be bound to the cluster lifecycle.

- cluster assistants for extended functionality

Cluster assistants are quite similar to cluster daemons, but unlike
cluster daemons, in which functionality is automatically enabled for
all users of the cluster, a cluster assistant requires the user to
provide some configuration or other gesture to opt in to the
functionality provided by the assistant. Rather than providing
automatic experiences, cluster assistants provide enriched, yet easily
accessible, functionality to users of the cluster, but it is
functionality that the user must be aware of and must provide
appropriate information to enable.

e,g. there is an unauthenciated service running inside cluster, and
service has a special annotation such as
`managed.ideapark.io/authentication-secret: httppasswd-secret`. Our
cluster assistant could watch this special service, and create a
deployment running nginx and configure nginx using password file
specified by the upstream service annotation. Then we can expose this
service outside securely.

- extending the lifecycle of the kube-apiserver

1. ValidatingAdmissionWebhook
2. Mutatingadmissionwebhook

- adding more APIs

Sometimes, you want to add entirely new API resource types to your
cluster.

1. CustomResourceDefinition (CRD)

It involves using the Kubernetes API itself to add new types to
Kubernetes. All of the storage and API serving associated with the new
custom type are handled by Kubernetes itself.

2. Aggregated APIServer

Kubernetes also supports API delegation, in which the complete API
call, including the storage, of the resources is delegated to an
alternate server. This enables the extension to implement an
arbitrarily complex API, but it also comes with significant
operational complexity, especially the need to manage your own
storage.
