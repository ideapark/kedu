# Kubernetes DNS: Make It Work Right & Fast

## Testing Environment

```bash
$ uname -a
Linux ideapark.local 4.19.114-1-MANJARO #1 SMP Thu Apr 2 17:04:36 UTC 2020 x86_64 GNU/Linux

$ kubectl version --short
Client Version: v1.17.0
Server Version: v1.17.0
```

## How DNS works

- /etc/resolv.conf

```text
search corporate.example.com
nameserver 10.202.4.4
nameserver 10.205.4.2
```

- nslookup -ndots=5 -debug www.google.com

> NOTE: We have set the `-ndots=5`, which is the same effect `options ndots:5`
> from `/etc/resolv.conf` (Kubernetes Pod's `/etc/resolv.conf` has this option
> by default)

```bash
$ nslookup -ndots=5 -debug www.google.com
Server:		10.202.4.4
Address:	10.202.4.4#53

------------
    QUESTIONS:
	www.google.com.corporate.example.com, type = A, class = IN
    ANSWERS:
    AUTHORITY RECORDS:
    ->  corporate.example.com
	origin = xdcdc01.corporate.example.com
	mail addr = hostmaster.corporate.example.com
	serial = 4928290
	refresh = 900
	retry = 600
	expire = 86400
	minimum = 3600
	ttl = 1481
    ADDITIONAL RECORDS:
------------
** server can't find www.google.com.corporate.example.com: NXDOMAIN
Server:		10.202.4.4
Address:	10.202.4.4#53

------------
    QUESTIONS:
	www.google.com, type = A, class = IN
    ANSWERS:
    ->  www.google.com
	internet address = 216.58.200.68
	ttl = 214
    AUTHORITY RECORDS:
    ADDITIONAL RECORDS:
------------
Non-authoritative answer:
Name:	www.google.com
Address: 216.58.200.68
------------
    QUESTIONS:
	www.google.com, type = AAAA, class = IN
    ANSWERS:
    ->  www.google.com
	has AAAA address 2404:6800:4005:80e::2004
	ttl = 235
    AUTHORITY RECORDS:
    ADDITIONAL RECORDS:
------------
Name:	www.google.com
Address: 2404:6800:4005:80e::2004
```

### What we learned

> `/etc/resolv.conf` `search corporate.example.com` and `options ndots:5`
> together make this dns query retry one by one.

## Kubernetes

POD: `dnsutils` runs on NODE: `local-control-plane`

```bash
$ kubectl get nodes -o wide
NAME                  STATUS   ROLES    AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION       CONTAINER-RUNTIME
local-control-plane   Ready    master   4d10h   v1.17.0   192.168.100.2   <none>        Ubuntu 19.10   4.19.113-1-MANJARO   containerd://1.3.2

$ kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE                  NOMINATED NODE   READINESS GATES
dnsutils   1/1     Running   0          14h   10.244.0.7   local-control-plane   <none>           <none>
```

- NODE's `/etc/resolv.conf`

```bash
$ cat /etc/resolv.conf
search corporate.example.com
nameserver 10.202.4.4
nameserver 10.205.4.2
```

- POD's `/etc/resolv.conf` (**pod.spec.dnsPolicy=ClusterFirst**)

```bash
$ kubectl exec -ti pod/dnsutils -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local corporate.example.com
nameserver 10.96.0.10
options ndots:5
```

### What we learned

> Node's `search corporate.example.com` (differ at your machine) will be
> appended to the Pod's `/etc/resolv.conf` `search default.svc.cluster.local
> svc.cluster.local cluster.local corporate.example.com`

See [dns.go](https://github.com/kubernetes/kubernetes/blob/db999c96343c10e83d72ff4bb82e775f09edf0a6/pkg/kubelet/network/dns/dns.go#L155)

- DNS query from the pod

```bash
$ kubectl exec -ti pod/dnsutils -- nslookup -debug www.google.com
Server:		10.96.0.10
Address:	10.96.0.10#53

------------
    QUESTIONS:
	www.google.com.default.svc.cluster.local, type = A, class = IN
    ANSWERS:
    AUTHORITY RECORDS:
    ->  cluster.local
	origin = ns.dns.cluster.local
	mail addr = hostmaster.cluster.local
	serial = 1586870456
	refresh = 7200
	retry = 1800
	expire = 86400
	minimum = 30
	ttl = 30
    ADDITIONAL RECORDS:
------------
** server can't find www.google.com.default.svc.cluster.local: NXDOMAIN
Server:		10.96.0.10
Address:	10.96.0.10#53

------------
    QUESTIONS:
	www.google.com.svc.cluster.local, type = A, class = IN
    ANSWERS:
    AUTHORITY RECORDS:
    ->  cluster.local
	origin = ns.dns.cluster.local
	mail addr = hostmaster.cluster.local
	serial = 1586870456
	refresh = 7200
	retry = 1800
	expire = 86400
	minimum = 30
	ttl = 30
    ADDITIONAL RECORDS:
------------
** server can't find www.google.com.svc.cluster.local: NXDOMAIN
Server:		10.96.0.10
Address:	10.96.0.10#53

------------
    QUESTIONS:
	www.google.com.cluster.local, type = A, class = IN
    ANSWERS:
    AUTHORITY RECORDS:
    ->  cluster.local
	origin = ns.dns.cluster.local
	mail addr = hostmaster.cluster.local
	serial = 1586870456
	refresh = 7200
	retry = 1800
	expire = 86400
	minimum = 30
	ttl = 30
    ADDITIONAL RECORDS:
------------
** server can't find www.google.com.cluster.local: NXDOMAIN
Server:		10.96.0.10
Address:	10.96.0.10#53

------------
    QUESTIONS:
	www.google.com.corporate.example.com, type = A, class = IN
    ANSWERS:
    AUTHORITY RECORDS:
    ->  .
	origin = a.root-servers.net
	mail addr = nstld.verisign-grs.com
	serial = 2020041500
	refresh = 1800
	retry = 900
	expire = 604800
	minimum = 86400
	ttl = 30
    ADDITIONAL RECORDS:
------------
** server can't find www.google.com.corporate.example.com: NXDOMAIN
Server:		10.96.0.10
Address:	10.96.0.10#53

------------
    QUESTIONS:
	www.google.com, type = A, class = IN
    ANSWERS:
    ->  www.google.com
	internet address = 216.58.197.100
	ttl = 30
    AUTHORITY RECORDS:
    ADDITIONAL RECORDS:
------------
Non-authoritative answer:
Name:	www.google.com
Address: 216.58.197.100

command terminated with exit code 1
```

### What we learned

> Inside the Pod, DNS query retry one by one from the search list. Nothing
> different with the regular non-container environment.

## Kubernetes CoreDNS

- Pod's `/etc/resolv.conf`

```bash
$ kubectl exec -ti pod/dnsutils -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local corporate.example.com
nameserver 10.96.0.10
options ndots:5
```

- CoreDNS Service

```bash
$ kubectl -n kube-system get services -o wide
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE     SELECTOR
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   4d11h   k8s-app=kube-dns

$ kubectl -n kube-system get deployment/coredns -o wide
NAME      READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                     SELECTOR
coredns   1/1     1            1           4d11h   coredns      k8s.gcr.io/coredns:1.6.5   k8s-app=kube-dns
```

### What we learned

> Pod's DNS query will be routed to CoreDNS, now we go to see how CoreDNS handle
> DNS query.

- CoreDNS `/etc/resolv.conf`

> NOTE: deployment/coredns has `deployment.spec.template.spec.dnsPolicy:
> Default`, which means that Node's `/etc/resolv.conf` which the CoreDNS Pod
> runs on will be used as CoreDNS's upstream.
> See [dns.go](https://github.com/kubernetes/kubernetes/blob/db999c96343c10e83d72ff4bb82e775f09edf0a6/pkg/kubelet/network/dns/dns.go#L332)

```bash
$ kubectl -n kube-system get deployment/coredns -o template --template="{{.spec.template.spec.dnsPolicy}}{{println}}"
Default

$ kubectl -n kube-system exec -ti deployment/coredns -- cat /etc/resolv.conf
search corporate.example.com
nameserver 10.202.4.4
nameserver 10.205.4.2
```

- CoreDNS `/etc/coredns/Corefile`

Enable `INFO` logs

```bash
$ kubectl -n kube-system get configmap/coredns -o template --template="{{.data.Corefile}}"
.:53 {
    logs
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
```

- DNS queries got retried at the server side

```bash
$ kubectl exec -ti pod/dnsutils -- nslookup www.google.com
Server:		10.96.0.10
Address:	10.96.0.10#53

Non-authoritative answer:
Name:	www.google.com
Address: 172.217.161.132

$ kubectl -n kube-system logs deployment/coredns
.:53
[INFO] plugin/reload: Running configuration MD5 = a4809ab99f6713c362194263016e6fac
CoreDNS-1.6.5
linux/amd64, go1.13.4, c2fd1b2
[INFO] 127.0.0.1:36934  - 50751 "HINFO IN 2339503303652509142.6629435935146223434. udp 57 false 512" NXDOMAIN qr,rd,ra 132 0.113342418s
[INFO] 10.244.0.7:40956 - 19505 "A IN www.google.com.default.svc.cluster.local.    udp 58 false 512" NXDOMAIN qr,aa,rd 151 0.000477458s
[INFO] 10.244.0.7:51841 - 6033  "A IN www.google.com.svc.cluster.local.            udp 50 false 512" NXDOMAIN qr,aa,rd 143 0.000334288s
[INFO] 10.244.0.7:58713 - 39245 "A IN www.google.com.cluster.local.                udp 46 false 512" NXDOMAIN qr,aa,rd 139 0.000297573s
[INFO] 10.244.0.7:40261 - 7481  "A IN www.google.com.corporate.example.com.        udp 59 false 512" NXDOMAIN qr,rd,ra 192 0.044948447s
[INFO] 10.244.0.7:60055 - 64468 "A IN www.google.com.                              udp 32 false 512" NOERROR  qr,rd,ra 62  0.048344485s
```

> FIXME: how to enable CoreDNS forward INFO logs, to confirm that CoreDNS will
> forward DNS lookup one by one from the `/etc/resolv.conf` search list to the
> upstream.

## Take aways

This is the longest DNS query cycle.

```text
                                       KUBE-APISERVER
                                     in-cluster dns (service)
                                             ^
  [A]                                   [B]  |                                 [C]
+-----+              (1)            +---------+   (2) out-of-cluster dns   +----------+
| Pod | --------------------------> | CoreDNS | -------------------------> | Upstream |
+-----+ <-------------------------- +---------+ <------------------------- +----------+
                                     10.96.0.10                         10.202.4.4/10.202.4.2
   |                 (4)                  |                 (3)
   |                                      |
   v                                      v
[/etc/resolv.conf]                      [/etc/resolv.conf]
nameserver 10.96.0.10                   nameserver 10.202.4.4
search default.svc.cluster.local        nameserver 10.205.4.2
search svc.cluster.local                search corporate.example.com
search cluster.local
search corporate.example.com
options ndots:5
```

- make DNS fast

1. Avoid retries with one by one `/etc/resolv.conf` `search list`
How to optimize node's `/etc/resolv.conf` `search list`
Setting `Pod.spec.dnsPolicy` to make best of DNS chooice, That is to say, if Pod do not query any in-cluster service, use `Default`.

2. Static DNS entries cached at `[B]` (CoreDNS `file`, `hosts` plugin), don't make DNS queries forward to the upstream
More [CoreDNS Plugins](https://coredns.io/plugins/)

> NOTE: I benchmarked the `hosts` static dns, the result indicating that
> ***NO*** too much benefit. (For CoreDNS already has *cache 30* by default, See
> the kubernetes default Corefile).

## Our pruduction fails

We have a Kuberentes cluster initialized already (cloud provider kubernetes
service). For some reason, we extended this cluster by managing some
heterogeneous nodes which is released or allocated from the same VPC (this
scaling capability is officially supported by the cloud provider).

Strange things occurred like this: Some pods in the cluster start error logging
`Name or service not known`. After some hard debugging efforts, we found that
`/etc/resolv.conf` of the the managed nodes are different with the origin
cluster nodes, and subset of CoreDNS pods were scheduled on these nodes. When
out-of-cluster dns queries hit on those coredns pods, coredns could not resolve
by itself or forwardindg to the upstream server (since upstream server is from
the Node's), that's the problem!
