# How the kubernetes service loadbalancer works exactly

## iptables

In short words, iptables can be used to mutate packets between network interface
and local process, `kube-proxy` will manipulate `iptables` utilities to program
the packet NAT (network address translation) on the fly.

```text
+---------+                         PREROUTING                                                   INPUT                +---------+
|         |     +--------------------------------------------------+                +----------------------------+    |         |
|         |     |   +-----+   +----------+   +--------+   +-----+  |                |   +--------+   +--------+  |    |         |
|         |-----|-->| raw |-->|connection|-->| mangle |-->| nat |--|----------------|-->| mangle |-->| filter |--|--->|         |
|         |     |   +-----+   | tracking |   +--------+   +-----+  |                |   +--------+   +--------+  |    |         |
|         |     |             +----------+                   |     |                +----------------------------+    |         |
|         |     +--------------------------------------------------+                                                  |         |
|         |                                                  |                                                        |         |
| Network |                                                  |                                                        |  Local  |
|interface|                                             +----------+                                                  | Process |
|         |                                             |    v     |                                                  |         |
|         |                                             | +------+ |                                                  |         |
|         |                                             | |mangle| | FORWARD                                          |         |
|         |                                             | +------+ |                                                  |         |
|         |                                             |    |     |                                                  |         |
|         |                                             |    v     |                                                  |         |
|         |                                             | +------+ |                                                  |         |
|         |                                +------------|-|filter| |                                                  |         |
|         |                                |            | +------+ |                                                  |         |
|         |                                |            +----------+                                                  |         |
|         |                                v                                                                          |         |
|         |                +---------------------------+    +------------------------------------------------------+  |         |
|         |                | +-----+   +--------+      |    | +------+   +-----+   +------+   +----------+   +---+ |  |         |
|         |<---------------| | nat |<--| mangle |      |<---| |filter|<--| nat |<--|mangle|<--|connection|<--|raw| |--|         |
|         |                | +-----+   +--------+      |    | +------+   +-----+   +------+   | tracking |   +---+ |  |         |
|         |                +---------------------------+    +------------------------------------------------------+  |         |
|         |                         POSTROUTING                                      OUTPUT                           |         |
+---------+                                                                                                           +---------+
```

Let's see some practical exapmles:

```text
*nat

# set up IP forwarding and nat
-A POSTROUTING -o eth0 -j SNAT --to 1.2.3.4
-A PREROUTING  -i eth0 -p tcp -d 1.2.3.4 --dport 80 -j DNAT --to 192.168.0.3:8080

COMMIT
```

The above iptable rules says that:

1. all out packets through `eth0` from ip address will be changed to `1.2.3.4`.

2. all in packets through `eth0` with destination `1.2.3.4:80` will be mutated
   to destination `192.168.0.3:8080`

## kube-proxy

Now we will compare the iptables after we scale up `deployment/coredns`

  kubectl -n kube-system scale --replicas=4 deployment/coredns

```text
diff -u /tmp/before.txt /tmp/after.txt
--- /tmp/before.txt	2021-05-11 07:25:03.842424691 +0800
+++ /tmp/after.txt	2021-05-11 07:24:39.989090219 +0800
@@ -11,13 +11,19 @@
 -N KUBE-NODEPORTS
 -N KUBE-POSTROUTING
 -N KUBE-PROXY-CANARY
+-N KUBE-SEP-232DQYSHL5HNRYWJ
 -N KUBE-SEP-275NWNNANOEIGYHG
 -N KUBE-SEP-2Z3537XSN3RJRU3M
+-N KUBE-SEP-A4UL7OUXQPUR7Y7Q
+-N KUBE-SEP-CPH3WXMLRJ2BZFXW
 -N KUBE-SEP-FVQSBIWR5JTECIVC
 -N KUBE-SEP-IRMT6RY5EEEBXDAY
 -N KUBE-SEP-LASJGFFJP3UOS6RQ
 -N KUBE-SEP-LPGSDLJ3FDW46N4W
+-N KUBE-SEP-SISP6ORRA37L3ZYK
 -N KUBE-SEP-V2PECCYPB6X2GSCW
+-N KUBE-SEP-XNZERJBNXRGRQGMS
+-N KUBE-SEP-XRFUWCXKVCLGWYQC
 -N KUBE-SERVICES
 -N KUBE-SVC-ERIFXISQEP7F7OF4
 -N KUBE-SVC-JD5MR3NA4I4DYORP
@@ -41,10 +47,16 @@
 -A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
 -A KUBE-POSTROUTING -j MARK --set-xmark 0x4000/0x0
 -A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully
+-A KUBE-SEP-232DQYSHL5HNRYWJ -s 10.244.0.7/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
+-A KUBE-SEP-232DQYSHL5HNRYWJ -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.7:53
 -A KUBE-SEP-275NWNNANOEIGYHG -s 10.244.0.6/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
 -A KUBE-SEP-275NWNNANOEIGYHG -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.6:9153
 -A KUBE-SEP-2Z3537XSN3RJRU3M -s 10.244.0.6/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
 -A KUBE-SEP-2Z3537XSN3RJRU3M -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.6:53
+-A KUBE-SEP-A4UL7OUXQPUR7Y7Q -s 10.244.0.7/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
+-A KUBE-SEP-A4UL7OUXQPUR7Y7Q -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.7:53
+-A KUBE-SEP-CPH3WXMLRJ2BZFXW -s 10.244.0.7/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
+-A KUBE-SEP-CPH3WXMLRJ2BZFXW -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.7:9153
 -A KUBE-SEP-FVQSBIWR5JTECIVC -s 10.244.0.5/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
 -A KUBE-SEP-FVQSBIWR5JTECIVC -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.5:9153
 -A KUBE-SEP-IRMT6RY5EEEBXDAY -s 10.244.0.6/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
@@ -53,8 +65,14 @@
 -A KUBE-SEP-LASJGFFJP3UOS6RQ -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.5:53
 -A KUBE-SEP-LPGSDLJ3FDW46N4W -s 10.244.0.5/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
 -A KUBE-SEP-LPGSDLJ3FDW46N4W -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.5:53
+-A KUBE-SEP-SISP6ORRA37L3ZYK -s 10.244.0.8/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
+-A KUBE-SEP-SISP6ORRA37L3ZYK -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.8:53
 -A KUBE-SEP-V2PECCYPB6X2GSCW -s 172.18.0.2/32 -m comment --comment "default/kubernetes:https" -j KUBE-MARK-MASQ
 -A KUBE-SEP-V2PECCYPB6X2GSCW -p tcp -m comment --comment "default/kubernetes:https" -m tcp -j DNAT --to-destination 172.18.0.2:6443
+-A KUBE-SEP-XNZERJBNXRGRQGMS -s 10.244.0.8/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
+-A KUBE-SEP-XNZERJBNXRGRQGMS -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.8:9153
+-A KUBE-SEP-XRFUWCXKVCLGWYQC -s 10.244.0.8/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
+-A KUBE-SEP-XRFUWCXKVCLGWYQC -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.8:53
 -A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
 -A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
 -A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
@@ -64,10 +82,16 @@
 -A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
 -A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
 -A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
--A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-LASJGFFJP3UOS6RQ
--A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-SEP-2Z3537XSN3RJRU3M
--A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-FVQSBIWR5JTECIVC
--A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-SEP-275NWNNANOEIGYHG
+-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-LASJGFFJP3UOS6RQ
+-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-2Z3537XSN3RJRU3M
+-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-A4UL7OUXQPUR7Y7Q
+-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-SEP-XRFUWCXKVCLGWYQC
+-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-FVQSBIWR5JTECIVC
+-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-275NWNNANOEIGYHG
+-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-CPH3WXMLRJ2BZFXW
+-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-SEP-XNZERJBNXRGRQGMS
 -A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment "default/kubernetes:https" -j KUBE-SEP-V2PECCYPB6X2GSCW
--A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-LPGSDLJ3FDW46N4W
--A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -j KUBE-SEP-IRMT6RY5EEEBXDAY
+-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-LPGSDLJ3FDW46N4W
+-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-IRMT6RY5EEEBXDAY
+-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-232DQYSHL5HNRYWJ
+-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -j KUBE-SEP-SISP6ORRA37L3ZYK
```

You do not have to be a iptables expert, just have a sense of that:

1. when `deployment/coredns` pods scale up, iptable rules was changed on the
   fly.

2. because 2 more pods added to the loadbalancer, so the traffic distribution
   probability will be changed accrodingly.

## How the kube-proxy get this happen

Please enable the verbose log level of the kube-proxy at your own chooice.

  kubectl -n kube-system edit daemonset/kube-proxy

```text
@@ -152,6 +152,7 @@
       containers:
       - command:
         - /usr/local/bin/kube-proxy
+        - -v=5
         - --config=/var/lib/kube-proxy/config.conf
         - --hostname-override=$(NODE_NAME)

```

Now do the scale up/down to see what's going on:

```text
I0510 23:45:24.654065       1 proxier.go:861] Syncing iptables rules
I0510 23:45:24.654103       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-EXTERNAL-SERVICES -t filter]
I0510 23:45:24.659315       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C INPUT -t filter -m conntrack --ctstate NEW -m comment --comment kubernetes externally-visible service portals -j KUBE-EXTERNAL-SERVICES]
I0510 23:45:24.665107       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-EXTERNAL-SERVICES -t filter]
I0510 23:45:24.670033       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C FORWARD -t filter -m conntrack --ctstate NEW -m comment --comment kubernetes externally-visible service portals -j KUBE-EXTERNAL-SERVICES]
I0510 23:45:24.674849       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-SERVICES -t filter]
I0510 23:45:24.678630       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C FORWARD -t filter -m conntrack --ctstate NEW -m comment --comment kubernetes service portals -j KUBE-SERVICES]
I0510 23:45:24.683355       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-SERVICES -t filter]
I0510 23:45:24.688603       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C OUTPUT -t filter -m conntrack --ctstate NEW -m comment --comment kubernetes service portals -j KUBE-SERVICES]
I0510 23:45:24.694127       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-FORWARD -t filter]
I0510 23:45:24.697958       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C FORWARD -t filter -m comment --comment kubernetes forwarding rules -j KUBE-FORWARD]
I0510 23:45:24.702631       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-SERVICES -t nat]
I0510 23:45:24.706695       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C OUTPUT -t nat -m comment --comment kubernetes service portals -j KUBE-SERVICES]
I0510 23:45:24.711344       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-SERVICES -t nat]
I0510 23:45:24.715726       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C PREROUTING -t nat -m comment --comment kubernetes service portals -j KUBE-SERVICES]
I0510 23:45:24.720542       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-POSTROUTING -t nat]
I0510 23:45:24.725432       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -C POSTROUTING -t nat -m comment --comment kubernetes postrouting rules -j KUBE-POSTROUTING]
I0510 23:45:24.730719       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -N KUBE-MARK-DROP -t nat]
I0510 23:45:24.735485       1 iptables.go:351] running iptables-save [-t filter]
I0510 23:45:24.740770       1 iptables.go:351] running iptables-save [-t nat]
I0510 23:45:24.749467       1 traffic.go:91] [DetectLocalByCIDR (10.244.0.0/16)] Jump Not Local: [-A KUBE-SERVICES -m comment --comment "default/kubernetes:https cluster IP" -m tcp -p tcp -d 10.96.0.1/32 --dport 443 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ]
I0510 23:45:24.749592       1 traffic.go:91] [DetectLocalByCIDR (10.244.0.0/16)] Jump Not Local: [-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp -p udp -d 10.96.0.10/32 --dport 53 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ]
I0510 23:45:24.749736       1 traffic.go:91] [DetectLocalByCIDR (10.244.0.0/16)] Jump Not Local: [-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 53 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ]
I0510 23:45:24.749875       1 traffic.go:91] [DetectLocalByCIDR (10.244.0.0/16)] Jump Not Local: [-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 9153 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ]
I0510 23:45:24.750235       1 proxier.go:1592] Restoring iptables rules: *filter
:KUBE-SERVICES - [0:0]
:KUBE-EXTERNAL-SERVICES - [0:0]
:KUBE-FORWARD - [0:0]
-A KUBE-FORWARD -m conntrack --ctstate INVALID -j DROP
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding rules" -m mark --mark 0x00004000/0x00004000 -j ACCEPT
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding conntrack pod source rule" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding conntrack pod destination rule" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
COMMIT
*nat
:KUBE-SERVICES - [0:0]
:KUBE-NODEPORTS - [0:0]
:KUBE-POSTROUTING - [0:0]
:KUBE-MARK-MASQ - [0:0]
:KUBE-SVC-NPX46M4PTMTKRN6Y - [0:0]
:KUBE-SEP-V2PECCYPB6X2GSCW - [0:0]
:KUBE-SVC-TCOU7JCQXEZGVUNU - [0:0]
:KUBE-SEP-R7EMXN5TTQQVP4UW - [0:0]
:KUBE-SEP-LPGSDLJ3FDW46N4W - [0:0]
:KUBE-SEP-IRMT6RY5EEEBXDAY - [0:0]
:KUBE-SEP-LBMQNJ35ID4UIQ2A - [0:0]
:KUBE-SVC-ERIFXISQEP7F7OF4 - [0:0]
:KUBE-SEP-OP4AXEAS4OXHBEQX - [0:0]
:KUBE-SEP-LASJGFFJP3UOS6RQ - [0:0]
:KUBE-SEP-2Z3537XSN3RJRU3M - [0:0]
:KUBE-SEP-S7MPVVC7MGYVFSF3 - [0:0]
:KUBE-SVC-JD5MR3NA4I4DYORP - [0:0]
:KUBE-SEP-HJ7EWOW62IX6GL6R - [0:0]
:KUBE-SEP-FVQSBIWR5JTECIVC - [0:0]
:KUBE-SEP-275NWNNANOEIGYHG - [0:0]
:KUBE-SEP-CEWR77HQLZDHWWAJ - [0:0]
-A KUBE-POSTROUTING -m mark ! --mark 0x00004000/0x00004000 -j RETURN
-A KUBE-POSTROUTING -j MARK --xor-mark 0x00004000
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully
-A KUBE-MARK-MASQ -j MARK --or-mark 0x00004000
-A KUBE-SERVICES -m comment --comment "default/kubernetes:https cluster IP" -m tcp -p tcp -d 10.96.0.1/32 --dport 443 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -m comment --comment "default/kubernetes:https cluster IP" -m tcp -p tcp -d 10.96.0.1/32 --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment default/kubernetes:https -j KUBE-SEP-V2PECCYPB6X2GSCW
-A KUBE-SEP-V2PECCYPB6X2GSCW -m comment --comment default/kubernetes:https -s 172.18.0.2/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-V2PECCYPB6X2GSCW -m comment --comment default/kubernetes:https -m tcp -p tcp -j DNAT --to-destination 172.18.0.2:6443
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp -p udp -d 10.96.0.10/32 --dport 53 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp -p udp -d 10.96.0.10/32 --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment kube-system/kube-dns:dns -m statistic --mode random --probability 0.2500000000 -j KUBE-SEP-R7EMXN5TTQQVP4UW
-A KUBE-SEP-R7EMXN5TTQQVP4UW -m comment --comment kube-system/kube-dns:dns -s 10.244.0.10/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-R7EMXN5TTQQVP4UW -m comment --comment kube-system/kube-dns:dns -m udp -p udp -j DNAT --to-destination 10.244.0.10:53
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment kube-system/kube-dns:dns -m statistic --mode random --probability 0.3333333333 -j KUBE-SEP-LPGSDLJ3FDW46N4W
-A KUBE-SEP-LPGSDLJ3FDW46N4W -m comment --comment kube-system/kube-dns:dns -s 10.244.0.5/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-LPGSDLJ3FDW46N4W -m comment --comment kube-system/kube-dns:dns -m udp -p udp -j DNAT --to-destination 10.244.0.5:53
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment kube-system/kube-dns:dns -m statistic --mode random --probability 0.5000000000 -j KUBE-SEP-IRMT6RY5EEEBXDAY
-A KUBE-SEP-IRMT6RY5EEEBXDAY -m comment --comment kube-system/kube-dns:dns -s 10.244.0.6/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-IRMT6RY5EEEBXDAY -m comment --comment kube-system/kube-dns:dns -m udp -p udp -j DNAT --to-destination 10.244.0.6:53
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment kube-system/kube-dns:dns -j KUBE-SEP-LBMQNJ35ID4UIQ2A
-A KUBE-SEP-LBMQNJ35ID4UIQ2A -m comment --comment kube-system/kube-dns:dns -s 10.244.0.9/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-LBMQNJ35ID4UIQ2A -m comment --comment kube-system/kube-dns:dns -m udp -p udp -j DNAT --to-destination 10.244.0.9:53
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 53 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment kube-system/kube-dns:dns-tcp -m statistic --mode random --probability 0.2500000000 -j KUBE-SEP-OP4AXEAS4OXHBEQX
-A KUBE-SEP-OP4AXEAS4OXHBEQX -m comment --comment kube-system/kube-dns:dns-tcp -s 10.244.0.10/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-OP4AXEAS4OXHBEQX -m comment --comment kube-system/kube-dns:dns-tcp -m tcp -p tcp -j DNAT --to-destination 10.244.0.10:53
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment kube-system/kube-dns:dns-tcp -m statistic --mode random --probability 0.3333333333 -j KUBE-SEP-LASJGFFJP3UOS6RQ
-A KUBE-SEP-LASJGFFJP3UOS6RQ -m comment --comment kube-system/kube-dns:dns-tcp -s 10.244.0.5/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-LASJGFFJP3UOS6RQ -m comment --comment kube-system/kube-dns:dns-tcp -m tcp -p tcp -j DNAT --to-destination 10.244.0.5:53
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment kube-system/kube-dns:dns-tcp -m statistic --mode random --probability 0.5000000000 -j KUBE-SEP-2Z3537XSN3RJRU3M
-A KUBE-SEP-2Z3537XSN3RJRU3M -m comment --comment kube-system/kube-dns:dns-tcp -s 10.244.0.6/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-2Z3537XSN3RJRU3M -m comment --comment kube-system/kube-dns:dns-tcp -m tcp -p tcp -j DNAT --to-destination 10.244.0.6:53
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment kube-system/kube-dns:dns-tcp -j KUBE-SEP-S7MPVVC7MGYVFSF3
-A KUBE-SEP-S7MPVVC7MGYVFSF3 -m comment --comment kube-system/kube-dns:dns-tcp -s 10.244.0.9/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-S7MPVVC7MGYVFSF3 -m comment --comment kube-system/kube-dns:dns-tcp -m tcp -p tcp -j DNAT --to-destination 10.244.0.9:53
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 9153 ! -s 10.244.0.0/16 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp -p tcp -d 10.96.0.10/32 --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment kube-system/kube-dns:metrics -m statistic --mode random --probability 0.2500000000 -j KUBE-SEP-HJ7EWOW62IX6GL6R
-A KUBE-SEP-HJ7EWOW62IX6GL6R -m comment --comment kube-system/kube-dns:metrics -s 10.244.0.10/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-HJ7EWOW62IX6GL6R -m comment --comment kube-system/kube-dns:metrics -m tcp -p tcp -j DNAT --to-destination 10.244.0.10:9153
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment kube-system/kube-dns:metrics -m statistic --mode random --probability 0.3333333333 -j KUBE-SEP-FVQSBIWR5JTECIVC
-A KUBE-SEP-FVQSBIWR5JTECIVC -m comment --comment kube-system/kube-dns:metrics -s 10.244.0.5/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-FVQSBIWR5JTECIVC -m comment --comment kube-system/kube-dns:metrics -m tcp -p tcp -j DNAT --to-destination 10.244.0.5:9153
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment kube-system/kube-dns:metrics -m statistic --mode random --probability 0.5000000000 -j KUBE-SEP-275NWNNANOEIGYHG
-A KUBE-SEP-275NWNNANOEIGYHG -m comment --comment kube-system/kube-dns:metrics -s 10.244.0.6/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-275NWNNANOEIGYHG -m comment --comment kube-system/kube-dns:metrics -m tcp -p tcp -j DNAT --to-destination 10.244.0.6:9153
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment kube-system/kube-dns:metrics -j KUBE-SEP-CEWR77HQLZDHWWAJ
-A KUBE-SEP-CEWR77HQLZDHWWAJ -m comment --comment kube-system/kube-dns:metrics -s 10.244.0.9/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-CEWR77HQLZDHWWAJ -m comment --comment kube-system/kube-dns:metrics -m tcp -p tcp -j DNAT --to-destination 10.244.0.9:9153
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
COMMIT
I0510 23:45:24.750306       1 iptables.go:416] running iptables-restore [-w 5 -W 100000 --noflush --counters]
I0510 23:45:24.768834       1 proxier.go:1608] Network programming of kube-system/kube-dns took 0.768629 seconds
I0510 23:45:24.768943       1 service_health.go:183] Not saving endpoints for unknown healthcheck "kube-system/kube-dns"
I0510 23:45:24.769251       1 proxier.go:1637] Deleting stale services IPs: []
I0510 23:45:24.769573       1 proxier.go:1643] Deleting stale endpoint connections: []
I0510 23:45:24.769652       1 proxier.go:825] syncProxyRules took 117.246645ms
I0510 23:45:24.770182       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s
I0510 23:45:30.163213       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -S KUBE-PROXY-CANARY -t mangle]
I0510 23:46:00.163223       1 iptables.go:456] running iptables: iptables [-w 5 -W 100000 -S KUBE-PROXY-CANARY -t mangle]
```

That's what the complexity behind the dynamic kubernetes service loadbalancer.

## Buy me a drink

![wechat](assets/wechat.png)
![alipay](assets/alipay.png)
