# Architecture Patterns Reference

This file defines the full pattern library used by `sdlc-architecture-design`.
Patterns are selected dynamically based on project characteristic tags extracted from the PRD.

---

## Pattern Selection Matrix

| Project Tag | Patterns to Include |
|-------------|---------------------|
| `frontend_heavy` | Micro-Frontends, BFF, Client-Server, Layered |
| `high_read_write_ratio` | CQRS, Event-Driven, Microservice |
| `event_driven` | Event-Driven, Serverless, Microservice |
| `multi_tenant` | Microservice, Hexagonal, Layered |
| `team_autonomy` | Microservice, Micro-Frontends, BFF, Plugin-Based |
| `low_ops_budget` | Serverless, Client-Server, Layered |
| `complex_domain` | Hexagonal, CQRS, Event-Driven, Plugin-Based |
| `rapid_prototype` | Client-Server, Serverless, Layered |
| `legacy_migration` | Micro-Frontends, Microservice, Plugin-Based |
| `ai_agent` | Event-Driven, Serverless, Hexagonal, Plugin-Based |

**Rule**: Select the top 4-6 patterns based on matching tags. If fewer than 4 tags match, default to: Layered, Hexagonal, Event-Driven, Microservice, Client-Server.

---

## Pattern 1: Layered Architecture

**Definition**: Organizes components into horizontal layers (Presentation, Business, Data), each with a specific responsibility.

**Best For**: CRUD applications, enterprise systems with predictable workflows, teams new to architecture patterns.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Low (layers depend only on adjacent layers) = 5; High (skip-layer dependencies) = 1 |
| Testability | Easy to unit test per layer = 5; Requires full stack integration = 2 |
| Scalability | Only whole-system scaling = 2; Can scale layers independently = 4 |
| Team Familiarity | Most developers understand layers = 5 |
| Maintenance Cost | Low for simple domains = 4; High for complex domains = 2 |

**Strengths**: Simple to understand, widely supported by frameworks, clear separation of concerns.

**Risks**: Layers can become "stupid pipes", business logic leaks between layers, hard to evolve independently.

**When to Reject**: Complex domain logic that doesn't fit CRUD, need for independent deployability.

---

## Pattern 2: Hexagonal Architecture (Ports and Adapters)

**Definition**: Application core is isolated from external concerns through "ports" (interfaces) and "adapters" (implementations).

**Best For**: Complex business domains, applications needing to swap external dependencies (DB, UI, APIs), test-driven development.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Core has zero external deps = 5; Adapters couple to specific tech = 3 |
| Testability | Core testable without DB/API = 5; Adapter tests need infra = 3 |
| Scalability | Depends on adapter choices = 3 |
| Team Familiarity | Requires DDD knowledge = 3 |
| Maintenance Cost | Low once established = 4; High learning curve = 2 |

**Strengths**: Business logic fully isolated, easy to swap technologies, excellent testability.

**Risks**: Overkill for simple CRUD, adapter boilerplate, team may struggle with indirection.

**When to Reject**: Simple CRUD with no expected tech swaps, team lacks DDD experience.

---

## Pattern 3: Event-Driven Architecture

**Definition**: Components communicate asynchronously through events, enabling loose coupling and reactive flows.

**Best For**: Real-time processing, workflows with multiple consumers, systems requiring high decoupling.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Producers know nothing about consumers = 5 |
| Testability | Hard to trace event chains = 2; With good tooling = 4 |
| Scalability | Excellent horizontal scaling = 5 |
| Team Familiarity | Requires understanding of async patterns = 2 |
| Maintenance Cost | Event schema evolution is hard = 2; Observability tooling helps = 4 |

**Strengths**: Excellent decoupling, natural fit for real-time, enables polyglot systems.

**Risks**: Eventual consistency complexity, debugging difficulty, schema evolution challenges, risk of event spaghetti.

**When to Reject**: Simple request-response workflows, team lacks observability tooling, strict consistency requirements.

---

## Pattern 4: Microservice Architecture

**Definition**: System composed of independently deployable services, each owning a bounded context.

**Best For**: Large teams, independent scaling needs, polyglot technology stacks, organizational autonomy.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Services share nothing = 5; Shared DB or lib = 1 |
| Testability | Contract tests required = 3; Integration tests complex = 2 |
| Scalability | Independent per-service scaling = 5 |
| Team Familiarity | Requires DevOps maturity = 2 |
| Maintenance Cost | High operational overhead = 1; With automation = 3 |

**Strengths**: Independent deployment and scaling, team autonomy, technology diversity.

**Risks**: Distributed system complexity, network latency, data consistency challenges, operational overhead.

**When to Reject**: Small teams (<3 per service), no independent scaling needs, network latency unacceptable.

---

## Pattern 5: Client-Server Architecture

**Definition**: Clear separation between client (UI/presentation) and server (data/logic), communicating over a network protocol.

**Best For**: Web applications, mobile backends, centralized data with distributed access.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Well-defined API boundary = 4; Fat client = 2 |
| Testability | Server testable independently = 4; Client needs mocks = 3 |
| Scalability | Server can scale independently = 4 |
| Team Familiarity | Ubiquitous pattern = 5 |
| Maintenance Cost | Low for simple 2-tier = 4 |

**Strengths**: Ubiquitous and well-understood, clear separation of concerns, server can be centralized.

**Risks**: Server becomes bottleneck, network dependency for all operations, limited offline capability.

**When to Reject**: Peer-to-peer requirements, heavy real-time collaboration, need for offline-first.

---

## Pattern 6: Plugin-Based Architecture

**Definition**: Core system provides extension points; functionality added via dynamically loaded plugins/modules.

**Best For**: Extensible platforms, product ecosystems, third-party integrations, IDEs and tools.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Plugin API is stable = 4; Plugins depend on internals = 1 |
| Testability | Core testable without plugins = 4; Plugin isolation needed = 3 |
| Scalability | Depends on plugin implementation = 3 |
| Team Familiarity | Requires API design skill = 3 |
| Maintenance Cost | API versioning burden = 2; With good design = 4 |

**Strengths**: Highly extensible, third-party ecosystem potential, core remains stable.

**Risks**: API design is critical and hard to change, plugin quality varies, security sandboxing needed.

**When to Reject**: No third-party extensibility needed, closed system, API stability cannot be guaranteed.

---

## Pattern 7: CQRS (Command Query Responsibility Segregation)

**Definition**: Separates read (Query) and write (Command) models, allowing independent optimization of each.

**Best For**: Read/write ratio > 10:1, complex query requirements, high-concurrency systems, reporting-heavy domains.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Command and query sides decoupled = 4; Shared event bus couples them = 3 |
| Testability | Each side simpler to test = 4; Consistency tests needed = 2 |
| Scalability | Read side scales independently = 5 |
| Team Familiarity | Significant mental leap = 1 |
| Maintenance Cost | Adds risky complexity = 1; In bounded context = 3 |

**Strengths**: Independent read/write scaling, query-side can be highly optimized, fits naturally with Event Sourcing.

**Risks**: Eventual consistency complexity, significant mental model shift, overkill for most systems, data synchronization challenges.

**When to Reject**: CRUD mental model sufficient, read/write loads similar, team lacks distributed systems experience.

**Critical Rule**: ONLY apply to specific Bounded Contexts, never the whole system.

---

## Pattern 8: BFF (Backend for Frontend)

**Definition**: Dedicated backend service per user experience (mobile, web, third-party), handling aggregation and adaptation.

**Best For**: Multiple distinct UIs consuming shared services, mobile-specific optimization, third-party API exposure.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | BFF tightly focused on one UI = 4; Shared BFF across clients = 2 |
| Testability | BFF testable with mocked services = 4 |
| Scalability | Per-experience scaling = 4 |
| Team Familiarity | Requires understanding of aggregation patterns = 3 |
| Maintenance Cost | Duplication across BFFs = 2; With shared libs = 3 |

**Strengths**: UI team autonomy, optimized payloads per client, isolates legacy APIs, release coupling reduced.

**Risks**: Duplication across BFFs, shared libraries reintroduce coupling, additional deployment overhead, temptation to bloat.

**When to Reject**: Single UI client, no aggregation needed, cannot tolerate extra network hop.

**Rule**: "One experience, one BFF" (iOS/Android may share if teams are unified).

---

## Pattern 9: Serverless / FaaS

**Definition**: Business logic runs in stateless, event-triggered functions managed by cloud provider.

**Best For**: Event-driven processing, variable workloads, low operational overhead, rapid prototyping.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Functions triggered by events = 4; Shared state couples = 2 |
| Testability | Local emulation difficult = 2; With good tooling = 4 |
| Scalability | Automatic to thousands/second = 5 |
| Team Familiarity | Requires cloud-native mindset = 2 |
| Maintenance Cost | Low ops = 5; Cold start tuning = 3 |

**Strengths**: Auto-scaling, pay-per-use, no server management, rapid deployment.

**Risks**: Cold start latency, vendor lock-in, debugging difficulty, state management complexity, execution time limits (15min on AWS).

**When to Reject**: Long-running processes, predictable steady-state workloads (cheaper to use VMs), need for low latency without provisioned concurrency.

---

## Pattern 10: Micro-Frontends

**Definition**: Independently deliverable frontend applications composed at runtime into a cohesive whole.

**Best For**: Large frontend codebases, multiple frontend teams, incremental migration from legacy, technology upgrades.

**Evaluation Dimensions**:
| Dimension | Score Guide |
|-----------|-------------|
| Coupling | Runtime composition = 4; Build-time = 1 |
| Testability | Standalone dev mode = 3; Integration gaps = 2 |
| Scalability | Independent deployment scaling = 4 |
| Team Familiarity | Requires org maturity = 2 |
| Maintenance Cost | Multiple repos/pipelines = 2; With automation = 3 |

**Strengths**: Independent deployment, simpler codebases per team, incremental upgrades, autonomous teams.

**Risks**: Duplicate dependencies increase payload, standalone dev mode risks production integration failures, operational complexity, styling isolation challenges.

**When to Reject**: Small frontend team (<2 teams), no independent delivery need, cannot accept runtime integration risk.

**Recommended Companion**: BFF pattern for each micro-frontend.

---

## Cross-Cutting Concerns

When evaluating any pattern, always consider:

1. **State Management**: Where is state stored? Who writes? Who reads? What is the lifecycle?
2. **Failure Modes**: What happens when a dependency fails? Is there a degradation path?
3. **Observability**: Can you trace a request across the architecture? Is logging centralized?
4. **Security**: Is authentication enforced at every boundary? Is data encrypted in transit and at rest?
5. **Evolution**: How much existing code must change to add a new feature module?
