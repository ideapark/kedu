# High Availability

- active-active

  1. kube-apiserver

- active-passive

  1. kube-controller-manager
  2. kube-scheduler

- etcd

`2n+1` etcd cluster tolerates simultaneously `n` nodes down

- state

  1. All PKI assets used by the Kubernetes API server

These are typically located in the `/etc/kubernetes/pki` directory.

  2. Any Secret encryption keys

These keys are stored in a static file that is specified with the
`--encryption-provider-config` in the API server parameter. If these
keys are lost, any Secret data is not recoverable.

  3. Any administrator credentials

Most deployment tools (including kubeadm) create static administrator
credentials and provide them in a kubeconfig file.  Although these may
be recreated, securely storing them off-cluster might reduce recovery
time.
