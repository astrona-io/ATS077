# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Repository access

Save this as `repo.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: platform
  password: starfleet-gitops
```

Apply it:

```sh
kubectl apply -f repo.yaml
```

Then check that the Secret has the label:

```sh
kubectl -n argocd get secret -l argocd.argoproj.io/secret-type=repository
```

The Secret `repo-scout-deploy` is listed.

## Step 2: The Application

Save this as `app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f app.yaml
```

Then check the result:

```sh
kubectl -n staging wait --for=create deployment/scout --timeout=180s
kubectl -n staging rollout status deployment/scout --timeout=180s
kubectl -n argocd get application scout-staging
```

The Application shows `Synced` and `Healthy`. Run `astrona submit`. The checks `application-definition`, `delivered`, `self-heal` and `workloads-running` pass.

## If a check fails

- `application-definition` names the field that differs. Compare the repository URL character by character.
- `delivered` fails with a tracking message when the Deployment was applied by hand. Delete it and let the Application recreate it.
- `self-heal` fails when `selfHeal` is false. The check scales `scout` to three and waits for the controller to restore one replica.
- If the Application stays `OutOfSync` or shows a comparison error, read the conditions with `kubectl -n argocd get application scout-staging -o jsonpath='{.status.conditions}'`.
