---
draft: true
exam_objectives:
- Continuous Delivery and GitOps
---
# Promotion Through Git And Revision Evidence

The `staging` environment runs `scout` 6.15.0 and `production` runs 6.14.0. The team wants production on 6.15.0. In a GitOps workflow the change is a commit to the repository, and the controller delivers it. No one runs `kubectl set image` against production.

A promotion in this model has three parts. The change is written in the source of truth, reviewed there, and recorded with a revision identifier. The controller pulls the revision and applies it. The Application status then names the revision it reached, which is the evidence that the commit was delivered.

```mermaid
flowchart LR
    A["Commit to main"] --> B["Git revision"]
    B -->|"pull"| C["Argo CD Application"]
    C -->|"apply"| D["Production Deployment"]
    C -->|"records"| E["status.sync.revision"]
```

Promotion through Git has an audit trail. The history shows who changed the production tag, when, and in which commit. A direct cluster edit leaves no such record in the source and is reverted by `selfHeal` anyway.

## The environment

The playground has Argo CD and a Gitea server with the repository `starfleet/scout-deploy`. No Application exists yet.

<!-- astrona:playground:renew -->

Save this as `production.yaml`. It gives the controller read access and declares the production Application with automated sync:

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
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-production
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply it and wait for production to settle:

```sh
kubectl apply -f production.yaml
kubectl -n production wait --for=create deploy/scout --timeout=180s
kubectl -n production rollout status deploy/scout --timeout=180s
kubectl -n production get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The last command prints `ghcr.io/stefanprodan/podinfo:6.14.0`. Note the revision the controller reached:

```sh
kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}{"\n"}'
```

The output is a 40-character commit hash. It is the head of `main` right now.

## Make the change as a commit

Reach the Git server and clone the repository:

```sh
kubectl -n gitea port-forward svc/gitea-http 3000:3000 >/dev/null 2>&1 &
sleep 3
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

Change the production tag, commit and push:

```sh
sed -i.bak 's/newTag: 6.14.0/newTag: 6.15.0/' overlays/production/kustomization.yaml
rm overlays/production/kustomization.yaml.bak
git diff
git -c user.name=platform -c user.email=platform@starfleet.local commit -am "Promote scout to 6.15.0 in production"
git push origin main
git rev-parse HEAD
```

The diff shows one changed line, `newTag: 6.14.0` replaced by `newTag: 6.15.0`. The last command prints the new commit hash. The commit is reviewable, attributable and the only thing that changed.

## Watch the controller deliver it

The controller polls the repository on an interval, so allow a short wait. Then read the image and the revision:

```sh
sleep 30
kubectl -n production rollout status deploy/scout --timeout=180s
kubectl -n production get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}{"\n"}'
```

The image is now `ghcr.io/stefanprodan/podinfo:6.15.0`. The revision printed by the last command equals the hash printed by `git rev-parse HEAD`. That equality is the evidence of delivery. If the two differ, the controller has not yet reached the commit, or it failed to render or apply it, and the Application conditions show the reason:

```sh
kubectl -n argocd get application scout-production -o jsonpath='{.status.conditions}{"\n"}'
```

An empty result means no error conditions are set.

## Revert through Git

A bad release is also undone with a commit. Revert the promotion and push:

```sh
git revert --no-edit HEAD
git push origin main
sleep 30
kubectl -n production rollout status deploy/scout --timeout=180s
kubectl -n production get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The image is back to `6.14.0`. The history now holds three entries, the original state, the promotion and the revert, and nothing was rewritten. A revert restores declared configuration. It cannot reverse a data migration that the new version ran or any message it sent, so recovery must cover state outside the repository.

Stop the port-forward when you finish:

```sh
cd ..
kill %1
```

## What you know now

A promotion is a commit on the environment path, and the controller delivers it. The synced revision in the Application status must equal the branch head for the commit to count as delivered. A revert is a new commit that restores earlier configuration, and it does not undo data or external effects.

## Common pitfalls

> [!WARNING]
> Pushing a commit does not prove delivery. Compare the synced revision with the branch head.
> Do not edit production with `kubectl`. Self-heal reverts it and the source stays unchanged.
> A revert restores configuration only. Plan recovery for data and external effects.
