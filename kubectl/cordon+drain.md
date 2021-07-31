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

- kubectl (un)cordon

Cordon or Uncordon is more about toggle switch of
`node.spec.unschedulable`, `kube-scheduler` will respect this flag at
the stage of `Predicates`.

```shell
$ kubectl explain node.spec.unschedulable
KIND:     Node
VERSION:  v1

FIELD:    unschedulable <boolean>

DESCRIPTION:
     Unschedulable controls node schedulability of new pods. By default, node is
     schedulable. More info:
     https://kubernetes.io/docs/concepts/nodes/node/#manual-node-administration
```

And it's implementation is quite easy to understand, note that it will
try to choose patch in the first and backoff to update if patch json
created failed.

```go
// PatchOrReplaceWithContext provides the option to pass a custom context while updating
// the node status
func (c *CordonHelper) PatchOrReplaceWithContext(clientCtx context.Context, clientset kubernetes.Interface, serverDryRun bool) (error, error) {
	client := clientset.CoreV1().Nodes()

	oldData, err := json.Marshal(c.node)
	if err != nil {
		return err, nil
	}

	c.node.Spec.Unschedulable = c.desired

	newData, err := json.Marshal(c.node)
	if err != nil {
		return err, nil
	}

	patchBytes, patchErr := strategicpatch.CreateTwoWayMergePatch(oldData, newData, c.node)
	if patchErr == nil {
		patchOptions := metav1.PatchOptions{}
		if serverDryRun {
			patchOptions.DryRun = []string{metav1.DryRunAll}
		}
		_, err = client.Patch(clientCtx, c.node.Name, types.StrategicMergePatchType, patchBytes, patchOptions)
	} else {
		updateOptions := metav1.UpdateOptions{}
		if serverDryRun {
			updateOptions.DryRun = []string{metav1.DryRunAll}
		}
		_, err = client.Update(clientCtx, c.node, updateOptions)
	}
	return err, patchErr
}
```
