# kube-scheduler

- Overview

When a Pod is first created, it generally doesn’t have a nodeName field. The
nodeName indicates the node on which the Pod should execute. The Kubernetes
scheduler is constantly scanning the API server (via a watch request) for Pods
that don’t have a nodeName; these are Pods that are eligible for scheduling. The
scheduler then selects an appropriate node for the Pod and updates the Pod
definition with the nodeName that the scheduler selected. After the nodeName is
set, the kubelet running on that node is notified about the Pod’s existence
(again, via a watch request) and it begins to actually execute that Pod on that
node.

- Predicates

When making the decision about how to schedule a Pod, the scheduler uses two
generic concepts to make its decision. The first is predicates. Simply stated, a
predicate indicates whether a Pod fits onto a particular node. Predicates are
hard constraints, which, if violated, lead to a Pod not operating correctly (or
at all) on that node. An example of a such a constraint is the amount of memory
requested by the Pod. If that memory is unavailable on the node, the Pod cannot
get all of the memory that it needs and the constraint is violated -- it is
false. Another example of a predicate is a node-selector label query specified
by the user. In this case, the user has requested that a Pod only run on certain
machines as indicated by the node labels. The predicate is false if a node does
not have the required label.

| PREDICATES             | DESCRIPTION                                                                                                                  |
|------------------------|------------------------------------------------------------------------------------------------------------------------------|
| PodFitsHostPorts       | Checks if a Node has free ports (the network protocol kind) for the Pod ports the Pod is requesting.                         |
| PodFitsHost            | Checks if a Pod specifies a specific Node by its hostname.                                                                   |
| PodFitsResources       | Checks if the Node has free resources (eg, CPU and Memory) to meet the requirement of the Pod.                               |
| MatchNodeSelector      | Checks if a Pod's Node Selector matches the Node's label(s).                                                                 |
| NoVolumeZoneConflict   | Evaluate if the Volumes that a Pod requests are available on the Node, given the failure zone restrictions for that storage. |
| NoDiskConflict         | Evaluates if a Pod can fit on a Node due to the volumes it requests, and those that are already mounted.                     |
| MaxCSIVolumeCount      | Decides how many CSI volumes should be attached, and whether that's over a configured limit.                                 |
| PodToleratesNodeTaints | Checks if a Pod's tolerations can tolerate the Node's taints.                                                                |
| CheckVolumeBinding     | Evaluates if a Pod can fit due to the volumes it requests. This applies for both bound and unbound PVCs.                     |

- Priorities

Predicates indicate situations that are either true or false -- the Pod either
fits or it doesn’t -- but there is an additional generic interface used by the
scheduler to determine preference for one node over another. These preferences
are expressed as priorities or priority functions. The role of a priority
function is to score the relative value of scheduling a Pod onto a particular
node. In contrast to predicates, the priority function does not indicate whether
or not the Pod being scheduled onto the node is viable -- it is assumed that the
Pod can successfully execute on the node -- but instead, the predicate function
attempts to judge the relative value of scheduling the Pod on to that particular
node.

As an example, a priority function would weight nodes where the image has
already been pulled. Therefore, the container would start faster than nodes
where the image is not present and would have to be pulled, delaying Pod
startup.

One important priority function is the spreading function. This function is
responsible for prioritizing nodes where Pods that are members of the same
Kubernetes Service are not present. It is used to ensure reliability, since it
reduces the chances that a machine failure will disable all of the containers in
a particular Service.

Ultimately, all of the various predicate values are mixed together to achieve a
final priority score for the node, and this score is used to determine where the
Pod is scheduled.

| PRIORITIES                       | DESCRIPTION                                                                                                                                                                                                                                                                                     |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SelectorSpreadPriority           | Spreads Pods across hosts, considering Pods that belong to the same Service, StatefulSet or ReplicaSet.                                                                                                                                                                                         |
| InterPodAffinityPriority         | Implements preferred inter pod affininity and antiaffinity.                                                                                                                                                                                                                                     |
| LeastRequestedPriority           | Favors nodes with fewer requested resources. In other words, the more Pods that are placed on a Node, and the more resources those Pods use, the lower the ranking this policy will give.                                                                                                       |
| MostRequestedPriority            | Favors nodes with most requested resources. This policy will fit the scheduled Pods onto the smallest number of Nodes needed to run your overall set of workloads.                                                                                                                              |
| RequestedToCapacityRatioPriority | Creates a requestedToCapacity based ResourceAllocationPriority using default resource scoring function shape.                                                                                                                                                                                   |
| BalancedResourceAllocation       | Favors nodes with balanced resource usage.                                                                                                                                                                                                                                                      |
| NodePreferAvoidPodsPriority      | Prioritizes nodes according to the node annotation scheduler.alpha.kubernetes.io/preferAvoidPods. You can use this to hint that two different Pods shouldn't run on the same Node.                                                                                                              |
| NodeAffinityPriority             | Prioritizes nodes according to node affinity scheduling preferences indicated in PreferredDuringSchedulingIgnoredDuringExecution. You can read more about this in Assigning Pods to Nodes.                                                                                                      |
| TaintTolerationPriority          | Prepares the priority list for all the nodes, based on the number of intolerable taints on the node. This policy adjusts a node's rank taking that list into account.                                                                                                                           |
| ImageLocalityPriority            | Favors nodes that already have the container images for that Pod cached locally.                                                                                                                                                                                                                |
| ServiceSpreadingPriority         | For a given Service, this policy aims to make sure that the Pods for the Service run on different nodes. It favours scheduling onto nodes that don't have Pods for the service already assigned there. The overall outcome is that the Service becomes more resilient to a single Node failure. |
| EqualPriority                    | Gives an equal weight of one to all nodes.                                                                                                                                                                                                                                                      |
| EvenPodsSpreadPriority           | Implements preferred pod topology spread constraints.                                                                                                                                                                                                                                           |
