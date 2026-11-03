# Question

Solve this question on: `terminal`

The platform team of the `starfleet` namespace wants every workload declared and every field owned. A first review found a bare pod and a team that has no declaration yet.

1. A pod named `shuttle-debug` runs in `starfleet`. No controller owns it, so nothing recreates it. Replace it with a Deployment named `shuttle-debug` in `starfleet` that has 2 replicas, the label `app: shuttle-debug` and the same image as the pod. Remove the bare pod. The pod runs a loop that never exits: `sh -c "while true; do sleep 30; done"`.

2. The `drifter` team in `outpost` needs its own copy of `scout`. Render it with Kustomize. Create a base directory with this Deployment and a `kustomization.yaml` that lists it:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: scout
     labels:
       app: scout
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: scout
     template:
       metadata:
         labels:
           app: scout
       spec:
         containers:
           - name: scout
             image: ghcr.io/stefanprodan/podinfo:6.15.0
             ports:
               - name: http
                 containerPort: 9898
   ```

   Create an overlay that sets the namespace `outpost`, the name prefix `outpost-`, the label `tier: edge` on the objects, the selector and the pod template, and 2 replicas. The result must be a Deployment `outpost-scout` in `outpost` with 2 available replicas.

3. Apply the rendered overlay with server-side apply under the field manager name `platform-team`.

Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator.
