# CoreDNS: how the kubernetes dns works

This collection assumed that you have a rough picture why kubernetes have a dns
server, and how the kubernetes service maps to the dns record. For example, you
know that:

```bash
kubectl get service/kubernetes
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d16h
```

You can resolve dns `kubernetes.default.svc.cluster.local` to ip address
`10.96.0.1` from inside your pod running on this cluster. I have another post
explain why this special servce has this special service ip, more refer to
[service_kubernetes.default.md](service_kubernetes.default.md).

Now, let's explore more on the coredns deployment:

```bash
kubectl -n kube-system get deployment/coredns
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   1/1     1            1           13d

kubectl -n kube-system get services/kube-dns
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   13d
```

For historical reasons, the `deployment/coredns` has a service named
`service/kube-dns`, We are more concerned about the dns server ip `10.96.0.10`,
so you could skip this inconsistency.

At this step, we could have a short conclusion that: there's a dns server
running inside our kubernetes cluster, and it's ip is `10.96.0.10`, From inside
the pod running on this cluster, we could lookup this dns server to resolve
cluster service names to service IPs.

```bash
kubectl run alpine -ti --rm --restart=Never --image=alpine:latest -- cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

kubectl run alpine -ti --rm --restart=Never --image=alpine:latest -- wget --no-check-certificate -O /dev/stdout https://kubernetes.default.svc.cluster.local/version
Connecting to kubernetes.default.svc.cluster.local (10.96.0.1:443)

{
  "major": "1",
  "minor": "19",
  "gitVersion": "v1.19.7",
  "gitCommit": "1dd5338295409edcfff11505e7bb246f0d325d15",
  "gitTreeState": "clean",
  "buildDate": "2021-01-13T13:15:20Z",
  "goVersion": "go1.15.5",
  "compiler": "gc",
  "platform": "linux/arm64"
}
```

From the above tests output, we know that we have successfully resolved
`kubernetes.default.svc.cluster.local` to `10.96.0.1`, and we have got a example
request and reply.

I came across two questions:

1. why the `service/kube-dns` has ip `10.96.0.10`
2. how the pod got its `/etc/resolv.conf` written the `nameserver 10.96.0.10`

## The Mysterious Demystified

- kubelet

First, The `kubelet` is responsible for the Pod's dns, we are not covering all
the types of service such headless and host network, please forget about those
edge cases for easy understanding.

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/network/dns/dns.go#L75)

Second, dns server ip address was passed in `kubelet` by configuration.

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/kubelet.go#L509)

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/kubelet.go#L485)

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubelet/app/server.go#L1094)

Third, what's the configuration for the `kubelet`:

```bash
$kubectl -n kube-system get configmap/kubelet-config-1.19 -o yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubelet-config-1.19
  namespace: kube-system
data:
  kubelet: |
    apiVersion: kubelet.config.k8s.io/v1beta1
    authentication:
      anonymous:
        enabled: false
      webhook:
        cacheTTL: 0s
        enabled: true
      x509:
        clientCAFile: /run/config/pki/ca.crt
    authorization:
      mode: Webhook
      webhook:
        cacheAuthorizedTTL: 0s
        cacheUnauthorizedTTL: 0s
    cgroupDriver: cgroupfs
    clusterDNS:
    - 10.96.0.10
    clusterDomain: cluster.local
    cpuManagerReconcilePeriod: 0s
    evictionPressureTransitionPeriod: 0s
    fileCheckFrequency: 0s
    healthzBindAddress: 127.0.0.1
    healthzPort: 10248
    httpCheckFrequency: 0s
    imageMinimumGCAge: 0s
    kind: KubeletConfiguration
    logging: {}
    nodeStatusReportFrequency: 0s
    nodeStatusUpdateFrequency: 0s
    rotateCertificates: true
    runtimeRequestTimeout: 0s
    staticPodPath: /etc/kubernetes/manifests
    streamingConnectionIdleTimeout: 0s
    syncFrequency: 0s
    volumeStatsAggPeriod: 0s
```

Finally, we found it `data.kublet.clusterDNS: [10.96.0.10]`. Note, your
configmap name may not be the same as `configmap/kubelet-config-1.19`.

- deployment/coredns, service/kube-dns

I'm assuming that your cluster was bootstraped by `kubeadm`, let's dig into the
dns bootstrap details.

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubeadm/app/phases/addons/dns/dns.go#L121)

[link to source](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubeadm/app/constants/constants.go#L587)

```go
// GetDNSIP returns a dnsIP, which is 10th IP in svcSubnet CIDR range
func GetDNSIP(svcSubnetList string, isDualStack bool) (net.IP, error) {
	// Get the service subnet CIDR
	svcSubnetCIDR, err := GetKubernetesServiceCIDR(svcSubnetList, isDualStack)
	if err != nil {
		return nil, errors.Wrapf(err, "unable to get internal Kubernetes Service IP from the given service CIDR (%s)", svcSubnetList)
	}

	// Selects the 10th IP in service subnet CIDR range as dnsIP
	dnsIP, err := utilnet.GetIndexedIP(svcSubnetCIDR, 10)
	if err != nil {
		return nil, errors.Wrap(err, "unable to get internal Kubernetes Service IP from the given service CIDR")
	}

	return dnsIP, nil
}
```

Oh, the truth came out, the 10th ip in service ip CIDR range was choosen by
default. The same as the `service/kubernetes` ip choose the 1st ip from service
ip CIDR range.

My final thinking: even kubernetes itself is highly dynamic about many aspects,
such pod/service ip. It was bootstraped by some conventions agreed in advance.
Chicken and egg, we could make a static chicken there, then let it produces egg,
don't ask egg for a chicken.

## Buy me a coffee

- wechat

![wechat](../img/wechat.png)

- alipay

![alipay](../img/alipay.png)
