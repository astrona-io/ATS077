---
draft: true
exam_objectives:
- Declarative Resource Management
---
# Summary

Declarative resource management stores the state a team wants, not the steps to reach it. In Kubernetes a declaration is a resource with a `spec`. The API server validates it and stores it in etcd, and controllers watch the stored objects. Each controller runs a reconciliation loop that compares `spec` with what exists and changes the system until the two match. The API server only stores intent. The controllers do the work.

A declaration has sufficient intent when a controller can reach the end state without more input from a person. It states what the user cares about, such as the image and the number of replicas, and leaves the choices that the platform can make, such as the node. A script that holds commands in version control is not declarative, because the result of each command depends on the state of the cluster when it runs. A repository of resource documents is declarative, because applying a document twice gives the same state.

Rendering produces the final documents from a small set of inputs. Kustomize combines a base, patches and transformers such as `namespace`, `namePrefix`, `labels` and `images`, and gives the same output for the same inputs. A render does not contact the cluster and does not prove that the result works. Reviewing the rendered output and the output of a diff against the live cluster are the checks before an apply.

Owner references connect an object to the controller that repairs it. A Pod owned by a ReplicaSet is recreated after a deletion, and a Pod without an owner is not. Controllers repair the objects they own, but nothing repairs a change to the top-level declaration. Such a change is drift, and a comparison with the source of truth finds it. Field managers record who wrote each field, and server-side apply turns a silent overwrite into a conflict that a person resolves on purpose.

A controller reports its progress in `status`. When `status.observedGeneration` is lower than `metadata.generation`, the status describes an older declaration. The conditions of a Deployment show whether it is available and whether a rollout progresses. A controller cannot infer what is missing from the declaration: it cannot restore a deleted top-level object, and it cannot know that a version should match another environment.

Key facts:

- `spec` holds desired state, and `status` holds the observed state that a controller writes.
- Reconciliation is a loop that runs continuously, not a script that runs once.
- Applying the same document again leaves the cluster unchanged.
- `kubectl kustomize` renders without contacting the cluster, and `kubectl diff -k` shows the change before it is applied.
- A conflict in server-side apply means that another manager owns the field.

<!-- astrona:playground:destroy -->
