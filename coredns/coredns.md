# CoreDNS: how the kubernetes dns works

This collection assumed that you have a rough picture why kubernetes have a dns
server, and how the kubernetes service maps to the dns record. For example, you
know that:

```bash
$kubectl get service/kubernetes
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d16h
```

You can resolve dns `kubernetes.default.svc.cluster.local` to ip
address `10.96.0.1` from inside your pod running on this cluster. I
have another post explain why this special service has this special
service ip, more refer to
[kubernetes](../kube-apiserver/kubernetes.html).

Now, let's explore more on the coredns deployment:

```bash
$kubectl -n kube-system get deployment/coredns
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   1/1     1            1           13d

$kubectl -n kube-system get services/kube-dns
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
$kubectl run alpine -ti --rm --restart=Never --image=alpine:latest -- cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

$kubectl run alpine -ti --rm --restart=Never --image=alpine:latest -- wget --no-check-certificate -O /dev/stdout https://kubernetes.default.svc.cluster.local/version
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

```go
// NewConfigurer returns a DNS configurer for launching pods.
func NewConfigurer(recorder record.EventRecorder, nodeRef *v1.ObjectReference, nodeIPs []net.IP, clusterDNS []net.IP, clusterDomain, resolverConfig string) *Configurer {
	return &Configurer{
		recorder:       recorder,
		nodeRef:        nodeRef,
		nodeIPs:        nodeIPs,
		clusterDNS:     clusterDNS,
		ClusterDomain:  clusterDomain,
		ResolverConfig: resolverConfig,
	}
}
```
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/network/dns/dns.go#L75)

Second, dns server ip address was passed in `kubelet` by configuration.

```go
	klet := &Kubelet{
		hostname:                                hostname,
		hostnameOverridden:                      hostnameOverridden,
		nodeName:                                nodeName,
		kubeClient:                              kubeDeps.KubeClient,
		heartbeatClient:                         kubeDeps.HeartbeatClient,
		onRepeatedHeartbeatFailure:              kubeDeps.OnHeartbeatFailure,
		rootDirectory:                           rootDirectory,
		resyncInterval:                          kubeCfg.SyncFrequency.Duration,
		sourcesReady:                            config.NewSourcesReady(kubeDeps.PodConfig.SeenAllSources),
		registerNode:                            registerNode,
		registerWithTaints:                      registerWithTaints,
		registerSchedulable:                     registerSchedulable,
		dnsConfigurer:                           dns.NewConfigurer(kubeDeps.Recorder, nodeRef, nodeIPs, clusterDNS, kubeCfg.ClusterDomain, kubeCfg.ResolverConfig),
		serviceLister:                           serviceLister,
		serviceHasSynced:                        serviceHasSynced,
		nodeLister:                              nodeLister,
		nodeHasSynced:                           nodeHasSynced,
		masterServiceNamespace:                  masterServiceNamespace,
		streamingConnectionIdleTimeout:          kubeCfg.StreamingConnectionIdleTimeout.Duration,
		recorder:                                kubeDeps.Recorder,
		cadvisor:                                kubeDeps.CAdvisorInterface,
		cloud:                                   kubeDeps.Cloud,
		externalCloudProvider:                   cloudprovider.IsExternal(cloudProvider),
		providerID:                              providerID,
		nodeRef:                                 nodeRef,
		nodeLabels:                              nodeLabels,
		nodeStatusUpdateFrequency:               kubeCfg.NodeStatusUpdateFrequency.Duration,
		nodeStatusReportFrequency:               kubeCfg.NodeStatusReportFrequency.Duration,
		os:                                      kubeDeps.OSInterface,
		oomWatcher:                              oomWatcher,
		cgroupsPerQOS:                           kubeCfg.CgroupsPerQOS,
		cgroupRoot:                              kubeCfg.CgroupRoot,
		mounter:                                 kubeDeps.Mounter,
		hostutil:                                kubeDeps.HostUtil,
		subpather:                               kubeDeps.Subpather,
		maxPods:                                 int(kubeCfg.MaxPods),
		podsPerCore:                             int(kubeCfg.PodsPerCore),
		syncLoopMonitor:                         atomic.Value{},
		daemonEndpoints:                         daemonEndpoints,
		containerManager:                        kubeDeps.ContainerManager,
		containerRuntimeName:                    containerRuntime,
		nodeIPs:                                 nodeIPs,
		nodeIPValidator:                         validateNodeIP,
		clock:                                   clock.RealClock{},
		enableControllerAttachDetach:            kubeCfg.EnableControllerAttachDetach,
		makeIPTablesUtilChains:                  kubeCfg.MakeIPTablesUtilChains,
		iptablesMasqueradeBit:                   int(kubeCfg.IPTablesMasqueradeBit),
		iptablesDropBit:                         int(kubeCfg.IPTablesDropBit),
		experimentalHostUserNamespaceDefaulting: utilfeature.DefaultFeatureGate.Enabled(features.ExperimentalHostUserNamespaceDefaultingGate),
		keepTerminatedPodVolumes:                keepTerminatedPodVolumes,
		nodeStatusMaxImages:                     nodeStatusMaxImages,
		lastContainerStartedTime:                newTimeCache(),
	}

```
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/kubelet.go#L509)

```go
	clusterDNS := make([]net.IP, 0, len(kubeCfg.ClusterDNS))
	for _, ipEntry := range kubeCfg.ClusterDNS {
		ip := net.ParseIP(ipEntry)
		if ip == nil {
			klog.InfoS("Invalid clusterDNS IP", "IP", ipEntry)
		} else {
			clusterDNS = append(clusterDNS, ip)
		}
	}
	httpClient := &http.Client{}
```
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/pkg/kubelet/kubelet.go#L485)

```go
// RunKubelet is responsible for setting up and running a kubelet.  It is used in three different applications:
//   1 Integration tests
//   2 Kubelet binary
//   3 Standalone 'kubernetes' binary
// Eventually, #2 will be replaced with instances of #3
func RunKubelet(kubeServer *options.KubeletServer, kubeDeps *kubelet.Dependencies, runOnce bool) error {
	hostname, err := nodeutil.GetHostname(kubeServer.HostnameOverride)
	if err != nil {
		return err
	}
	// Query the cloud provider for our node name, default to hostname if kubeDeps.Cloud == nil
	nodeName, err := getNodeName(kubeDeps.Cloud, hostname)
	if err != nil {
		return err
	}
	hostnameOverridden := len(kubeServer.HostnameOverride) > 0
	// Setup event recorder if required.
	makeEventRecorder(kubeDeps, nodeName)

	var nodeIPs []net.IP
	if kubeServer.NodeIP != "" {
		for _, ip := range strings.Split(kubeServer.NodeIP, ",") {
			parsedNodeIP := net.ParseIP(strings.TrimSpace(ip))
			if parsedNodeIP == nil {
				klog.InfoS("Could not parse --node-ip ignoring", "IP", ip)
			} else {
				nodeIPs = append(nodeIPs, parsedNodeIP)
			}
		}
	}
	if !utilfeature.DefaultFeatureGate.Enabled(features.IPv6DualStack) && len(nodeIPs) > 1 {
		return fmt.Errorf("dual-stack --node-ip %q not supported in a single-stack cluster", kubeServer.NodeIP)
	} else if len(nodeIPs) > 2 || (len(nodeIPs) == 2 && utilnet.IsIPv6(nodeIPs[0]) == utilnet.IsIPv6(nodeIPs[1])) {
		return fmt.Errorf("bad --node-ip %q; must contain either a single IP or a dual-stack pair of IPs", kubeServer.NodeIP)
	} else if len(nodeIPs) == 2 && kubeServer.CloudProvider != "" {
		return fmt.Errorf("dual-stack --node-ip %q not supported when using a cloud provider", kubeServer.NodeIP)
	} else if len(nodeIPs) == 2 && (nodeIPs[0].IsUnspecified() || nodeIPs[1].IsUnspecified()) {
		return fmt.Errorf("dual-stack --node-ip %q cannot include '0.0.0.0' or '::'", kubeServer.NodeIP)
	}

	capabilities.Initialize(capabilities.Capabilities{
		AllowPrivileged: true,
	})

	credentialprovider.SetPreferredDockercfgPath(kubeServer.RootDirectory)
	klog.V(2).InfoS("Using root directory", "path", kubeServer.RootDirectory)

	if kubeDeps.OSInterface == nil {
		kubeDeps.OSInterface = kubecontainer.RealOS{}
	}

	k, err := createAndInitKubelet(&kubeServer.KubeletConfiguration,
		kubeDeps,
		&kubeServer.ContainerRuntimeOptions,
		kubeServer.ContainerRuntime,
		hostname,
		hostnameOverridden,
		nodeName,
		nodeIPs,
		kubeServer.ProviderID,
		kubeServer.CloudProvider,
		kubeServer.CertDirectory,
		kubeServer.RootDirectory,
		kubeServer.ImageCredentialProviderConfigFile,
		kubeServer.ImageCredentialProviderBinDir,
		kubeServer.RegisterNode,
		kubeServer.RegisterWithTaints,
		kubeServer.AllowedUnsafeSysctls,
		kubeServer.ExperimentalMounterPath,
		kubeServer.KernelMemcgNotification,
		kubeServer.ExperimentalCheckNodeCapabilitiesBeforeMount,
		kubeServer.ExperimentalNodeAllocatableIgnoreEvictionThreshold,
		kubeServer.MinimumGCAge,
		kubeServer.MaxPerPodContainerCount,
		kubeServer.MaxContainerCount,
		kubeServer.MasterServiceNamespace,
		kubeServer.RegisterSchedulable,
		kubeServer.KeepTerminatedPodVolumes,
		kubeServer.NodeLabels,
		kubeServer.SeccompProfileRoot,
		kubeServer.NodeStatusMaxImages)
	if err != nil {
		return fmt.Errorf("failed to create kubelet: %w", err)
	}

	// NewMainKubelet should have set up a pod source config if one didn't exist
	// when the builder was run. This is just a precaution.
	if kubeDeps.PodConfig == nil {
		return fmt.Errorf("failed to create kubelet, pod source config was nil")
	}
	podCfg := kubeDeps.PodConfig

	if err := rlimit.SetNumFiles(uint64(kubeServer.MaxOpenFiles)); err != nil {
		klog.ErrorS(err, "Failed to set rlimit on max file handles")
	}

	// process pods and exit.
	if runOnce {
		if _, err := k.RunOnce(podCfg.Updates()); err != nil {
			return fmt.Errorf("runonce failed: %w", err)
		}
		klog.InfoS("Started kubelet as runonce")
	} else {
		startKubelet(k, podCfg, &kubeServer.KubeletConfiguration, kubeDeps, kubeServer.EnableServer)
		klog.InfoS("Started kubelet")
	}
	return nil
}
```
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubelet/app/server.go#L1094)

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

```go
	// Get the config file for CoreDNS
	coreDNSConfigMapBytes, err := kubeadmutil.ParseTemplate(CoreDNSConfigMap, struct{ DNSDomain, UpstreamNameserver, StubDomain string }{
		DNSDomain: cfg.Networking.DNSDomain,
	})
	if err != nil {
		return errors.Wrap(err, "error when parsing CoreDNS configMap template")
	}

	dnsip, err := kubeadmconstants.GetDNSIP(cfg.Networking.ServiceSubnet, features.Enabled(cfg.FeatureGates, features.IPv6DualStack))
	if err != nil {
		return err
	}
```
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubeadm/app/phases/addons/dns/dns.go#L121)

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
[more](https://github.com/kubernetes/kubernetes/blob/b96c86f1b9d92880845724d2030da3e2adac89e5/cmd/kubeadm/app/constants/constants.go#L587)

Oh, the truth came out, the 10th ip in service ip CIDR range was choosen by
default. The same as the `service/kubernetes` ip choose the 1st ip from service
ip CIDR range.

My final thinking: even kubernetes itself is highly dynamic about many aspects,
such pod/service ip. It was bootstraped by some conventions agreed in advance.
Chicken and egg, we could make a static chicken there, then let it produces egg,
don't ask egg for a chicken.
