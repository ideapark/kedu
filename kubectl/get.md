# The lifecycle of `kubectl get all`

## A quick overview

```bash
$kubectl -v=6 get all
I0612 22:23:02.481509   63898 loader.go:372] Config loaded from file:  /Users/park/.kube/config
I0612 22:23:02.505277   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/api/v1/namespaces/default/pods?limit=500 200 OK in 14 milliseconds
I0612 22:23:02.508702   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/api/v1/namespaces/default/replicationcontrollers?limit=500 200 OK in 3 milliseconds
I0612 22:23:02.511794   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/api/v1/namespaces/default/services?limit=500 200 OK in 3 milliseconds
I0612 22:23:02.515644   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/apps/v1/namespaces/default/daemonsets?limit=500 200 OK in 3 milliseconds
I0612 22:23:02.518787   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/apps/v1/namespaces/default/deployments?limit=500 200 OK in 3 milliseconds
I0612 22:23:02.521967   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/apps/v1/namespaces/default/replicasets?limit=500 200 OK in 3 milliseconds
I0612 22:23:02.524796   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/apps/v1/namespaces/default/statefulsets?limit=500 200 OK in 2 milliseconds
I0612 22:23:02.527421   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/autoscaling/v1/namespaces/default/horizontalpodautoscalers?limit=500 200 OK in 2 milliseconds
I0612 22:23:02.529131   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/batch/v1/namespaces/default/cronjobs?limit=500 200 OK in 1 milliseconds
I0612 22:23:02.530539   63898 round_trippers.go:454] GET https://kubernetes.docker.internal:6443/apis/batch/v1/namespaces/default/jobs?limit=500 200 OK in 1 milliseconds
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   22h
```

kubectl has the follow steps:

1. load configuration to discovery cluster, authenticate as the identity defined in the config file
2. explain `all` to the real kubernetes resources like pod, replicationcontroller, service, daemonset, deployment, ...
3. request each resources from the cluster server
4. print out the response resource objects

Let's walk through the above 4 steps in details, note that we will not touch the
internals of cluster server, we only care the kubectl client specific details.

## `./kube/config`

## all to kubernetes resources

## get pod

## print pod objects
