---
name: ai-agent-design
description: Domain extension for AI Agent system architecture. Use when the project involves LLM-based agents, tool use, memory systems, or multi-agent orchestration. This is NOT a standalone skill — it is dynamically loaded by sdlc-architecture-design when the PRD contains ai-agent characteristic tags.
---

# AI Agent Design Extension

## Overview

This extension augments the generic `sdlc-architecture-design` skill with AI Agent-specific evaluation dimensions, anti-patterns, and architecture guidance. It is loaded automatically when the PRD contains tags like `ai_agent`, `llm_orchestration`, `tool_use`, or `multi_agent`.

## Extension Mechanism

When `sdlc-architecture-design` detects an AI Agent domain tag:
1. It reads this SKILL.md to understand the overlay rules
2. It reads `references/dimensions.md` for additional evaluation dimensions
3. It reads `references/anti-patterns.md` for domain-specific risks
4. These dimensions are ADDED to the generic pattern evaluation, not replacing it

## When to Load

- PRD mentions: LLM, agent, ReAct, tool use, function calling, RAG, memory, planning, multi-agent
- Project characteristic tags include: `ai_agent`, `llm_orchestration`, `tool_use`

## Overlay Rules

### 1. Additional Architecture Evaluation Dimensions

For each evaluated pattern, add these AI Agent-specific dimensions:

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Tool Latency | 1.2x | How does the pattern affect tool selection and execution latency? |
| Context Window Efficiency | 1.0x | Can the pattern optimize LLM context window usage? |
| Memory Integration | 1.1x | How naturally does the pattern integrate vector/RAG memory? |
| Agent Orchestration | 1.0x | Does the pattern support multi-agent delegation and coordination? |
| Observability | 1.0x | Can agent reasoning chains be traced and debugged? |

### 2. Pattern-Specific Guidance

**Event-Driven Architecture**
- Strength for AI Agents: Natural fit for asynchronous tool execution, streaming LLM responses
- Risk: Eventual consistency can cause agent state drift if not carefully managed
- Guidance: Use event sourcing for agent action history; ensure idempotent tool execution

**Microservice Architecture**
- Strength for AI Agents: Separate services for LLM inference, tool execution, memory retrieval
- Risk: Network latency between agent orchestrator and LLM service
- Guidance: Co-locate orchestrator and LLM service if latency is critical; use caching for frequent prompts

**Hexagonal Architecture**
- Strength for AI Agents: Isolate LLM provider adapters; swap OpenAI for Claude without touching core logic
- Risk: Over-abstraction of simple LLM calls
- Guidance: Ports for LLMClient, ToolRegistry, MemoryStore; adapters per provider

**Plugin-Based Architecture**
- Strength for AI Agents: Tool registry as plugin system; third-party tools load dynamically
- Risk: Tool sandboxing and permission model complexity
- Guidance: Implement strict tool capability declarations and runtime permission checks

### 3. Mandatory XML Additions

When generating `architecture.xml` for an AI Agent system, ensure these modules are considered:

- `Orchestrator`: ReAct loop, plan generation, agent delegation
- `LLMGateway`: Provider abstraction, prompt management, token tracking
- `ToolRegistry`: Tool discovery, parameter validation, execution routing
- `MemoryStore`: Vector search, conversation history, long-term memory
- `SecurityJudge`: Input classification, prompt injection detection, rate limiting

Add AI-specific `StateModel` entries:
- `conversation_history`: location, owner (Orchestrator), lifecycle
- `agent_context_window`: location (in-memory / Redis), owner (Orchestrator), lifecycle (per-session)
- `tool_execution_cache`: location (Redis), owner (ToolRegistry), lifecycle (TTL-based)

### 4. Interface Contract Additions

Every AI Agent system should define these cross-module interfaces:

| Interface | Input | Output | Error Codes |
|-----------|-------|--------|-------------|
| `execute_tool` | `ToolRequest` | `ToolResult` | 400 (invalid params), 403 (unauthorized tool), 504 (tool timeout) |
| `query_memory` | `MemoryQuery` | `MemoryResults` | 404 (no relevant memory), 429 (rate limit) |
| `generate_plan` | `GoalDescription` | `ExecutionPlan` | 422 (unachievable goal), 500 (LLM failure) |
| `security_check` | `UserInput` | `SafetyRating` | 400 (malformed input), 403 (blocked content) |

## References

- `references/dimensions.md` — Full evaluation dimension definitions and scoring guides
- `references/anti-patterns.md` — AI Agent architecture anti-patterns and mitigations
