# Platform Engineering Core Fundamentals (ATS077)

Certified Cloud Native Platform Engineering Associate (CNPA): Platform Engineering Core Fundamentals, worth 36% of the official curriculum. This course belongs to ATP016.

Developed reading explains mechanisms, responsible components, examples and limits. Every section has an introduction and every module closes with a summary. Every module has a playground and a graded lab, every section has a capstone lab and a quiz, and a final domain quiz closes the course. Labs run on kind (Kubernetes 1.35) and were built without being run: they are untested. Technical content remains draft.

## Course Outline

| Section / module | Module | Teaching files | Lab and capstone |
| --- | --- | --- | --- |
| 010 / 01 | Sufficient Intent, Rendering And Controller Contracts | Desired State, The API Server And Controllers; Rendering Declarations With Kustomize; Ownership, Drift And Field Managers | Declare, Render And Apply Under A Field Manager Lab; Declarative Resource Management Capstone |
| 020 / 01 | Shared Ownership, Feedback And Platform Enablement | Shared Ownership And Platform Enablement; Feedback Signals: Probes, Rollouts And Rollback; DevSecOps Guardrails In The Platform | Ownership, Probes And A Restricted Namespace Lab; DevOps Practices Capstone |
| 030 / 01 | Environment Boundaries, Dependencies And Resource Isolation | Environments And The Boundaries That Separate Them; Quotas, Limits And Capacity Isolation; Identity, Data And Environment Lifecycle | Quota, Defaults And Parity Lab; Environment Boundaries Capstone |
| 040 / 01 | Capability Layers, Control Planes And Supported Interfaces | Capability Layers And Supported Interfaces; A Custom Resource As A Platform API; Guardrails, Failure Domains And Ownership | Custom Resource As A Platform API Lab; Platform Architecture Capstone |
| 050 / 01 | User Needs, Golden Paths And Incremental Platform Adoption | User Needs And Platform Goals; Golden Paths With A Kustomize Base; Adoption, Feedback And Exceptions | Golden Path Base For Two Teams Lab; Platform Goals Capstone |
| 060 / 01 | Build And Release Pipelines | Source Changes And Build Evidence; Delivery, Deployment And Promotion Decisions; Pipeline Identities, Release Records And Rollback | Pipeline Stages And Promotion Lab; Pipeline Fundamentals Capstone |
| 070 / 01 | GitOps And Deployment Configuration | GitOps Reconciliation And Drift; Helm, Kustomize And Configuration Rendering; Promotion Through Git And Revision Evidence | GitOps Delivery Lab; GitOps And Deployment Capstone |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). Labs and playgrounds were checked statically only (`astrona validate`, `bash -n`, YAML parsing); no runtime execution is claimed.
