---
draft: true
exam_objectives:
- Platform Engineering Goals, Objectives, and Approaches
---
# Summary

Platform engineering begins with the needs of the users. A need is something a user must do and cannot do easily, and a goal states the improvement the platform delivers for it. A goal names the user, the task and the change, and it needs a baseline, so that an improvement can be shown. Outputs, such as templates and tools, are easy to count and do not show value. Evidence for needs comes from interviews, support requests and incidents, and also from the cluster, where the objects show what teams set and what they leave out. A count of what is missing is a symptom, and the team that owns the workload explains the cause. Prioritization weighs how many users have the need, how often and at what cost, and whether the platform can remove it.

A golden path is a supported, opinionated way to complete a common task. It contains the settings the platform recommends, such as a readiness probe, resource limits, a restricted security context and a label that makes the workload findable. With Kustomize, the platform team publishes a base and each team writes a small overlay with its own choices, such as namespace, replicas and team label. The base should not set what the team decides. A namespace that enforces the Pod Security Standard confirms that the path meets the baseline, and a team that writes its own manifest has to meet it by itself. A change in the base reaches teams on their next apply, so the base needs versions and notice of breaking changes.

A path is adopted because it is easier and safer, not because it is required. A mandate produces labels on paper and workarounds in practice. The path leaves a label on its workloads so that the platform can find them, and the label is only a claim. A report must verify the settings behind the label and count the verified ones. A workload that cannot follow the path gets a documented exception with a reason and a review date, so that it stays visible and honest. The workloads that have neither state are the ones to follow up with their owners.

Feedback closes the loop. Numbers show where adoption stops, and conversations with teams show why. The next change is small, announced and measured against the baseline. Old versions of the path are retired on a published schedule.

Key facts:

- A goal names a user, a task and a change, and has a baseline.
- Counting outputs does not show value, and outcome measures follow the user's task.
- A golden path packages the platform's defaults, and the team supplies what is specific to its service.
- A label that claims the path is not evidence of adoption. Verify the settings.
- An exception needs a reason and a review date.

<!-- astrona:playground:destroy -->
