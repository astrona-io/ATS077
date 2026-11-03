---
draft: true
exam_objectives:
- Continuous Integration Fundamentals
---
# Summary

A pipeline turns reviewed source revisions into checked, identifiable artifacts. Continuous integration gives feedback on the checks that are configured, and a passing run proves only those checks. Each stage has an input, a command and an exit status. A failed stage stops the pipeline and writes no build record. A build record ties the source revision to the artifact and the checks, and the artifact needs an identity that does not move. A version tag can point at a different image later, and a digest identifies the exact bytes. Rebuilding after testing can produce a different artifact unless the inputs are controlled, so the pipeline builds once and promotes the same artifact.

Promotion runs that artifact in the next environment, and the environment supplies its own configuration. When production misbehaves, the comparison of artifact identity and configuration shows what differs. Continuous delivery keeps changes releasable and waits for a decision before production. Continuous deployment promotes every qualifying change without that decision. The gate is what separates them, and a gate is useful only when its opener has evidence. Deployment and user-visible release can happen at different times, for example with a feature flag. A configuration change is a release as well, even when the image stays the same, and a running pod reads its environment variables from a ConfigMap only when it starts.

Each stage should run as its own identity. A build stage needs source access and the right to publish, and a production stage needs the right to update a scoped set of workloads. A Role per namespace limits the damage of a leaked credential, and `kubectl auth can-i` proves the boundary without changing anything. A release record names the revision, the artifact, the configuration and the Deployment revision number, and the Deployment stores a revision and a change cause. Rollback restores an earlier pod template under a new revision number, so the record must be updated afterwards. It does not reverse data migrations, feature flags or external side effects, so the recovery plan must cover them as well.

Key facts:

- A failed check must stop promotion, and an ignored failure removes the protection.
- Build once, promote the same artifact, and vary only the configuration.
- Delivery waits for a release decision. Deployment is automatic.
- Each stage gets the narrowest identity that works.
- A rollback needs a record update and does not undo data or external effects.

<!-- astrona:playground:destroy -->
