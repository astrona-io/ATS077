# Question

Solve this question on: `terminal`

The pipeline has produced release `r2` (the ConfigMap `source` in `ci` holds the revision). `staging` and `production` both run the Deployment `scout` as release `r1`, using the image `ghcr.io/stefanprodan/podinfo:6.15.0` and the label `release=r1` on the pod template. Set up the pipeline identities, release `r2` through both environments with the same artifact, and write a release record.

1. Create three ServiceAccounts in `ci`: `ci-build`, `deploy-staging` and `deploy-production`. Give them the narrowest rights that fit their stage. `ci-build` may get, list, create, update and patch ConfigMaps and get, list and create Jobs in `ci`, and nothing else. `deploy-staging` may get, list, patch and update Deployments in `staging`, and nothing else. `deploy-production` may do the same in `production`, and nothing else. No account may delete Deployments, read Secrets, or touch any other namespace.

2. Release `r2`. Change the pod template label of `scout` to `release=r2`, first in `staging` and wait for the rollout, then in `production`. Do not change the image. On the production Deployment, set the annotation `kubernetes.io/change-cause` to `release r2` in the same change that updates the template.

3. In `ci`, create the ConfigMap `release-record` with the keys `revision` (`r2`), `image` (the image production runs), `deployed-revision` (the revision number that production reports in the annotation `deployment.kubernetes.io/revision`) and `previous-revision` (the revision number to return to if `r2` is wrong, one less than the deployed revision). Derive the values from the cluster.

Do not delete, scale down or replace `scout`, `probe` or `shuttle` in `starfleet`. `kubectl` already points at the cluster as the cluster administrator. Test the identities with `kubectl auth can-i --as=system:serviceaccount:ci:<name>`.
