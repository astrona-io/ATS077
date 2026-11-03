# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

Work in an empty directory, for example `golden`. Create the folders first:

```sh
mkdir -p golden/base golden/overlays/bridge golden/overlays/engine
```

## Step 1: The base

Save this as `golden/base/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
    platform.starfleet.io/path: golden
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
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

Save this as `golden/base/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: http
```

Save this as `golden/base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

Render the base and read it:

```sh
kubectl kustomize golden/base
```

The command prints a Service and a Deployment with no namespace. Nothing is applied yet. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/module-01/labs/lab-01 --keep
```

All checks except `workloads-running` fail, because nothing runs in the team namespaces.

## Step 2: The two overlays

Save this as `golden/overlays/bridge/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: bridge
resources:
  - ../../base
replicas:
  - name: web
    count: 2
labels:
  - pairs:
      team: bridge
    includeTemplates: true
```

Save this as `golden/overlays/engine/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: engine
resources:
  - ../../base
labels:
  - pairs:
      team: engine
    includeTemplates: true
```

Render one overlay and check that the namespace, the replicas and the `team` label appear, then apply both:

```sh
kubectl kustomize golden/overlays/bridge
kubectl apply -k golden/overlays/bridge
kubectl apply -k golden/overlays/engine
kubectl -n bridge rollout status deployment/web --timeout=120s
kubectl -n engine rollout status deployment/web --timeout=120s
```

Each `apply -k` prints one `created` line for the Service and one for the Deployment. The namespaces enforce the `restricted` standard, and the pods are accepted because the base already meets it. Each rollout prints `successfully rolled out`. Check the endpoints and grade the whole task:

```sh
kubectl get endpointslices -A -l kubernetes.io/service-name=web
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-050/module-01/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-050-01
```

## Why it works

The base holds everything that is the same for every team, so a team that uses it gets the probe, the limits and the restricted security context without writing them. The overlay holds only the choices of the team: the namespace, the replica count and the team label. The `labels` transformer with `includeTemplates` also writes the label into the pod template, so the pods carry it. The path label on the Deployment and the template lets the platform find every workload on the path with one selector.
