# XML Schema Reference

This document defines the strict schemas for the three-layer XML architecture documentation system.
All XML files must validate against these schemas.

---

## Layer 1: System Architecture (`architecture.xml`)

**File location**: `docs/architecture/system/architecture.xml` (or `skill/artifacts/architecture.xml`)

**Root element**: `SystemArchitecture`

**Required attributes on root**:
- `type`: One of {layered, hexagonal, event-driven, microservice, client-server, plugin-based, cqrs, bff, serverless, micro-frontends}
- `version`: Semantic version string (e.g., "1.0.0")

**Child elements**:

### `DecisionTrace`
Contains one or more `Decision` nodes documenting architecture decisions.

**Decision attributes**:
- `id`: Unique decision ID (format: `arch-dec-{NNNN}`)
- `date`: ISO-8601 date string

**Decision children**:
- `Question`: The architectural question that was decided
- `Answer`: The decision made
- `Risk`: Known risks of this decision

### `Module`
Represents a top-level system module. One per bounded context or service.

**Module attributes**:
- `id`: Unique module identifier (camelCase, no spaces)
- `owner`: Team or responsible party

**Module children**:
- `Responsibility`: Text description of what this module does
- `Interface`: Defines the module's public contract
  - `Input` (1+): Attributes: `schema` (required), `protocol` (optional, default "HTTP/JSON")
  - `Output` (1+): Attributes: `schema` (required), `protocol` (optional)
  - `ErrorCodes` (0+): Contains `Error` nodes with `code` and `description` attributes
- `Coupling`: Contains `DependsOn` nodes
  - `DependsOn` attributes: `module` (required), `reason` (optional)
- `ModuleDetail` (optional but recommended): Reference to module-level XML
  - Attribute: `ref` (relative path from system XML to module XML)

### `DataModel`
Defines system-wide data entities.

**DataModel children**:
- `Entity` (1+): Attributes: `id`, `module`
  - `Fields`: Contains `Field` nodes
    - `Field` attributes: `name`, `type`, `nullable` (boolean), `encrypted` (boolean, optional)
  - `CacheStrategy` (optional): Attributes: `type`, `ttl` (seconds)

### `StateModel`
Defines where state lives, who owns it, and its lifecycle.

**StateModel children**:
- `State` (1+): Attributes:
  - `id` (required): State identifier
  - `location` (required): Storage system (e.g., "PostgreSQL", "Redis", "S3")
  - `owner` (required): Module id that writes this state
  - `consumer` (optional): Comma-separated list of module ids that read this state
  - `lifecycle` (required): Lifecycle policy string in format:
    `create:{event}, read:{event}, update:{event}, delete:{event}, cleanup:{policy}`

### `Security`
System-wide security policies.

**Security children**:
- `Authentication`: Attributes: `type`, `issuer`, `audience`
- `Encryption`: Attributes: `inTransit` (e.g., "TLS1.3"), `atRest` (e.g., "AES-256")

---

## Layer 2: Module Architecture (`module-architecture.xml`)

**File location**: `docs/architecture/modules/{module_id}/module-architecture.xml`

**Root element**: `ModuleArchitecture`

**Required attributes on root**:
- `id`: Must match the corresponding `Module/@id` in system XML
- `version`: Semantic version string

**Child elements**:

### `ParentSystem`
Reference back to the parent system architecture.

- Attribute: `ref` (relative path to system `architecture.xml`)

### `Constraints`
Inherited obligations from the system level. Must not be violated by module-level design.

**Constraints children**:
- `InterfaceConstraint`: Contains `Input` and `Output` nodes mirroring the system-level interface
  - `Input` attributes: `schema` (required), `must` (boolean, default "true")
  - `Output` attributes: `schema` (required), `must` (boolean, default "true")

### `Components`
Module-internal component decomposition.

**Components children**:
- `Component` (1+): Attributes:
  - `id`: Component identifier (camelCase)
  - `type`: One of {entry_point, domain_service, repository, utility, controller, service, gateway}

**Component children**:
- `Responsibility`: Text description
- `Type`: Component classification (redundant with attribute, for readability)
- `Input` (0+): Attributes: `schema`
- `Output` (0+): Attributes: `schema`
- `ComponentDetail` (optional): Reference to component-level spec
  - Attribute: `ref` (relative path to `component-spec.xml`)

### `ComponentInterfaces`
Explicit interfaces between components within this module.

**ComponentInterfaces children**:
- `Interface` (0+): Attributes:
  - `from`: Source component id
  - `to`: Target component id
  - `protocol` (optional): e.g., "in-process", "gRPC", "HTTP"

**Interface children**:
- `Method` (1+): Attributes:
  - `name`: Method name
  - `input`: Input schema or type
  - `output`: Output schema or type
  - `async` (boolean, optional): Whether the call is asynchronous

### `ModuleStateModel`
Module-scoped state definitions.

**ModuleStateModel children**:
- `State` (1+): Same attributes as system-level `State`
  - `id`, `location`, `owner`, `consumer`, `lifecycle`

---

## Layer 3: Component Specification (`component-spec.xml`)

**File location**: `docs/architecture/modules/{module_id}/components/{component_id}/component-spec.xml`

**Root element**: `ComponentSpec`

**Required attributes on root**:
- `id`: Must match the corresponding `Component/@id` in module XML
- `version`: Semantic version string

**Child elements**:

### `ParentModule`
Reference back to the parent module architecture.

- Attribute: `ref` (relative path to `module-architecture.xml`)

### `Metadata`
Implementation technology constraints.

**Metadata children**:
- `Language`: Programming language (e.g., "Python", "TypeScript", "Go")
- `Framework`: Primary framework (e.g., "FastAPI", "React", "Spring Boot")
- `FilePath`: Expected source file path (relative to project root)

### `Functions`
Detailed function specifications. This is the authority for code generation.

**Functions children**:
- `Function` (1+): Attributes:
  - `id`: Unique function identifier within this component
  - `async` (boolean, default "false"): Whether the function is async
  - `traceTo` (optional): Reference to PRD user story or requirement ID

**Function children**:
- `Signature`: CDATA containing the exact function signature. Must be parseable by code generators.
- `Logic`: Step-by-step business logic description
  - `Step` (1+): Attributes:
    - `order` (integer): Execution order
    - `description`: Human-readable step description
- `ErrorHandling`: Explicit error cases
  - `Error` (1+): Attributes:
    - `code`: HTTP status code or internal error code
    - `condition`: When this error occurs
    - `response`: Expected response payload (JSON format)
    - `log` (boolean, optional): Whether this error must be logged
- `Tests`: Required test coverage
  - `Test` (1+): Attributes:
    - `id`: Test case ID
    - `type`: One of {happy_path, abnormal, performance, security}
    - `description`: What this test verifies

### `Dependencies`
External dependencies required by this component.

**Dependencies children**:
- `Dependency` (1+): Attributes:
  - `id`: Dependency identifier (must match a component id or external service name)
  - `injection`: Injection pattern: {constructor, setter, singleton, factory}
  - `optional` (boolean, optional): Whether the dependency is optional

### `CodeTemplate` (Optional)
Code generation hints.

**CodeTemplate children**:
- `Header`: CDATA containing required file header comments (e.g., architecture decision references)

---

## Cross-Layer Validation Rules

### Rule 1: ID Consistency
- `ModuleArchitecture/@id` MUST equal a `Module/@id` in system XML
- `ComponentSpec/@id` MUST equal a `Component/@id` in the parent module XML

### Rule 2: Interface Consistency
- System `Module/Interface/Input/@schema` MUST be present in Module `Constraints/InterfaceConstraint/Input/@schema`
- System `Module/Interface/Output/@schema` MUST be present in Module `Constraints/InterfaceConstraint/Output/@schema`

### Rule 3: Reference Integrity
- `ModuleDetail/@ref` MUST resolve to an existing file
- `ComponentDetail/@ref` MUST resolve to an existing file
- `ParentSystem/@ref` MUST resolve to the system `architecture.xml`
- `ParentModule/@ref` MUST resolve to the parent `module-architecture.xml`

### Rule 4: State Lifecycle Completeness
Every `State` MUST define all five lifecycle phases in its `lifecycle` attribute:
- `create`, `read`, `update`, `delete`, `cleanup`

### Rule 5: Coupling Directionality
- `Coupling/DependsOn/@module` MUST reference a `Module/@id` that exists in the system XML
- Circular dependencies between modules SHOULD be flagged as warnings

---

## Example: Minimal Valid Files

### System Level (excerpt)
```xml
<SystemArchitecture type="microservice" version="1.0.0">
  <Module id="UserService" owner="team-auth">
    <Interface>
      <Input schema="LoginRequest" protocol="HTTP/JSON"/>
      <Output schema="AuthToken" protocol="HTTP/JSON"/>
    </Interface>
    <ModuleDetail ref="modules/UserService/module-architecture.xml"/>
  </Module>
</SystemArchitecture>
```

### Module Level (excerpt)
```xml
<ModuleArchitecture id="UserService" version="1.0.0">
  <ParentSystem ref="../../architecture.xml"/>
  <Constraints>
    <InterfaceConstraint>
      <Input schema="LoginRequest" must="true"/>
      <Output schema="AuthToken" must="true"/>
    </InterfaceConstraint>
  </Constraints>
  <Components>
    <Component id="AuthController">
      <ComponentDetail ref="components/AuthController/component-spec.xml"/>
    </Component>
  </Components>
</ModuleArchitecture>
```

### Component Level (excerpt)
```xml
<ComponentSpec id="AuthController" version="1.0.0">
  <ParentModule ref="../module-architecture.xml"/>
  <Metadata>
    <Language>Python</Language>
    <Framework>FastAPI</Framework>
  </Metadata>
  <Functions>
    <Function id="login">
      <Signature><![CDATA[
async def login(request: LoginRequest) -> AuthToken
      ]]></Signature>
      <ErrorHandling>
        <Error code="401" condition="Invalid credentials"/>
      </ErrorHandling>
    </Function>
  </Functions>
</ComponentSpec>
```
