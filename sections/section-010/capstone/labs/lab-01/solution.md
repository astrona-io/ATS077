# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Take the drifted field back

Compare the declaration with the live object. Write the declaration to a file first:

```sh
kubectl -n starfleet get configmap desired-state -o jsonpath='{.data.shuttle\.yaml}' > shuttle.yaml
kubectl diff -f shuttle.yaml
```

The diff shows `replicas` changing from `4` to `1`. A plain server-side apply fails with a conflict with the manager `kubectl`, which owns `spec.replicas` because of the `scale` command. The file is the truth here, so force the apply under a named manager:

```sh
kubectl apply --server-side --force-conflicts --field-manager=platform-team -f shuttle.yaml
```

The command prints `deployment.apps/shuttle serverside-applied`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/capstone/labs/lab-01 --keep
```

The check `shuttle-drift-removed` passes.

## Step 2: Render the outpost overlay

Save `base/scout.yaml`, `base/probe.yaml` and `base/kustomization.yaml` as the task describes. The base `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - scout.yaml
  - probe.yaml
```

Save this as `overlays/outpost/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: outpost
namePrefix: outpost-
resources:
  - ../../base
labels:
  - pairs:
      team: drifter
    includeSelectors: true
patches:
  - target:
      kind: Deployment
      name: scout
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
  - target:
      kind: Deployment
    patch: |-
      - op: add
        path: /spec/template/spec/containers/0/resources
        value:
          requests:
            cpu: 10m
            memory: 32Mi
```

The second patch has a `target` with only a `kind`, so it applies to every Deployment in the render. Read the render, then apply it:

```sh
kubectl kustomize overlays/outpost
kubectl apply -k overlays/outpost
kubectl -n outpost rollout status deployment/outpost-scout
kubectl -n outpost rollout status deployment/outpost-probe
```

The check `outpost-rendered` passes.

## Step 3: Replace the bare pod

Delete the pod and save this as `drifter-debug.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: drifter-debug
  namespace: outpost
  labels:
    app: drifter-debug
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drifter-debug
  template:
    metadata:
      labels:
        app: drifter-debug
    spec:
      serviceAccountName: drifter
      containers:
        - name: drifter-debug
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
```

```sh
kubectl -n outpost delete pod drifter-debug
kubectl apply -f drifter-debug.yaml
kubectl -n outpost rollout status deployment/drifter-debug
```

## Step 4: Record the status

Read the three numbers from the live object, then store them. The rollout of `outpost-scout` must be finished, otherwise the numbers change after you record them:

```sh
kubectl -n outpost get deployment outpost-scout -o jsonpath='{.metadata.generation} {.status.observedGeneration} {.status.readyReplicas}{"\n"}'
kubectl -n outpost create configmap rollout-evidence --from-literal=generation=1 --from-literal=observed-generation=1 --from-literal=ready-replicas=2
```

Replace the three numbers in the second command with the three numbers that the first command printed. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/capstone/labs/lab-01
```

All five checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-010
```

## Why it works

The manager that scaled `shuttle` owns `spec.replicas`, so a server-side apply without `--force-conflicts` stops with a conflict. Forcing the apply moves the field to `platform-team`, and the Deployment controller scales the ReplicaSet to the declared number. The overlay holds the differences for `outpost` in one place. The evidence compares `metadata.generation` with `status.observedGeneration`: when they are equal, the controller has processed the latest declaration.
