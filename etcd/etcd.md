# etcd.io

etcd is a strongly consistent, distributed key-value store that provides a
reliable way to store data that needs to be accessed by a distributed system or
cluster of machines. It gracefully handles leader elections during network
partitions and can tolerate machine failure, even in the leader node.

## kubernetes storage

Copy the follow etcd certificates from the controlplane:

1. `/etc/kubernetes/pki/apiserver-etcd-client.crt`
2. `/etc/kubernetes/pki/apiserver-etcd-client.key`
3. `/etc/kubernetes/pki/etcd/ca.crt`

```bash
# Port forward etcd to localhost
$kubectl -n kube-system port-forward pod/etcd-docker-desktop 2379:2379

# Get all the keys of the current kubernetes cluster
$etcdctl --cacert=ca.crt --cert=apiserver-etcd-client.crt --key=apiserver-etcd-client.key get --prefix --keys-only /
/registry/apiregistration.k8s.io/apiservices/v1.
/registry/apiregistration.k8s.io/apiservices/v1.admissionregistration.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.apiextensions.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.apps
/registry/apiregistration.k8s.io/apiservices/v1.authentication.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.authorization.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.autoscaling
/registry/apiregistration.k8s.io/apiservices/v1.batch
/registry/apiregistration.k8s.io/apiservices/v1.certificates.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.coordination.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.events.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.rbac.authorization.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.scheduling.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.storage.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.admissionregistration.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.apiextensions.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.authentication.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.authorization.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.batch
/registry/apiregistration.k8s.io/apiservices/v1beta1.certificates.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.coordination.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.discovery.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.events.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.extensions
/registry/apiregistration.k8s.io/apiservices/v1beta1.networking.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.node.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.policy
/registry/apiregistration.k8s.io/apiservices/v1beta1.rbac.authorization.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.scheduling.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1beta1.storage.k8s.io
/registry/apiregistration.k8s.io/apiservices/v2beta1.autoscaling
/registry/apiregistration.k8s.io/apiservices/v2beta2.autoscaling
/registry/clusterrolebindings/cluster-admin
/registry/clusterrolebindings/docker-for-desktop-binding
/registry/clusterrolebindings/kubeadm:get-nodes
/registry/clusterrolebindings/kubeadm:kubelet-bootstrap
/registry/clusterrolebindings/kubeadm:node-autoapprove-bootstrap
/registry/clusterrolebindings/kubeadm:node-autoapprove-certificate-rotation
/registry/clusterrolebindings/kubeadm:node-proxier
/registry/clusterrolebindings/storage-provisioner
/registry/clusterrolebindings/system:basic-user
/registry/clusterrolebindings/system:controller:attachdetach-controller
/registry/clusterrolebindings/system:controller:certificate-controller
/registry/clusterrolebindings/system:controller:clusterrole-aggregation-controller
/registry/clusterrolebindings/system:controller:cronjob-controller
/registry/clusterrolebindings/system:controller:daemon-set-controller
/registry/clusterrolebindings/system:controller:deployment-controller
/registry/clusterrolebindings/system:controller:disruption-controller
/registry/clusterrolebindings/system:controller:endpoint-controller
/registry/clusterrolebindings/system:controller:endpointslice-controller
/registry/clusterrolebindings/system:controller:endpointslicemirroring-controller
/registry/clusterrolebindings/system:controller:expand-controller
/registry/clusterrolebindings/system:controller:generic-garbage-collector
/registry/clusterrolebindings/system:controller:horizontal-pod-autoscaler
/registry/clusterrolebindings/system:controller:job-controller
/registry/clusterrolebindings/system:controller:namespace-controller
/registry/clusterrolebindings/system:controller:node-controller
/registry/clusterrolebindings/system:controller:persistent-volume-binder
/registry/clusterrolebindings/system:controller:pod-garbage-collector
/registry/clusterrolebindings/system:controller:pv-protection-controller
/registry/clusterrolebindings/system:controller:pvc-protection-controller
/registry/clusterrolebindings/system:controller:replicaset-controller
/registry/clusterrolebindings/system:controller:replication-controller
/registry/clusterrolebindings/system:controller:resourcequota-controller
/registry/clusterrolebindings/system:controller:route-controller
/registry/clusterrolebindings/system:controller:service-account-controller
/registry/clusterrolebindings/system:controller:service-controller
/registry/clusterrolebindings/system:controller:statefulset-controller
/registry/clusterrolebindings/system:controller:ttl-controller
/registry/clusterrolebindings/system:coredns
/registry/clusterrolebindings/system:discovery
/registry/clusterrolebindings/system:kube-controller-manager
/registry/clusterrolebindings/system:kube-dns
/registry/clusterrolebindings/system:kube-scheduler
/registry/clusterrolebindings/system:node
/registry/clusterrolebindings/system:node-proxier
/registry/clusterrolebindings/system:public-info-viewer
/registry/clusterrolebindings/system:volume-scheduler
/registry/clusterrolebindings/vpnkit-controller
/registry/clusterroles/admin
/registry/clusterroles/cluster-admin
/registry/clusterroles/edit
/registry/clusterroles/kubeadm:get-nodes
/registry/clusterroles/system:aggregate-to-admin
/registry/clusterroles/system:aggregate-to-edit
/registry/clusterroles/system:aggregate-to-view
/registry/clusterroles/system:auth-delegator
/registry/clusterroles/system:basic-user
/registry/clusterroles/system:certificates.k8s.io:certificatesigningrequests:nodeclient
/registry/clusterroles/system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
/registry/clusterroles/system:certificates.k8s.io:kube-apiserver-client-approver
/registry/clusterroles/system:certificates.k8s.io:kube-apiserver-client-kubelet-approver
/registry/clusterroles/system:certificates.k8s.io:kubelet-serving-approver
/registry/clusterroles/system:certificates.k8s.io:legacy-unknown-approver
/registry/clusterroles/system:controller:attachdetach-controller
/registry/clusterroles/system:controller:certificate-controller
/registry/clusterroles/system:controller:clusterrole-aggregation-controller
/registry/clusterroles/system:controller:cronjob-controller
/registry/clusterroles/system:controller:daemon-set-controller
/registry/clusterroles/system:controller:deployment-controller
/registry/clusterroles/system:controller:disruption-controller
/registry/clusterroles/system:controller:endpoint-controller
/registry/clusterroles/system:controller:endpointslice-controller
/registry/clusterroles/system:controller:endpointslicemirroring-controller
/registry/clusterroles/system:controller:expand-controller
/registry/clusterroles/system:controller:generic-garbage-collector
/registry/clusterroles/system:controller:horizontal-pod-autoscaler
/registry/clusterroles/system:controller:job-controller
/registry/clusterroles/system:controller:namespace-controller
/registry/clusterroles/system:controller:node-controller
/registry/clusterroles/system:controller:persistent-volume-binder
/registry/clusterroles/system:controller:pod-garbage-collector
/registry/clusterroles/system:controller:pv-protection-controller
/registry/clusterroles/system:controller:pvc-protection-controller
/registry/clusterroles/system:controller:replicaset-controller
/registry/clusterroles/system:controller:replication-controller
/registry/clusterroles/system:controller:resourcequota-controller
/registry/clusterroles/system:controller:route-controller
/registry/clusterroles/system:controller:service-account-controller
/registry/clusterroles/system:controller:service-controller
/registry/clusterroles/system:controller:statefulset-controller
/registry/clusterroles/system:controller:ttl-controller
/registry/clusterroles/system:coredns
/registry/clusterroles/system:discovery
/registry/clusterroles/system:heapster
/registry/clusterroles/system:kube-aggregator
/registry/clusterroles/system:kube-controller-manager
/registry/clusterroles/system:kube-dns
/registry/clusterroles/system:kube-scheduler
/registry/clusterroles/system:kubelet-api-admin
/registry/clusterroles/system:node
/registry/clusterroles/system:node-bootstrapper
/registry/clusterroles/system:node-problem-detector
/registry/clusterroles/system:node-proxier
/registry/clusterroles/system:persistent-volume-provisioner
/registry/clusterroles/system:public-info-viewer
/registry/clusterroles/system:volume-scheduler
/registry/clusterroles/view
/registry/clusterroles/vpnkit-controller
/registry/configmaps/kube-public/cluster-info
/registry/configmaps/kube-system/coredns
/registry/configmaps/kube-system/extension-apiserver-authentication
/registry/configmaps/kube-system/kube-proxy
/registry/configmaps/kube-system/kubeadm-config
/registry/configmaps/kube-system/kubelet-config-1.19
/registry/controllerrevisions/kube-system/kube-proxy-8cb89d659
/registry/csinodes/docker-desktop
/registry/daemonsets/kube-system/kube-proxy
/registry/deployments/kube-system/coredns
/registry/endpointslices/default/kubernetes
/registry/endpointslices/kube-system/kube-dns-fnnf7
/registry/leases/kube-node-lease/docker-desktop
/registry/leases/kube-system/kube-scheduler
/registry/masterleases/192.168.65.4
/registry/minions/docker-desktop
/registry/namespaces/default
/registry/namespaces/kube-node-lease
/registry/namespaces/kube-public
/registry/namespaces/kube-system
/registry/pods/kube-system/coredns-f9fd979d6-58l5b
/registry/pods/kube-system/coredns-f9fd979d6-5dkgp
/registry/pods/kube-system/etcd-docker-desktop
/registry/pods/kube-system/kube-apiserver-docker-desktop
/registry/pods/kube-system/kube-controller-manager-docker-desktop
/registry/pods/kube-system/kube-proxy-lph2m
/registry/pods/kube-system/kube-scheduler-docker-desktop
/registry/pods/kube-system/storage-provisioner
/registry/pods/kube-system/vpnkit-controller
/registry/priorityclasses/system-cluster-critical
/registry/priorityclasses/system-node-critical
/registry/ranges/serviceips
/registry/ranges/servicenodeports
/registry/replicasets/kube-system/coredns-f9fd979d6
/registry/rolebindings/kube-public/kubeadm:bootstrap-signer-clusterinfo
/registry/rolebindings/kube-public/system:controller:bootstrap-signer
/registry/rolebindings/kube-system/kube-proxy
/registry/rolebindings/kube-system/kubeadm:kubelet-config-1.19
/registry/rolebindings/kube-system/kubeadm:nodes-kubeadm-config
/registry/rolebindings/kube-system/system::extension-apiserver-authentication-reader
/registry/rolebindings/kube-system/system::leader-locking-kube-controller-manager
/registry/rolebindings/kube-system/system::leader-locking-kube-scheduler
/registry/rolebindings/kube-system/system:controller:bootstrap-signer
/registry/rolebindings/kube-system/system:controller:cloud-provider
/registry/rolebindings/kube-system/system:controller:token-cleaner
/registry/roles/kube-public/kubeadm:bootstrap-signer-clusterinfo
/registry/roles/kube-public/system:controller:bootstrap-signer
/registry/roles/kube-system/extension-apiserver-authentication-reader
/registry/roles/kube-system/kube-proxy
/registry/roles/kube-system/kubeadm:kubelet-config-1.19
/registry/roles/kube-system/kubeadm:nodes-kubeadm-config
/registry/roles/kube-system/system::leader-locking-kube-controller-manager
/registry/roles/kube-system/system::leader-locking-kube-scheduler
/registry/roles/kube-system/system:controller:bootstrap-signer
/registry/roles/kube-system/system:controller:cloud-provider
/registry/roles/kube-system/system:controller:token-cleaner
/registry/secrets/default/default-token-s7kdt
/registry/secrets/kube-node-lease/default-token-rrjf8
/registry/secrets/kube-public/default-token-qnvgb
/registry/secrets/kube-system/attachdetach-controller-token-gg4c5
/registry/secrets/kube-system/bootstrap-signer-token-lmpfj
/registry/secrets/kube-system/certificate-controller-token-75ddv
/registry/secrets/kube-system/clusterrole-aggregation-controller-token-lg2fc
/registry/secrets/kube-system/coredns-token-nfcth
/registry/secrets/kube-system/cronjob-controller-token-pjh47
/registry/secrets/kube-system/daemon-set-controller-token-4t97j
/registry/secrets/kube-system/default-token-8bfbm
/registry/secrets/kube-system/deployment-controller-token-zpv9w
/registry/secrets/kube-system/disruption-controller-token-jkngc
/registry/secrets/kube-system/endpoint-controller-token-9f44q
/registry/secrets/kube-system/endpointslice-controller-token-2xvfq
/registry/secrets/kube-system/endpointslicemirroring-controller-token-qfdpx
/registry/secrets/kube-system/expand-controller-token-kmpr7
/registry/secrets/kube-system/generic-garbage-collector-token-cnkhd
/registry/secrets/kube-system/horizontal-pod-autoscaler-token-q8qnc
/registry/secrets/kube-system/job-controller-token-pg8nc
/registry/secrets/kube-system/kube-proxy-token-5p68w
/registry/secrets/kube-system/namespace-controller-token-mdcll
/registry/secrets/kube-system/node-controller-token-j55qv
/registry/secrets/kube-system/persistent-volume-binder-token-thmhx
/registry/secrets/kube-system/pod-garbage-collector-token-7r8qf
/registry/secrets/kube-system/pv-protection-controller-token-8qm86
/registry/secrets/kube-system/pvc-protection-controller-token-qj2nx
/registry/secrets/kube-system/replicaset-controller-token-v6fjl
/registry/secrets/kube-system/replication-controller-token-f8xck
/registry/secrets/kube-system/resourcequota-controller-token-9sckg
/registry/secrets/kube-system/service-account-controller-token-b8pkb
/registry/secrets/kube-system/service-controller-token-pqbtz
/registry/secrets/kube-system/statefulset-controller-token-l2gzg
/registry/secrets/kube-system/storage-provisioner-token-z8z4k
/registry/secrets/kube-system/token-cleaner-token-qvnr5
/registry/secrets/kube-system/ttl-controller-token-l2rwr
/registry/secrets/kube-system/vpnkit-controller-token-xsx2n
/registry/serviceaccounts/default/default
/registry/serviceaccounts/kube-node-lease/default
/registry/serviceaccounts/kube-public/default
/registry/serviceaccounts/kube-system/attachdetach-controller
/registry/serviceaccounts/kube-system/bootstrap-signer
/registry/serviceaccounts/kube-system/certificate-controller
/registry/serviceaccounts/kube-system/clusterrole-aggregation-controller
/registry/serviceaccounts/kube-system/coredns
/registry/serviceaccounts/kube-system/cronjob-controller
/registry/serviceaccounts/kube-system/daemon-set-controller
/registry/serviceaccounts/kube-system/default
/registry/serviceaccounts/kube-system/deployment-controller
/registry/serviceaccounts/kube-system/disruption-controller
/registry/serviceaccounts/kube-system/endpoint-controller
/registry/serviceaccounts/kube-system/endpointslice-controller
/registry/serviceaccounts/kube-system/endpointslicemirroring-controller
/registry/serviceaccounts/kube-system/expand-controller
/registry/serviceaccounts/kube-system/generic-garbage-collector
/registry/serviceaccounts/kube-system/horizontal-pod-autoscaler
/registry/serviceaccounts/kube-system/job-controller
/registry/serviceaccounts/kube-system/kube-proxy
/registry/serviceaccounts/kube-system/namespace-controller
/registry/serviceaccounts/kube-system/node-controller
/registry/serviceaccounts/kube-system/persistent-volume-binder
/registry/serviceaccounts/kube-system/pod-garbage-collector
/registry/serviceaccounts/kube-system/pv-protection-controller
/registry/serviceaccounts/kube-system/pvc-protection-controller
/registry/serviceaccounts/kube-system/replicaset-controller
/registry/serviceaccounts/kube-system/replication-controller
/registry/serviceaccounts/kube-system/resourcequota-controller
/registry/serviceaccounts/kube-system/service-account-controller
/registry/serviceaccounts/kube-system/service-controller
/registry/serviceaccounts/kube-system/statefulset-controller
/registry/serviceaccounts/kube-system/storage-provisioner
/registry/serviceaccounts/kube-system/token-cleaner
/registry/serviceaccounts/kube-system/ttl-controller
/registry/serviceaccounts/kube-system/vpnkit-controller
/registry/services/endpoints/default/kubernetes
/registry/services/endpoints/kube-system/docker.io-hostpath
/registry/services/endpoints/kube-system/kube-dns
/registry/services/endpoints/kube-system/kube-scheduler
/registry/services/specs/default/kubernetes
/registry/services/specs/kube-system/kube-dns
/registry/storageclasses/hostpath
```

The key pattern is like `/registry/[GROUP]/<KIND>/[NAMESPACE]/<NAME>`:

1. `[GROUP]`: apiregistration.k8s.io, istio.io, or omitted for core group
2. `<KIND>`: Pod, Service, Deployment
3. `[NAMESPACE]`: kube-system, kube-public, kube-node-lease, default, or omitted if cluster level
4. `<NAME>`: kube-dns, kube-scheduler, node-controller