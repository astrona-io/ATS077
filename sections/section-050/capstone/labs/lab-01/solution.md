# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Measure first

Count the labels and the verified settings side by side:

```sh
kubectl -n adopt get deployments -L platform.starfleet.io/path
kubectl -n adopt get deployments -o json | jq -r '.items[] | [.metadata.name, (.spec.template.spec.containers[0].readinessProbe != null), (.spec.template.spec.containers[0].resources.limits != null)] | @tsv'
```

The first command shows `golden` for `bridge-web` and `engine-web`, and nothing for `drifter-web`. The second shows `true` and `true` for `bridge-web`, and `false` and `false` for the other two. Two workloads claim the path, and one of them meets it. The label of `engine-web` is a claim and not a fact.

## Step 2: Bring engine-web onto the path

Save this as `engine-web.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-web
  namespace: adopt
  labels:
    app: engine-web
    platform.starfleet.io/path: golden
spec:
  replicas: 1
  selector:
    matchLabels:
      app: engine-web
  template:
    metadata:
      labels:
        app: engine-web
        platform.starfleet.io/path: golden
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: web
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              memory: 64Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
```

Apply it and wait for the rollout:

```sh
kubectl apply -f engine-web.yaml
kubectl -n adopt rollout status deployment/engine-web --timeout=120s
```

The command prints `deployment.apps/engine-web configured`, and the rollout ends with `successfully rolled out`. The pod template changed, so the Deployment replaces its pod. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/capstone/labs/lab-01 --keep
```

`engine-on-path` passes. `exception-recorded` and `adoption-report` still fail.

## Step 3: Record the exception

```sh
kubectl -n adopt label deployment drifter-web platform.starfleet.io/path=exception
kubectl -n adopt annotate deployment drifter-web platform.starfleet.io/exception-reason="legacy image, no probe endpoint agreed" platform.starfleet.io/exception-review="2027-01-31"
kubectl -n adopt get deployments -L platform.starfleet.io/path
```

The `PATH` column now shows `golden` twice and `exception` once. Changing labels and annotations of the Deployment does not change its pod template, so no rollout happens.

## Step 4: Report from the cluster

```sh
total=$(kubectl -n adopt get deployments -o json | jq '.items | length')
onpath=$(kubectl -n adopt get deployments -l platform.starfleet.io/path=golden -o json | jq '[.items[] | select(.spec.template.spec.containers[0].readinessProbe != null and .spec.template.spec.containers[0].resources.limits.memory != null)] | length')
exceptions=$(kubectl -n adopt get deployments -l platform.starfleet.io/path=exception -o json | jq '.items | length')
kubectl -n adopt create configmap adoption-report --from-literal=onpath=$onpath --from-literal=exceptions=$exceptions --from-literal=total=$total
kubectl -n adopt get configmap adoption-report -o jsonpath='{.data}{"\n"}'
```

The last command prints an object with `exceptions` `1`, `onpath` `2` and `total` `3`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/capstone/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-050
```

## Why it works

A label states a claim, and the settings of the pod template are the evidence. The first measurement shows the difference, so the report does not repeat a wrong number. Bringing `engine-web` onto the path changes its pod template, so Kubernetes replaces the pod. The exception keeps `drifter-web` visible with a reason and a review date, and it changes nothing about how the workload runs. The report is computed from the cluster, so running the same commands later gives the new counts.
