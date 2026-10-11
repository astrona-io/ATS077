---
draft: true
exam_objectives:
- Continuous Integration Fundamentals
---
# Delivery, Deployment And Promotion Decisions

The `scout` pipeline produces a release-ready artifact after checks. Continuous delivery keeps software in a state that can be released through a controlled decision. Continuous deployment automatically deploys qualifying changes without a separate manual release approval. Both can use the same build and test foundation.

The abbreviation CD is used for both practices, so the decision gate matters more than the abbreviation. A pipeline that waits for a human to approve production promotion can still support continuous delivery. A pipeline that promotes every passing change automatically implements continuous deployment if its other requirements are met.

Deployment changes what runs in an environment. Release can also mean making behavior available to users. A feature flag can let deployed code remain inactive until an explicit decision enables it. This separation can reduce some release risks, but old and new behavior must still be tested and compatible.

Promotion needs permissions and environment-specific controls. A build service that compiles source does not necessarily need permission to modify production workloads. Separate identities and scoped credentials limit the consequences of compromised build inputs or tools.

A good release record identifies the artifact, configuration change, approvals where applicable and observed result. It should support both investigation and reversal. Rolling back an image alone may not reverse a changed database schema or an external side effect.

For a scenario, find where the decision occurs. Automatic tests followed by a manual production approval indicate continuous delivery. Automatic production deployment of every qualifying change indicates continuous deployment. Neither label guarantees that the resulting application is healthy without representative validation and monitoring.

## Locating The Release Decision

Consider a pipeline with automatic compilation, testing and staging deployment, followed by a manual production approval. It keeps the change ready for release and supports continuous delivery. Removing the final approval and automatically promoting every qualifying change changes the production decision to continuous deployment. Automated testing by itself does not distinguish them.

A team can also deploy dormant functionality controlled by a feature flag. The application bytes reach production before the feature becomes available to users. The flag needs ownership, monitoring and cleanup so old inactive branches do not become permanent hidden complexity. Switching a flag can also have compatibility and security consequences even without rebuilding an image.

Release gates should match the risk. A manual approval is useful only when the approver has meaningful evidence and authority. An automated gate is useful only when its checks reflect the required behavior. Neither a person clicking a button nor a green icon alone establishes that the release is safe.

## Separating Pipeline Identities

The build stage may need source access and permission to publish to one artifact repository. The production delivery stage may need to update a scoped workload set. Granting the build process unrestricted cluster access combines these trust boundaries unnecessarily. A compromised dependency or build step can then affect the deployment environment directly.

Keep secrets out of ordinary logs and limit credentials to the stages that use them. A short-lived deployment identity reduces exposure compared with a widely shared permanent credential, while repository protections control who can change pipeline instructions. These controls preserve the integrity of the release decision.

Finally, record a recovery plan for more than the image. Configuration, data migrations, feature flags and external side effects can survive image rollback. Delivery and deployment practices work well when the team can explain both how a qualifying change reaches users and how an unsuitable change is detected and corrected.

## Common pitfalls

> [!WARNING]
> Deployment and user-visible release can happen at different times. An image rollback does not automatically reverse database migrations or external effects.
