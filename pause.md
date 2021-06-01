# Pause Container Running in Every Pod

Do you have ever noticed that there is a container running image `pause:X.X`
in your Pod?

```bash
$ docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED        STATUS        PORTS     NAMES
797ef4864f74   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_vpnkit-controller_kube-system_e61b8668-12ea-4626-9e8d-23ed1b8886a6_0
4f0e62a39683   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_storage-provisioner_kube-system_c8a61f75-82b8-4d8a-adb3-409a88539c9b_0
e14a1f2fd2c1   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_kube-scheduler-docker-desktop_kube-system_57b58b3eb5589cb745c50233392349fb_0
36fe25e91665   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_kube-proxy-shr2q_kube-system_ae1de764-1519-4dbe-b36b-f46d54640792_0
7f06c44f5b45   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_kube-controller-manager-docker-desktop_kube-system_77e9d7fdbb29bf4b5600ab5fbb368a2b_0
412390d7c10e   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_kube-apiserver-docker-desktop_kube-system_4ac4b5ee26e7058a1ed090c12123e3a6_0
908f206b27d9   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_etcd-docker-desktop_kube-system_127f1e78367a800caa891919cc4b583f_0
96a3f3ddb262   k8s.gcr.io/pause:3.2               "/pause"                 3 days ago     Up 3 days               k8s_POD_coredns-f9fd979d6-ldcdq_kube-system_f2ff17a1-84d2-4c72-973f-0c033ad94ccd_0
3bb69d0a443f   k8s.gcr.io/kube-scheduler          "kube-scheduler --au…"   3 days ago     Up 3 days               k8s_kube-scheduler_kube-scheduler-docker-desktop_kube-system_57b58b3eb5589cb745c50233392349fb_0
c14db6cef44f   k8s.gcr.io/kube-proxy              "/usr/local/bin/kube…"   3 days ago     Up 3 days               k8s_kube-proxy_kube-proxy-shr2q_kube-system_ae1de764-1519-4dbe-b36b-f46d54640792_0
cf8314633df5   k8s.gcr.io/etcd                    "etcd --advertise-cl…"   3 days ago     Up 3 days               k8s_etcd_etcd-docker-desktop_kube-system_127f1e78367a800caa891919cc4b583f_0
2a9eb162f300   k8s.gcr.io/coredns                 "/coredns -conf /etc…"   3 days ago     Up 3 days               k8s_coredns_coredns-f9fd979d6-ldcdq_kube-system_f2ff17a1-84d2-4c72-973f-0c033ad94ccd_0
ba3066d4918f   e704287ce753                       "/storage-provisione…"   44 hours ago   Up 44 hours             k8s_storage-provisioner_storage-provisioner_kube-system_c8a61f75-82b8-4d8a-adb3-409a88539c9b_1
b5dbb1bf7f30   docker/desktop-vpnkit-controller   "/kube-vpnkit-forwar…"   3 days ago     Up 3 days               k8s_vpnkit-controller_vpnkit-controller_kube-system_e61b8668-12ea-4626-9e8d-23ed1b8886a6_0
8957df9e88b0   699c5704c97f                       "kube-controller-man…"   3 days ago     Up 3 days               k8s_kube-controller-manager_kube-controller-manager-docker-desktop_kube-system_77e9d7fdbb29bf4b5600ab5fbb368a2b_5
463d0a0de601   322111412cde                       "kube-apiserver --ad…"   3 days ago     Up 3 days               k8s_kube-apiserver_kube-apiserver-docker-desktop_kube-system_4ac4b5ee26e7058a1ed090c12123e3a6_4

$ docker images
REPOSITORY                           TAG        IMAGE ID       CREATED         SIZE
alpine                               latest     3fcaaf3dc95c   6 weeks ago     5.35MB
docker/desktop-storage-provisioner   v1.1       e704287ce753   14 months ago   41.8MB
docker/desktop-vpnkit-controller     v1.0       79da37e5a3aa   15 months ago   36.6MB
k8s.gcr.io/coredns                   1.7.0      db91994f4ee8   11 months ago   42.8MB
k8s.gcr.io/etcd                      3.4.13-0   05b738aa1bc6   9 months ago    312MB
k8s.gcr.io/kube-apiserver            v1.19.7    322111412cde   4 months ago    110MB
k8s.gcr.io/kube-controller-manager   v1.19.7    699c5704c97f   4 months ago    103MB
k8s.gcr.io/kube-proxy                v1.19.7    bf996869d15f   4 months ago    116MB
k8s.gcr.io/kube-scheduler            v1.19.7    62fbe881de53   4 months ago    42.6MB
k8s.gcr.io/pause                     3.2        2a060e2e7101   15 months ago   484kB
```

## What the hell is it?

Let's discuss a little about Pod. you can think it like a Linux machine, when
the linux kernel bootstrapped, the first process which is of pid 0 is started by
the kernel. then this `root` process is responsible for the other userspace
process bootstrapping and reap all the dead processes. Because unix system
process is organized by the tree structure, there must be a tree root.

So where is the `Pod machine` root process? yes, it's the pause container
process. To be short, the `pause` container is the root process of the Pod, and
it's responsible for the dead process reaping. Among that, it is the first
process to be started and allocated pod level resources such network namespace,
cpu & memory limits. Please note that the pasue container is there to hold the
network namespace when multiple container pod has one of it's container stoppped
and restarted again.

The pause is implmented by C code, and it just sleep, awake by signal and do
reap and loop.

[link to source](https://github.com/kubernetes/kubernetes/blob/d6b408f74890abaa0b5be7172714c7fe89ee7eff/build/pause/linux/pause.c#L42)

## Why `kubectl describe pod/xxxx` not showing this container?

First, user creating a pod do not specify this special container, it is created
by the kubelet by default when a new pod was initliazing. So pause lifecycle is
bound with the pod, it is responsible for the pod resource holder, especialy
network namespace.

[link to source](https://github.com/kubernetes/kubernetes/blob/9c2684150c4d4aed99c6f950f4bc4c0754720897/pkg/kubelet/dockershim/docker_sandbox.go#L43)

The kubelet will
[run](https://github.com/kubernetes/kubernetes/blob/9c2684150c4d4aed99c6f950f4bc4c0754720897/pkg/kubelet/dockershim/docker_sandbox.go#L89)
and
[stop](https://github.com/kubernetes/kubernetes/blob/9c2684150c4d4aed99c6f950f4bc4c0754720897/pkg/kubelet/dockershim/docker_sandbox.go#L212)
the pod sandbox when the pod was created or deleted.

## Further QA

This conclusion is from the dockershim implementation code, I don't have digged
out the cri implemetation details.

## Buy me a coffee

- wechat

![wechat](assets/wechat.png)

- alipay

![alipay](assets/alipay.png)
