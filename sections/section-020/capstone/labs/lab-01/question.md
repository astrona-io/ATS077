# Question

Solve this question on: `terminal`

The `drifter-team` takes over the `drifter` workload in `outpost`, and the `bridge-team` has just started a release of `probe` in `starfleet` that did not finish. Recover the release and build the boundary in which the `drifter-team` can deploy alone.

1. Recover `probe`. A rollout of the Deployment `probe` in `starfleet` to an image tag that does not exist is stuck, and the old pod still serves. Return `probe` to its previous working template (image `mccutchen/go-httpbin:2.25.0`) without deleting the Deployment. Then add an HTTP readiness probe to the `probe` container on the path `/status/200` and the named port `http`, so that the next failed release is visible. All replicas must be updated and available.

2. Guardrail for `outpost`. The namespace `outpost` must reject pods that do not meet the `restricted` Pod Security Standard. The Deployment `drifter` runs `sh -c "while true; do sleep 30; done"` as it comes from the image. Make its pods comply, with the numeric user ID `1000`, and add the pod label `owner=drifter-team` so that the owner is known.

3. Access for the team. The group `drifter-team` must be able to create, read and update Deployments in `outpost` and read pods and their logs there. It must not delete Deployments, read Secrets or change anything in `starfleet`. Create the smallest set of objects that grants this. Do not use the built-in `edit` or `admin` roles.

Do not delete, scale down or replace `scout` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator. Check an identity with `kubectl auth can-i ... --as=<user> --as-group=drifter-team`.
