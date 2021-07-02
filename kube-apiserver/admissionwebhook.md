# kube-apiserver extensibility points: admission controller

kube-apiserver request AdmissionReview, admissioncontroller response
AdmissionResponse

- validating admission control

evaluate based upon business logical, return true for acceptence,
otherwise false for rejection and reasons.

- mutating admission controller

execute mutating logical such as injecting sidecar container
transparently.
