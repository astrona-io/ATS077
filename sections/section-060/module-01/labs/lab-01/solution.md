# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: The check stage

Read the revision that the stage must check:

```sh
kubectl -n ci get configmap source -o jsonpath='{.data.revision}{"\n"}'
```

The command prints `r7`. Save this as `unit-checks.yaml`, and use the revision you read in the label and in the command:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: unit-checks
  namespace: ci
  labels:
    ci.starfleet.io/revision: r7
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        ci.starfleet.io/revision: r7
    spec:
      restartPolicy: Never
      containers:
        - name: check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c"]
          args:
            - test "$(cat /source/revision)" = "r7" && test -n "$(cat /source/greeting)"
          volumeMounts:
            - name: source
              mountPath: /source
      volumes:
        - name: source
          configMap:
            name: source
```

Apply it and wait:

```sh
kubectl apply -f unit-checks.yaml
kubectl -n ci wait --for=condition=complete job/unit-checks --timeout=120s
```

The first command prints `job.batch/unit-checks created`, and the second prints `job.batch/unit-checks condition met`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/module-01/labs/lab-01 --keep
```

`check-stage` passes. If it fails, its output names the missing label, the mount or the status.

## Step 2: The build record

```sh
kubectl -n ci create configmap build-record --from-literal=revision=r7 --from-literal=image=ghcr.io/stefanprodan/podinfo:6.15.0 --from-literal=checks=passed --from-literal=job=unit-checks
kubectl -n ci get configmap build-record -o jsonpath='{.data}{"\n"}'
```

The second command prints the four keys. `build-record` now passes. The image is read from this record in the next step, so both environments use the same value.

## Step 3: Promote to both environments

Read the image from the record and create both environments from it:

```sh
IMAGE=$(kubectl -n ci get configmap build-record -o jsonpath='{.data.image}')
for env in staging production; do
  kubectl -n $env create configmap app-config --from-literal=PODINFO_UI_MESSAGE=$env
  kubectl -n $env apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
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
          image: $IMAGE
          ports:
            - name: http
              containerPort: 9898
          envFrom:
            - configMapRef:
                name: app-config
YAML
done
kubectl -n staging rollout status deployment/scout --timeout=120s
kubectl -n production rollout status deployment/scout --timeout=120s
```

Each pass prints one line for the ConfigMap and one for the Deployment, and both rollouts end with `successfully rolled out`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/module-01/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-060-01
```

## Why it works

The Job turns the check into a stage with an exit status, and the label ties it to the source revision it checked. The build record ties the revision to the artifact and the checks. Both environments take the image from the record, so the bytes are the same and only `app-config` differs. A difference between staging and production is then a configuration difference.
