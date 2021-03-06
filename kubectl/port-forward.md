# How the kubectl port-forward works exactly

Or in another words, what the hell `kubectl -n kube-system port-forward
deployment/coredns 5353:53` was implemented.

## kubectl

- kubectl will listen on port 5353 until get CTRL-C killing signal

```bash
$kubectl -n kube-system port-forward deployment/coredns 5353:53
Forwarding from 127.0.0.1:5353 -> 53
Forwarding from [::1]:5353 -> 53
```

```go
// RunPortForward implements all the necessary functionality for port-forward cmd.
func (o PortForwardOptions) RunPortForward() error {
	pod, err := o.PodClient.Pods(o.Namespace).Get(context.TODO(), o.PodName, metav1.GetOptions{})
	if err != nil {
		return err
	}

	if pod.Status.Phase != corev1.PodRunning {
		return fmt.Errorf("unable to forward port because pod is not running. Current status=%v", pod.Status.Phase)
	}

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)
	defer signal.Stop(signals)

	go func() {
		<-signals
		if o.StopChannel != nil {
			close(o.StopChannel)
		}
	}()

	req := o.RESTClient.Post().
		Resource("pods").
		Namespace(o.Namespace).
		Name(pod.Name).
		SubResource("portforward")

	return o.PortForwarder.ForwardPorts("POST", req.URL(), o)
}
```
[more](https://github.com/kubernetes/kubernetes/blob/3dd0597843ced8270bbbb9d26ac390397e2c4166/staging/src/k8s.io/kubectl/pkg/cmd/portforward/portforward.go#L401)

- from kubectl to kube-apiserver

```bash
$kubectl -v=6 -n kube-system port-forward deployment/coredns 5353:53
I0508 17:34:26.376413  221687 loader.go:372] Config loaded from file:  /home/park/.kube/config
I0508 17:34:26.386867  221687 round_trippers.go:454] GET https://127.0.0.1:45691/apis/apps/v1/namespaces/kube-system/deployments/coredns 200 OK in 6 milliseconds
I0508 17:34:26.393478  221687 round_trippers.go:454] GET https://127.0.0.1:45691/api/v1/namespaces/kube-system/pods?labelSelector=k8s-app%3Dkube-dns 200 OK in 2 milliseconds
I0508 17:34:26.399918  221687 round_trippers.go:454] GET https://127.0.0.1:45691/api/v1/namespaces/kube-system/pods/coredns-df9744896-vh84c 200 OK in 1 milliseconds
I0508 17:34:26.415950  221687 round_trippers.go:454] POST https://127.0.0.1:45691/api/v1/namespaces/kube-system/pods/coredns-df9744896-vh84c/portforward 101 Switching Protocols in 12 milliseconds
Forwarding from 127.0.0.1:5353 -> 53
Forwarding from [::1]:5353 -> 53
```

The kubectl verbose log gives us 3 hints:

1. kubectl query the pods which is belonging to the `deployment/coredns`
2. and it chooses one of active pods (randomly?)
3. make a POST request to the selected pod subresource `/portforward`

```go
// RunPortForward implements all the necessary functionality for port-forward cmd.
func (o PortForwardOptions) RunPortForward() error {
	pod, err := o.PodClient.Pods(o.Namespace).Get(context.TODO(), o.PodName, metav1.GetOptions{})
	if err != nil {
		return err
	}

	if pod.Status.Phase != corev1.PodRunning {
		return fmt.Errorf("unable to forward port because pod is not running. Current status=%v", pod.Status.Phase)
	}

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)
	defer signal.Stop(signals)

	go func() {
		<-signals
		if o.StopChannel != nil {
			close(o.StopChannel)
		}
	}()

	req := o.RESTClient.Post().
		Resource("pods").
		Namespace(o.Namespace).
		Name(pod.Name).
		SubResource("portforward")

	return o.PortForwarder.ForwardPorts("POST", req.URL(), o)
}
```
[more](https://github.com/kubernetes/kubernetes/blob/3dd0597843ced8270bbbb9d26ac390397e2c4166/staging/src/k8s.io/kubectl/pkg/cmd/portforward/portforward.go#L408)

## kube-apiserver

Let's move our focus to how kube-apiserver handle the pod subresource `/portforward`.

```text
 0  0x00000000048d85ca in k8s.io/kubernetes/pkg/registry/core/pod.PortForwardLocation
    at ./pkg/registry/core/pod/strategy.go:576
 1  0x00000000048e18f8 in k8s.io/kubernetes/pkg/registry/core/pod/rest.(*PortForwardREST).Connect
    at ./pkg/registry/core/pod/rest/subresources.go:187
 2  0x00000000024b0811 in k8s.io/apiserver/pkg/endpoints/handlers.ConnectResource.func1.1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/handlers/rest.go:219
 3  0x0000000002142773 in k8s.io/apiserver/pkg/endpoints/metrics.RecordLongRunning
    at ./vendor/k8s.io/apiserver/pkg/endpoints/metrics/metrics.go:427
 4  0x00000000024b188b in k8s.io/apiserver/pkg/endpoints/handlers.ConnectResource.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/handlers/rest.go:218
 5  0x00000000024d1e26 in k8s.io/apiserver/pkg/endpoints.restfulConnectResource.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/installer.go:1250
 6  0x0000000002146813 in k8s.io/apiserver/pkg/endpoints/metrics.InstrumentRouteFunc.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/metrics/metrics.go:483
 7  0x000000000212412d in github.com/emicklei/go-restful.(*Container).dispatch
    at ./vendor/github.com/emicklei/go-restful/container.go:288
 8  0x0000000002123065 in github.com/emicklei/go-restful.(*Container).Dispatch
    at ./vendor/github.com/emicklei/go-restful/container.go:199
 9  0x000000000253ba46 in k8s.io/apiserver/pkg/server.director.ServeHTTP
    at ./vendor/k8s.io/apiserver/pkg/server/handler.go:146
10  0x00000000025456fb in k8s.io/apiserver/pkg/server.(*director).ServeHTTP
    at <autogenerated>:1
11  0x000000000266167b in k8s.io/kube-aggregator/pkg/apiserver.(*proxyHandler).ServeHTTP
    at ./vendor/k8s.io/kube-aggregator/pkg/apiserver/handler_proxy.go:123
12  0x00000000023237a8 in k8s.io/apiserver/pkg/server/mux.(*pathHandler).ServeHTTP
    at ./vendor/k8s.io/apiserver/pkg/server/mux/pathrecorder.go:248
13  0x000000000232310e in k8s.io/apiserver/pkg/server/mux.(*PathRecorderMux).ServeHTTP
    at ./vendor/k8s.io/apiserver/pkg/server/mux/pathrecorder.go:234
14  0x000000000253bd25 in k8s.io/apiserver/pkg/server.director.ServeHTTP
    at ./vendor/k8s.io/apiserver/pkg/server/handler.go:154
15  0x00000000025456fb in k8s.io/apiserver/pkg/server.(*director).ServeHTTP
    at <autogenerated>:1
16  0x0000000002160900 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackCompleted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:95
17  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
18  0x0000000002173f5d in k8s.io/apiserver/pkg/endpoints/filters.WithAuthorization.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filters/authorization.go:64
19  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
20  0x000000000216056d in k8s.io/apiserver/pkg/endpoints/filterlatency.trackStarted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:71
21  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
22  0x0000000002160900 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackCompleted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:95
23  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
24  0x00000000023f0e74 in k8s.io/apiserver/pkg/server/filters.WithPriorityAndFairness.func1
    at ./vendor/k8s.io/apiserver/pkg/server/filters/priority-and-fairness.go:90
25  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
26  0x000000000216056d in k8s.io/apiserver/pkg/endpoints/filterlatency.trackStarted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:71
27  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
28  0x0000000002160900 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackCompleted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:95
29  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
30  0x000000000217482c in k8s.io/apiserver/pkg/endpoints/filters.WithImpersonation.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filters/impersonation.go:50
31  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
32  0x000000000216056d in k8s.io/apiserver/pkg/endpoints/filterlatency.trackStarted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:71
33  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
34  0x0000000002160900 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackCompleted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:95
35  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
36  0x000000000216056d in k8s.io/apiserver/pkg/endpoints/filterlatency.trackStarted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:71
37  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
38  0x0000000002160900 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackCompleted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:95
39  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
40  0x0000000002172fff in k8s.io/apiserver/pkg/endpoints/filters.withAuthentication.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filters/authentication.go:80
41  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
42  0x00000000021606f6 in k8s.io/apiserver/pkg/endpoints/filterlatency.trackStarted.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filterlatency/filterlatency.go:80
43  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
44  0x00000000023ecb0b in k8s.io/apiserver/pkg/server/filters.(*timeoutHandler).ServeHTTP
    at ./vendor/k8s.io/apiserver/pkg/server/filters/timeout.go:85
45  0x0000000002177269 in k8s.io/apiserver/pkg/endpoints/filters.withRequestDeadline.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filters/request_deadline.go:66
46  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
47  0x00000000023f24fb in k8s.io/apiserver/pkg/server/filters.WithWaitGroup.func1
    at ./vendor/k8s.io/apiserver/pkg/server/filters/waitgroup.go:59
48  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
49  0x0000000002178764 in k8s.io/apiserver/pkg/endpoints/filters.WithRequestInfo.func1
    at ./vendor/k8s.io/apiserver/pkg/endpoints/filters/requestinfo.go:39
50  0x00000000008e8784 in net/http.HandlerFunc.ServeHTTP
    at /usr/local/go/src/net/http/server.go:2069
```

I have grasped a snopshot of the kube-apiserver call stack when the pod
`/portforward` subresource was requested.

The upppermost func told us that the kube-apiserver proxied port-forward request
the node which pod was scheduled running on.

```go
	// Proxy the connection. This is bidirectional, so we need a goroutine
	// to copy in each direction. Once one side of the connection exits, we
	// exit the function which performs cleanup and in the process closes
	// the other half of the connection in the defer.
	writerComplete := make(chan struct{})
	readerComplete := make(chan struct{})

	go func() {
		var writer io.WriteCloser
		if h.MaxBytesPerSec > 0 {
			writer = flowrate.NewWriter(backendConn, h.MaxBytesPerSec)
		} else {
			writer = backendConn
		}
		_, err := io.Copy(writer, requestHijackedConn)
		if err != nil && !strings.Contains(err.Error(), "use of closed network connection") {
			klog.Errorf("Error proxying data from client to backend: %v", err)
		}
		close(writerComplete)
	}()

	go func() {
		var reader io.ReadCloser
		if h.MaxBytesPerSec > 0 {
			reader = flowrate.NewReader(backendConn, h.MaxBytesPerSec)
		} else {
			reader = backendConn
		}
		_, err := io.Copy(requestHijackedConn, reader)
		if err != nil && !strings.Contains(err.Error(), "use of closed network connection") {
			klog.Errorf("Error proxying data from backend to client: %v", err)
		}
		close(readerComplete)
	}()

	// Wait for one half the connection to exit. Once it does the defer will
	// clean up the other half of the connection.
	select {
	case <-writerComplete:
	case <-readerComplete:
	}
```
[more](https://github.com/kubernetes/kubernetes/blob/7b2776b89fb1be28d4e9203bdeec079be903c103/staging/src/k8s.io/apimachinery/pkg/util/proxy/upgradeaware.go#L371)

## kubelet

At last, we reached the last kubernetes component involved in a kubectl
port-forward command.

```go
// NewServer creates a new Server for stream requests.
// TODO(tallclair): Add auth(n/z) interface & handling.
func NewServer(config Config, runtime Runtime) (Server, error) {
	s := &server{
		config:  config,
		runtime: &criAdapter{runtime},
		cache:   newRequestCache(),
	}

	if s.config.BaseURL == nil {
		s.config.BaseURL = &url.URL{
			Scheme: "http",
			Host:   s.config.Addr,
		}
		if s.config.TLSConfig != nil {
			s.config.BaseURL.Scheme = "https"
		}
	}

	ws := &restful.WebService{}
	endpoints := []struct {
		path    string
		handler restful.RouteFunction
	}{
		{"/exec/{token}", s.serveExec},
		{"/attach/{token}", s.serveAttach},
		{"/portforward/{token}", s.servePortForward},
	}
	// If serving relative to a base path, set that here.
	pathPrefix := path.Dir(s.config.BaseURL.Path)
	for _, e := range endpoints {
		for _, method := range []string{"GET", "POST"} {
			ws.Route(ws.
				Method(method).
				Path(path.Join(pathPrefix, e.path)).
				To(e.handler))
		}
	}
	handler := restful.NewContainer()
	handler.Add(ws)
	s.handler = handler
	s.server = &http.Server{
		Addr:      s.config.Addr,
		Handler:   s.handler,
		TLSConfig: s.config.TLSConfig,
	}

	return s, nil
}
```
[more](https://github.com/kubernetes/kubernetes/blob/7b2776b89fb1be28d4e9203bdeec079be903c103/pkg/kubelet/cri/streaming/server.go#L108)

The above source code tellls us that kubelet build a server with an cri-runtime
which impplements `PortForward(podSandboxID string, port int32, stream
io.ReadWriteCloser) error` will serve on a path `/portforward/{token}`, so the
kube-apiserver's request will be handled by the kubelet cri-runtime.

So, we could concluded that the cri-runtime will proxy our port-forward request
the real pod's port.

## One picture says more than a thousand words

Finally, we can reach a remote pod from our localhost, it's amazing when I first
time used this magic. Simplicity is for users, complexity is under the iceberg.

```text
    curl
     |
     |
     v
   :5353
 LOCALHOST               CONTROLPLANE                                NODE
+---------+           +----------------+           +-------------------------------------------+
| kubectl | <-------> | kube-apiserver | <-------> | kubelet <---> cri-runtime <---> container |
+---------+           +----------------+           +-------------------------------------------+
```
