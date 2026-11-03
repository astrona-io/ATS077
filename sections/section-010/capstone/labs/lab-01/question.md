# Question

Solve this question on: `terminal`

The platform team keeps the declaration of the `shuttle` Deployment in the ConfigMap `desired-state` in `starfleet`, under the key `shuttle.yaml`. During an incident someone scaled `shuttle` by hand. The `drifter` team in `outpost` also needs workloads that the platform team can render and own. Bring all of it back under declaration.

1. Remove the drift from `shuttle`. Read the declaration from the ConfigMap and apply it with server-side apply under the field manager name `platform-team`. The manager that scaled the Deployment owns `spec.replicas`, so the apply must take that field on purpose. Afterwards `shuttle` has the replica count of the declaration and `platform-team` owns `spec.replicas`.

2. Render `scout` and `probe` for `outpost` from one Kustomize overlay. Use these two base Deployments, each in its own file, and a base `kustomization.yaml` that lists both. Neither base resource sets a namespace.

   - `scout`: image `ghcr.io/stefanprodan/podinfo:6.15.0`, container port 9898, label `app: scout`, 1 replica.
   - `probe`: image `mccutchen/go-httpbin:2.25.0`, container port 8080, label `app: probe`, 1 replica.

   Both Deployments need a `selector` that matches their `app` label and a pod template with the same label.

   The overlay must create `outpost-scout` with 2 replicas and `outpost-probe` with 1 replica in the namespace `outpost`. Every object, selector and pod template carries the label `team: drifter`. Both containers request `10m` CPU and `32Mi` memory. Apply the result.

3. A bare pod `drifter-debug` runs in `outpost`. Replace it with a Deployment `drifter-debug` with 1 replica and the label `app: drifter-debug`. Keep the image `curlimages/curl:8.22.0` and the command `sh -c "while true; do sleep 30; done"`. Remove the bare pod.

4. Record evidence in a ConfigMap `rollout-evidence` in `outpost` with these keys, copied from `outpost-scout` after its rollout finished: `generation` (`metadata.generation`), `observed-generation` (`status.observedGeneration`) and `ready-replicas` (`status.readyReplicas`).

Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator.
