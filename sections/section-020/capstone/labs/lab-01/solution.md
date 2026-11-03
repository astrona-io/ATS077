# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Roll back probe and add the readiness probe

Look at the state of the release first. The old pod is ready, and the new pod cannot pull its image:

```sh
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet rollout history deployment/probe
```

The list has one running pod and one pod in `ErrImagePull` or `ImagePullBackOff`. The history has two revisions. Return to the previous one:

```sh
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe
```

The `undo` command prints `deployment.apps/probe rolled back`. Save this as `probe-readiness.yaml`:

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

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/capstone/labs/lab-01 --keep
```

The check `probe-recovered` passes.

## Step 2: Restrict outpost and fix drifter

Save this as `drifter-restricted.yaml`:

```yaml
spec:
  template:
    metadata:
      labels:
        owner: drifter-team
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: drifter
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
```

Enforce the standard, then patch the Deployment. Existing pods are not evicted by the label, so the patch makes sure that the new pods comply:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/enforce=restricted
kubectl -n outpost patch deployment drifter --patch-file drifter-restricted.yaml
kubectl -n outpost rollout status deployment/drifter
```

The check `outpost-restricted` passes.

## Step 3: Give the team a boundary

Save this as `team-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: outpost
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-team-deployer
  namespace: outpost
subjects:
  - kind: Group
    name: drifter-team
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: deployer
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f team-access.yaml
```

Then check the result:

```sh
kubectl auth can-i update deployments.apps -n outpost --as=casey --as-group=drifter-team
kubectl auth can-i delete deployments.apps -n outpost --as=casey --as-group=drifter-team
kubectl auth can-i update deployments.apps -n starfleet --as=casey --as-group=drifter-team
```

The answers are `yes`, `no` and `no`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-020/capstone/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-020
```

## Why it works

The failed rollout stopped because the new pod never became ready, so the old pod kept serving. `rollout undo` returns the Deployment to the template of the previous ReplicaSet, and the readiness probe makes the next failure visible. The label on `outpost` makes the API server reject pods that break the `restricted` standard, and the patched template meets it. The Role lists only the verbs that the team needs on one namespace, so the RoleBinding gives no access to Secrets, deletion or `starfleet`.
