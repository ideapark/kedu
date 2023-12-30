# Demystify Service kubernetes.default.svc.cluster.local

Have you ever paid attention to a special service located at default namespace?
Yes, I am talking about the service `kubernetes.default.svc.cluster.local`. In
this collection, I will walk you through the unknown side of this special
service.

## Why is it special?

Please spin up a fresh kubernetes cluster using
[`Kind`](https://kind.sigs.k8s.io/) or [`Docker Desktop`](https://www.docker.com/products/docker-desktop) (as is my case).

```bash
$kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d11h
```

We found the following questions:

1. its name is `kubernetes` and located in namespace `default`
2. it's the first service created by the kubernetes itself
3. it's ip is of type ClusterIP and the value is `10.96.0.1`
4. it's port is 443, seems like a https endpoint
5. it's `2d11h` old

## Explain technology details in the underground

First, this service is used to expose the kubernetes cluster's `kube-apiserver`
to be comsumed by any authorized and authenticated user (I means programmer like
you) or program (pods running inside this cluster). So the first question is
almost clear that it was choosen by purpose, to be widely known (for the name
`kubernetes`) and accessable (for the namespace `default`).

Second, let's do something evil:

```bash
$kubectl delete all --all
service "kubernetes" deleted

$kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   1s
```

The service was deleted, but created automatically again! A clerver guy may
quickly speak out that: I know, it's the controller. But keep this in mind that
there is no such service controller in the `kube-controller-manager` component.
Instead, the controller is running in the `kube-apiserver`.

```go
// Controller is the controller manager for the core bootstrap Kubernetes
// controller loops, which manage creating the "kubernetes" service, the
// "default", "kube-system" and "kube-public" namespaces, and provide the IP
// repair check on service IPs
type Controller struct {
	ServiceClient   corev1client.ServicesGetter
	NamespaceClient corev1client.NamespacesGetter
	EventClient     corev1client.EventsGetter
	readyzClient    rest.Interface

	ServiceClusterIPRegistry          rangeallocation.RangeRegistry
	ServiceClusterIPRange             net.IPNet
	SecondaryServiceClusterIPRegistry rangeallocation.RangeRegistry
	SecondaryServiceClusterIPRange    net.IPNet

	ServiceClusterIPInterval time.Duration

	ServiceNodePortRegistry rangeallocation.RangeRegistry
	ServiceNodePortInterval time.Duration
	ServiceNodePortRange    utilnet.PortRange

	EndpointReconciler reconcilers.EndpointReconciler
	EndpointInterval   time.Duration

	SystemNamespaces         []string
	SystemNamespacesInterval time.Duration

	PublicIP net.IP

	// ServiceIP indicates where the kubernetes service will live.  It may not be nil.
	ServiceIP                 net.IP
	ServicePort               int
	ExtraServicePorts         []corev1.ServicePort
	ExtraEndpointPorts        []corev1.EndpointPort
	PublicServicePort         int
	KubernetesServiceNodePort int

	runner *async.Runner
}
```
[more](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/controller.go#L51)

Keep going through the source, you could find that the `kubernetes` service ip
was passed in here:

```go
// NewBootstrapController returns a controller for watching the core capabilities of the master
func (c *completedConfig) NewBootstrapController(legacyRESTStorage corerest.LegacyRESTStorage, serviceClient corev1client.ServicesGetter, nsClient corev1client.NamespacesGetter, eventClient corev1client.EventsGetter, readyzClient rest.Interface) *Controller {
	_, publicServicePort, err := c.GenericConfig.SecureServing.HostPort()
	if err != nil {
		klog.Fatalf("failed to get listener address: %v", err)
	}

	systemNamespaces := []string{metav1.NamespaceSystem, metav1.NamespacePublic, corev1.NamespaceNodeLease}

	return &Controller{
		ServiceClient:   serviceClient,
		NamespaceClient: nsClient,
		EventClient:     eventClient,
		readyzClient:    readyzClient,

		EndpointReconciler: c.ExtraConfig.EndpointReconcilerConfig.Reconciler,
		EndpointInterval:   c.ExtraConfig.EndpointReconcilerConfig.Interval,

		SystemNamespaces:         systemNamespaces,
		SystemNamespacesInterval: 1 * time.Minute,

		ServiceClusterIPRegistry:          legacyRESTStorage.ServiceClusterIPAllocator,
		ServiceClusterIPRange:             c.ExtraConfig.ServiceIPRange,
		SecondaryServiceClusterIPRegistry: legacyRESTStorage.SecondaryServiceClusterIPAllocator,
		SecondaryServiceClusterIPRange:    c.ExtraConfig.SecondaryServiceIPRange,

		ServiceClusterIPInterval: 3 * time.Minute,

		ServiceNodePortRegistry: legacyRESTStorage.ServiceNodePortAllocator,
		ServiceNodePortRange:    c.ExtraConfig.ServiceNodePortRange,
		ServiceNodePortInterval: 3 * time.Minute,

		PublicIP: c.GenericConfig.PublicAddress,

		ServiceIP:                 c.ExtraConfig.APIServerServiceIP,
		ServicePort:               c.ExtraConfig.APIServerServicePort,
		ExtraServicePorts:         c.ExtraConfig.ExtraServicePorts,
		ExtraEndpointPorts:        c.ExtraConfig.ExtraEndpointPorts,
		PublicServicePort:         publicServicePort,
		KubernetesServiceNodePort: c.ExtraConfig.KubernetesServiceNodePort,
	}
}
```
[more](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/controller.go#L121)

And dig further, I found if the `kube-apiserver` was not passed in this ip or ip
is not in service ip range, it will pick the first ip address (`10.96.0.1`) from
the service ip range (as is our case is `10.96.0.0/16`).

```go
// Complete fills in any fields not set that are required to have valid data. It's mutating the receiver.
func (c *Config) Complete() CompletedConfig {
	cfg := completedConfig{
		c.GenericConfig.Complete(c.ExtraConfig.VersionedInformers),
		&c.ExtraConfig,
	}

	serviceIPRange, apiServerServiceIP, err := ServiceIPRange(cfg.ExtraConfig.ServiceIPRange)
	if err != nil {
		klog.Fatalf("Error determining service IP ranges: %v", err)
	}
	if cfg.ExtraConfig.ServiceIPRange.IP == nil {
		cfg.ExtraConfig.ServiceIPRange = serviceIPRange
	}
	if cfg.ExtraConfig.APIServerServiceIP == nil {
		cfg.ExtraConfig.APIServerServiceIP = apiServerServiceIP
	}

	discoveryAddresses := discovery.DefaultAddresses{DefaultAddress: cfg.GenericConfig.ExternalAddress}
	discoveryAddresses.CIDRRules = append(discoveryAddresses.CIDRRules,
		discovery.CIDRRule{IPRange: cfg.ExtraConfig.ServiceIPRange, Address: net.JoinHostPort(cfg.ExtraConfig.APIServerServiceIP.String(), strconv.Itoa(cfg.ExtraConfig.APIServerServicePort))})
	cfg.GenericConfig.DiscoveryAddresses = discoveryAddresses

	if cfg.ExtraConfig.ServiceNodePortRange.Size == 0 {
		// TODO: Currently no way to specify an empty range (do we need to allow this?)
		// We should probably allow this for clouds that don't require NodePort to do load-balancing (GCE)
		// but then that breaks the strict nestedness of ServiceType.
		// Review post-v1
		cfg.ExtraConfig.ServiceNodePortRange = kubeoptions.DefaultServiceNodePortRange
		klog.Infof("Node port range unspecified. Defaulting to %v.", cfg.ExtraConfig.ServiceNodePortRange)
	}

	if cfg.ExtraConfig.EndpointReconcilerConfig.Interval == 0 {
		cfg.ExtraConfig.EndpointReconcilerConfig.Interval = DefaultEndpointReconcilerInterval
	}

	if cfg.ExtraConfig.MasterEndpointReconcileTTL == 0 {
		cfg.ExtraConfig.MasterEndpointReconcileTTL = DefaultEndpointReconcilerTTL
	}

	if cfg.ExtraConfig.EndpointReconcilerConfig.Reconciler == nil {
		cfg.ExtraConfig.EndpointReconcilerConfig.Reconciler = c.createEndpointReconciler()
	}

	return CompletedConfig{&cfg}
}
```
[more](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/instance.go#L304)

```go
// ServiceIPRange checks if the serviceClusterIPRange flag is nil, raising a warning if so and
// setting service ip range to the default value in kubeoptions.DefaultServiceIPCIDR
// for now until the default is removed per the deprecation timeline guidelines.
// Returns service ip range, api server service IP, and an error
func ServiceIPRange(passedServiceClusterIPRange net.IPNet) (net.IPNet, net.IP, error) {
	serviceClusterIPRange := passedServiceClusterIPRange
	if passedServiceClusterIPRange.IP == nil {
		klog.Warningf("No CIDR for service cluster IPs specified. Default value which was %s is deprecated and will be removed in future releases. Please specify it using --service-cluster-ip-range on kube-apiserver.", kubeoptions.DefaultServiceIPCIDR.String())
		serviceClusterIPRange = kubeoptions.DefaultServiceIPCIDR
	}

	size := integer.Int64Min(utilnet.RangeSize(&serviceClusterIPRange), 1<<16)
	if size < 8 {
		return net.IPNet{}, net.IP{}, fmt.Errorf("the service cluster IP range must be at least %d IP addresses", 8)
	}

	// Select the first valid IP from ServiceClusterIPRange to use as the GenericAPIServer service IP.
	apiServerServiceIP, err := utilnet.GetIndexedIP(&serviceClusterIPRange, 1)
	if err != nil {
		return net.IPNet{}, net.IP{}, err
	}
	klog.V(4).Infof("Setting service IP to %q (read-write).", apiServerServiceIP)

	return serviceClusterIPRange, apiServerServiceIP, nil
}
```
[more](https://github.com/kubernetes/kubernetes/blob/9f0f14952c51e7a5622eac05c541ba20b5821627/pkg/controlplane/services.go#L47)

The other questions should be self-explanatory now, that's the complexity behind
the simplicity `kubernetes.default.svc.cluster.local`.
