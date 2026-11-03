# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Quota and defaults in dev

Save this as `dev-limits.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    pods: "4"
    requests.memory: 256Mi
    limits.memory: 512Mi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-defaults
  namespace: dev
spec:
  limits:
    - type: Container
      defaultRequest:
        memory: 16Mi
      default:
        memory: 64Mi
```

Apply it:

```sh
kubectl apply -f dev-limits.yaml
```

Then check:

```sh
kubectl -n dev describe resourcequota dev-quota
kubectl -n dev describe limitrange dev-defaults
```

The first command shows the three hard values with `Used` at zero. The second shows the Container defaults. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01 --keep
```

The check `dev-limits` passes.

## Step 2: The crew Deployment

Create the Deployment without any resources. The quota covers memory, and the LimitRange fills in the values, so the pods are accepted:

```sh
kubectl -n dev create deployment crew --image=ghcr.io/stefanprodan/podinfo:6.15.0 --replicas=2
kubectl -n dev rollout status deployment/crew
kubectl -n dev get pods -o jsonpath='{.items[0].spec.containers[0].resources}{"\n"}'
```

The create command prints `deployment.apps/crew created`. The last command prints a JSON object with a memory limit of `64Mi` and a request of `16Mi`. If the pods do not appear, the Deployment was created before the LimitRange existed. Run `kubectl -n dev rollout restart deployment/crew`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01 --keep
```

The check `dev-workload` passes.

## Step 3: Make the configuration consistent

Add the missing key to `test` and change the log level of `prod`. A merge patch changes only the named keys:

```sh
kubectl -n test patch configmap app-config --type=merge -p '{"data":{"DATABASE_HOST":"db.test.starfleet.internal"}}'
kubectl -n prod patch configmap app-config --type=merge -p '{"data":{"LOG_LEVEL":"warn"}}'
```

Each command prints `configmap/app-config patched`. Compare the key sets:

```sh
for ns in dev test prod; do kubectl -n $ns get configmap app-config -o jsonpath='{.data}{"\n"}'; done
```

Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-030/module-01/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-030-01
```

## Why it works

The API server runs the LimitRange first and then checks the quota with the filled-in values. A pod without requests would be refused when the quota covers memory, so the LimitRange is what makes the quota usable for a workload that declares nothing. The configuration check compares the key sets, because a test environment that lacks a key of production cannot prove how production behaves, and it compares the values, because a copied production host removes the boundary.
