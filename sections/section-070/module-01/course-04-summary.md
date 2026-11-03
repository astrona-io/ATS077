---
draft: true
exam_objectives:
- Continuous Delivery and GitOps
---
# Summary

GitOps keeps desired state declarative and versioned in a repository, and a controller pulls it and reconciles the cluster toward it. Storing files in Git does not deliver anything. Without an automated policy an Argo CD Application only reports `OutOfSync`. With `automated` it applies changes, `prune` removes what Git no longer declares, and `selfHeal` reverts manual changes. Drift is a difference between declared and live state, and the right response to an emergency change is to record it in the source or use an explicit temporary procedure.

Helm renders templates and values into manifests and tracks releases. Kustomize composes a base with overlays and patches. Neither provides continuous reconciliation. The controller renders them and reconciles the result. Review the rendered output, because a correct source value can still render a mismatched selector, a wrong namespace or an unintended permission. A rendered diff between two overlays shows exactly what differs between environments.

A promotion is a commit that changes the target environment, and the controller delivers it. The Application status records the revision it synced, and that value must equal the head of the branch for the commit to count as delivered. A revert is another commit and restores earlier declared state, but it cannot undo data changes or external effects. A configuration repository needs reviewed changes, protected identities and careful secret handling, because a compromised source publishes harmful state that a working controller then applies.

Key facts:

- A commit is intent. Delivery is proven by `Synced`, `Healthy` and the synced revision.
- `selfHeal` reverts live changes and `prune` deletes resources removed from Git.
- Rendered output is what the API receives, so review it.
- Promote with a commit, and record the commit hash that was synced.
- A revert restores configuration. It does not undo data or external effects.

<!-- astrona:playground:destroy -->
