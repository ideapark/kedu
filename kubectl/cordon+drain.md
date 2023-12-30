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

- kubectl drain

First, list all the pods on the node to be drained.

``` go
// GetPodsForDeletion receives resource info for a node, and returns those pods as PodDeleteList,
// or error if it cannot list pods. All pods that are ready to be deleted can be obtained with .Pods(),
// and string with all warning can be obtained with .Warnings(), and .Errors() for all errors that
// occurred during deletion.
func (d *Helper) GetPodsForDeletion(nodeName string) (*PodDeleteList, []error) {
	labelSelector, err := labels.Parse(d.PodSelector)
	if err != nil {
		return nil, []error{err}
	}

	podList := &corev1.PodList{}
	initialOpts := &metav1.ListOptions{
		LabelSelector: labelSelector.String(),
		FieldSelector: fields.SelectorFromSet(fields.Set{"spec.nodeName": nodeName}).String(),
		Limit:         d.ChunkSize,
	}

	err = resource.FollowContinue(initialOpts, func(options metav1.ListOptions) (runtime.Object, error) {
		newPods, err := d.Client.CoreV1().Pods(metav1.NamespaceAll).List(d.getContext(), options)
		if err != nil {
			podR := corev1.SchemeGroupVersion.WithResource(corev1.ResourcePods.String())
			return nil, resource.EnhanceListError(err, options, podR.String())
		}
		podList.Items = append(podList.Items, newPods.Items...)
		return newPods, nil
	})

	if err != nil {
		return nil, []error{err}
	}

	list := filterPods(podList, d.makeFilters())
	if errs := list.errors(); len(errs) > 0 {
		return list, errs
	}

	return list, nil
}
```

Second, it will evict pod if server supports or backoff to delete pod.
