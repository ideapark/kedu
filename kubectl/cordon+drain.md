# How the `kubectl (un)cordon` and `kubectl drain` works

You can use `kubectl drain` to safely evict all of your pods from a
node before you perform maintenance on the node (e.g. kernel upgrade,
hardware maintenance, etc.). Safe evictions allow the pod's containers
to gracefully terminate and will respect the `PodDisruptionBudgets`
you have specified.

Often the steps applied will be:

    kubectl cordon      ;; mark node unschedulable
    kubectl drain       ;; drain all non-system pods from this node
    kubectl uncordon    ;; mark node schedulable again
