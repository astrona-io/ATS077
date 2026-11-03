# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Guardrails

Label the namespaces, enforce the standard on `prod` only, and create the quota. Save this as `test-quota.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    pods: "5"
```

Apply it:

```sh
for ns in dev test prod; do kubectl label namespace $ns environment=$ns --overwrite; done
kubectl label namespace prod pod-security.kubernetes.io/enforce=restricted
kubectl apply -f test-quota.yaml
```

Then check:

```sh
kubectl get namespaces dev test prod --show-labels
kubectl -n test describe resourcequota test-quota
```

The list shows the `environment` label on each, and `prod` also shows the Pod Security label. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01 --keep
```

The check `environment-guardrails` passes.

## Step 2: Read-only access in prod

A role binding cannot change its `roleRef`, so remove the binding and create a new one. Only `prod` changes:

```sh
kubectl -n prod delete rolebinding drifter-team-edit
kubectl -n prod create rolebinding drifter-team-view --clusterrole=view --group=drifter-team
kubectl auth can-i create deployments.apps -n prod --as=casey --as-group=drifter-team
kubectl auth can-i get pods -n prod --as=casey --as-group=drifter-team
kubectl auth can-i create deployments.apps -n dev --as=casey --as-group=drifter-team
```

The answers are `no`, `yes` and `yes`. The `view` role reads most objects of a namespace but not Secrets. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01 --keep
```

The check `environment-access` passes.

## Step 3: Separate the data of test

Change the host of `test` and replace its Secret. The Secret is replaced from a client-side dry run, which writes a new value:

```sh
kubectl -n test patch configmap app-config --type=merge -p '{"data":{"DATABASE_HOST":"db.test.starfleet.internal"}}'
kubectl -n test create secret generic db-credentials --from-literal=password=test-only-value --dry-run=client -o yaml | kubectl replace -f -
```

The first command prints `configmap/app-config patched`, and the second prints `secret/db-credentials replaced`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/capstone/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-030
```

## Why it works

Labels and the quota are the guardrails: the label makes the environment selectable, the Pod Security label makes the API server reject unsafe pods in `prod`, and the quota caps the shared capacity of `test`. Access is a matter of bindings. The team keeps `edit` where it works and only gets `view` in production, and `view` excludes Secrets. A test environment that holds the production host or the production password is not a separate environment, so each gets its own values and `prod` is left unchanged.
