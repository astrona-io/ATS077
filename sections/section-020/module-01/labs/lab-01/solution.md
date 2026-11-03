# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Label the pod templates

A label on a Deployment does not reach its pods. The pods take their labels from `spec.template.metadata.labels`. Patch the three Deployments:

```sh
kubectl -n starfleet patch deployment scout --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"owner":"bridge-team"}}}}}'
kubectl -n starfleet patch deployment probe --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"owner":"bridge-team"}}}}}'
kubectl -n starfleet patch deployment shuttle --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"owner":"bridge-team"}}}}}'
```

Each command prints `deployment.apps/<name> patched`. The change starts a rollout for each Deployment. Wait for them and list the pods:

```sh
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet rollout status deployment/probe
kubectl -n starfleet rollout status deployment/shuttle
kubectl -n starfleet get pods -l owner=bridge-team
```

The list shows one pod for each Deployment. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/module-01/labs/lab-01 --keep
```

The check `owner-labels` passes.

## Step 2: Add the readiness probe

Save this as `probe-readiness.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
        - name: probe
          readinessProbe:
            httpGet:
              path: /status/200
              port: http
            periodSeconds: 5
```

Apply it and wait for the rollout:

```sh
kubectl -n starfleet patch deployment probe --patch-file probe-readiness.yaml
kubectl -n starfleet rollout status deployment/probe
```

The check `probe-readiness` now passes. If the path were wrong, the new pod would never become ready and the rollout would wait. That is the feedback the probe gives.

## Step 3: Enforce the restricted standard in sandbox

Ask what the namespace would reject before you enforce it:

```sh
kubectl label --dry-run=server --overwrite namespace sandbox pod-security.kubernetes.io/enforce=restricted
```

The command prints warnings for the existing `crew` pod, which has no security context. Enforce the label and fix the Deployment. Save this as `crew-restricted.yaml`:

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: crew
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
```

```sh
kubectl label namespace sandbox pod-security.kubernetes.io/enforce=restricted
kubectl -n sandbox patch deployment crew --patch-file crew-restricted.yaml
kubectl -n sandbox rollout status deployment/crew
```

Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/module-01/labs/lab-01
```

All four checks pass.

Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-020-01
```

## Why it works

The `owner` label is in the pod template, so the ReplicaSet gives it to every pod. The readiness probe lets the kubelet report when `probe` can answer requests, and the rolling update waits for it. Pod Security Admission judges new pods against the `restricted` standard, and the patched `crew` pod sets every field that the standard requires: a non-root numeric user, no privilege escalation, no capabilities and the runtime default system-call filter.
