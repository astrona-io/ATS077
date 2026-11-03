# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-070/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`, and `applications-intact` also passes.

## Step 1: Commit the promotion

Clone the repository through the port-forward:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
```

Change the tag, commit and push:

```sh
sed -i.bak 's/newTag: 6.14.0/newTag: 6.15.0/' overlays/production/kustomization.yaml
rm overlays/production/kustomization.yaml.bak
git diff
git -c user.name=platform -c user.email=platform@starfleet.local commit -am "Promote scout to 6.15.0 in production"
git push origin main
```

The diff shows one changed line. Then check that Git has the commit:

```sh
git rev-parse HEAD
```

The command prints the commit hash.

## Step 2: Wait for delivery

The controller polls the repository on an interval:

```sh
sleep 30
kubectl -n production rollout status deployment/scout --timeout=240s
kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}{"\n"}'
```

The revision equals the hash from `git rev-parse HEAD` and the Application shows `Synced` and `Healthy`. Run `astrona submit`. The check `production-promoted` passes.

## Step 3: The record

Save this as `record.sh`:

```sh
COMMIT="$(git rev-parse HEAD)"
SYNCED="$(kubectl -n argocd get application scout-production -o jsonpath='{.status.sync.revision}')"
IMAGE="$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}')"
kubectl -n argocd create configmap promotion-record \
  --from-literal=commit="$COMMIT" \
  --from-literal=synced-revision="$SYNCED" \
  --from-literal=image="$IMAGE" \
  --from-literal=environment=production
```

Run it from inside the cloned repository:

```sh
bash record.sh
```

Then check the ConfigMap:

```sh
kubectl -n argocd get configmap promotion-record -o yaml
```

The data holds four keys. Run `astrona submit`. All four checks pass.

## If a check fails

- `production-promoted` reports the field that differs. If Git has the new tag and the Application is `OutOfSync`, wait for the next poll and read `kubectl -n argocd get application scout-production -o jsonpath='{.status.conditions}'`.
- `promotion-record` fails when the keys were copied before the controller reached the commit. Delete the ConfigMap and create it again.
- If `git push` is rejected, run `git pull --rebase origin main` and push again.
- `applications-intact` fails when `selfHeal` was turned off or the Deployment was edited by hand.
