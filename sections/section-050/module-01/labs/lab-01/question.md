# Question

Solve this question on: `terminal`

The platform team wants two teams to deploy a web service the same way. Instead of each team writing its own manifest, the platform publishes a golden path as a Kustomize base. Two namespaces already exist, `bridge` and `engine`, and both enforce the `restricted` Pod Security Standard. Build the base, write one overlay for each team and apply both.

1. Build a Kustomize base with a Deployment named `web` and a Service named `web`. The Deployment uses the image `ghcr.io/stefanprodan/podinfo:6.15.0`, labels its pods `app: web` and selects on that label, and names its container port `http` (`9898`). It has a readiness probe that does an HTTP GET on `/readyz` at the named port. It requests `10m` CPU and `32Mi` memory and has a memory limit of `64Mi`. The pod runs as non-root with the numeric user `1000`, uses the `RuntimeDefault` seccomp profile, and the container does not allow privilege escalation and drops all capabilities. The Service selects `app: web` and exposes port `80` to the named port `http`. The base sets no namespace.

2. The base labels its workloads for the platform. The Deployment and its pod template both carry the label `platform.starfleet.io/path: golden`.

3. Write the overlay for `bridge`: namespace `bridge`, `2` replicas, and the label `team: bridge` on the objects and in the pod template. Write the overlay for `engine`: namespace `engine`, the default replica count, and the label `team: engine` in the same places. Apply both with `kubectl apply -k`.

Both Services must have a ready endpoint for each replica. Do not delete, scale down or replace `scout`, `probe` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator. Use `kubectl kustomize` to read the rendered result before you apply it.
