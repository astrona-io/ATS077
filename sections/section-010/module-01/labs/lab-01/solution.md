# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`. It stays your guard while you work.

## Step 1: Replace the bare pod with a Deployment

Confirm that the pod has no owner. The command prints nothing when there is no owner reference:

```sh
kubectl -n starfleet get pod shuttle-debug -o jsonpath='{.metadata.ownerReferences}'
```

Delete the pod. Then save this as `shuttle-debug.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle-debug
  namespace: starfleet
  labels:
    app: shuttle-debug
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shuttle-debug
  template:
    metadata:
      labels:
        app: shuttle-debug
    spec:
      serviceAccountName: shuttle
      containers:
        - name: shuttle-debug
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
```

Apply it and wait for the rollout:

```sh
kubectl -n starfleet delete pod shuttle-debug
kubectl apply -f shuttle-debug.yaml
kubectl -n starfleet rollout status deployment/shuttle-debug
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/module-01/labs/lab-01 --keep
```

The check `debug-pod-managed` now passes.

## Step 2: Render the overlay for outpost

Save the base Deployment from the task as `base/deployment.yaml`. Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
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
      tier: edge
    includeSelectors: true
patches:
  - target:
      kind: Deployment
      name: scout
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
```

Read the render before you apply it. The Deployment is named `outpost-scout`, has namespace `outpost`, `replicas: 2` and the label `tier: edge` in three places:

```sh
kubectl kustomize overlays/outpost
```

## Step 3: Apply under the field manager platform-team

Pipe the render to a server-side apply with a named manager:

```sh
kubectl kustomize overlays/outpost | kubectl apply --server-side --field-manager=platform-team -f -
kubectl -n outpost rollout status deployment/outpost-scout
```

The apply prints `deployment.apps/outpost-scout serverside-applied`. Check who owns the fields:

```sh
kubectl -n outpost get deployment outpost-scout --show-managed-fields -o jsonpath='{range .metadata.managedFields[*]}{.manager}{" "}{.operation}{"\n"}{end}'
```

The list contains `platform-team Apply`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-010/module-01/labs/lab-01
```

All four checks pass.

Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-010-01
```

## Why it works

The bare pod had no owner reference, so no controller repaired it. The Deployment creates a ReplicaSet, and the ReplicaSet owns the pods and recreates them. The overlay holds the differences for `outpost`, and the base stays unchanged. The label with `includeSelectors: true` keeps the selector and the pod template aligned, so the API server accepts the Deployment. The server-side apply records `platform-team` as the owner of the fields it sets.
