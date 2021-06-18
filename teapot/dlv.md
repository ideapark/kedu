# dlv: debug go programm

## Install dlv

```bash
$go version
$go version go1.16.4 darwin/arm64                     # go1.16+
$go install github.com/go-delve/delve/cmd/dlv@latest  # latest stable dlv
```

## Debug kubectl

```bash
$cd /path/to/kubernetes
$dlv debug k8s.io/kubernetes/cmd/kubectl
Type 'help' for list of commands.
(dlv) break main.main
Breakpoint 1 (enabled) set at 0x1025f2700 for main.main() ./cmd/kubectl/kubectl.go:35
(dlv) r
Process restarted with PID 28090
(dlv) c
main.main() ./cmd/kubectl/kubectl.go:35 (hits goroutine(1):1 total:1) (PC: 0x102156700)
   30:
   31:		// Import to initialize client auth plugins.
   32:		_ "k8s.io/client-go/plugin/pkg/client/auth"
   33:	)
   34:
=> 35:	func main() {
   36:		rand.Seed(time.Now().UnixNano())
   37:
   38:		command := cmd.NewDefaultKubectlCommand()
   39:
   40:		// TODO: once we switch everything over to Cobra commands, we can go back to calling
(dlv)
```

## Frequently used debug command

1. restart kubectl with arguments

> (dlv) r -v=6 get all

2. set breakpoints

> break 78
> break kubectl.go:38

3. step command

> n

4. step into function

> s

5. step out function

> so

6. run to next breakpoint

> c

7. print var

> p varname

8. function local variables

> locals

9. global variables

> vars

10. more help

> help
