# Curriculum Coverage

Exam: Certified Cloud Native Platform Engineering Associate (CNPA). Domain: Platform Engineering Core Fundamentals (36%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-cloud-native-platform-engineering-associate-cnpa/) were checked on 2026-10-11. Teaching structure is independently authored and does not add official requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Declarative Resource Management | 1 |
| 020 | DevOps Practices in Platform Engineering | 1 |
| 030 | Application Environments and Infrastructure Concepts | 1 |
| 040 | Platform Architecture and Capabilities | 1 |
| 050 | Platform Engineering Goals, Objectives, and Approaches | 1 |
| 060 | Continuous Integration Fundamentals | 1 |
| 070 | Continuous Delivery and GitOps | 1 |

| Section / module | Module | Teaching files | Lab and capstone |
| --- | --- | --- | --- |
| 010 / 01 | Sufficient Intent, Rendering And Controller Contracts | Desired State, The API Server And Controllers; Rendering Declarations With Kustomize; Ownership, Drift And Field Managers | Declare, Render And Apply Under A Field Manager Lab; Declarative Resource Management Capstone |
| 020 / 01 | Shared Ownership, Feedback And Platform Enablement | Shared Ownership And Platform Enablement; Feedback Signals: Probes, Rollouts And Rollback; DevSecOps Guardrails In The Platform | Ownership, Probes And A Restricted Namespace Lab; DevOps Practices Capstone |
| 030 / 01 | Environment Boundaries, Dependencies And Resource Isolation | Environments And The Boundaries That Separate Them; Quotas, Limits And Capacity Isolation; Identity, Data And Environment Lifecycle | Quota, Defaults And Parity Lab; Environment Boundaries Capstone |
| 040 / 01 | Capability Layers, Control Planes And Supported Interfaces | Capability Layers And Supported Interfaces; A Custom Resource As A Platform API; Guardrails, Failure Domains And Ownership | Custom Resource As A Platform API Lab; Platform Architecture Capstone |
| 050 / 01 | User Needs, Golden Paths And Incremental Platform Adoption | User Needs And Platform Goals; Golden Paths With A Kustomize Base; Adoption, Feedback And Exceptions | Golden Path Base For Two Teams Lab; Platform Goals Capstone |
| 060 / 01 | Build And Release Pipelines | Source Changes And Build Evidence; Delivery, Deployment And Promotion Decisions; Pipeline Identities, Release Records And Rollback | Pipeline Stages And Promotion Lab; Pipeline Fundamentals Capstone |
| 070 / 01 | GitOps And Deployment Configuration | GitOps Reconciliation And Drift; Helm, Kustomize And Configuration Rendering; Promotion Through Git And Revision Evidence | GitOps Delivery Lab; GitOps And Deployment Capstone |

AUTHORING.yaml records measurable goals and adaptation sources. Every objective retains its section ID. All technical readings remain draft. Question banks are separate from the reading manifest and follow their declared summaries. Every module has a playground and a graded lab, every section has a capstone lab and a quiz, and `sections/final-domain-quiz.yaml` closes the course. Labs and playgrounds were validated statically only and have not been run.
