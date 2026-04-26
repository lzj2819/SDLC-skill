# AI Agent Architecture Anti-Patterns

Common design mistakes in AI Agent systems and how to avoid them.

---

## Anti-Pattern 1: The God Agent

**Symptom**: A single monolithic agent that handles all tasks — reasoning, planning, tool use, memory, and output formatting.

**Why it's bad**:
- Context window bloats with unrelated responsibilities
- Cannot optimize prompts for specific sub-tasks
- Single point of failure; one bug breaks everything
- Impossible to test individual capabilities

**Fix**: Decompose into specialized agents (Planner, Executor, Critic) or at minimum into specialized components within a single agent.

---

## Anti-Pattern 2: Tool Amnesia

**Symptom**: Agent executes a tool but doesn't retain the result in context for subsequent reasoning steps.

**Why it's bad**: Agent enters infinite loops calling the same tool, or makes decisions based on stale information.

**Fix**: Mandate that every `Observation` from tool execution is appended to the conversation context before the next `Thought`. Enforce this in the orchestrator loop, not as a prompt instruction.

---

## Anti-Pattern 3: Prompt Injection Vulnerability

**Symptom**: User input is passed directly into system prompts without sanitization. Attacker can override system instructions.

**Why it's bad**: Complete compromise of agent behavior. Agent can be tricked into executing unauthorized tools or revealing sensitive data.

**Fix**:
- Separate system prompts from user input with clear delimiters
- Implement a `SecurityJudge` component that classifies input before processing
- Never execute tool calls based solely on LLM output without validation

---

## Anti-Pattern 4: Synchronous Tool Blocking

**Symptom**: Agent waits for each tool call to complete before making the next decision, even when tools are independent.

**Why it's bad**: Serial execution wastes time. A research agent could be fetching 3 URLs in parallel but does so sequentially.

**Fix**: Design the orchestrator to identify independent tool calls and execute them concurrently. Return aggregated results to the agent.

---

## Anti-Pattern 5: Stateless Everything

**Symptom**: Every agent invocation starts from scratch; no conversation history, no user preferences, no learned context.

**Why it's bad**: User experience degrades significantly. Agent feels dumb and repetitive.

**Fix**: Implement tiered memory:
- **Working memory**: Current conversation (in context window)
- **Short-term memory**: Recent conversations (Redis, 24h TTL)
- **Long-term memory**: User preferences, learned facts (vector DB)

---

## Anti-Pattern 6: Hallucinated Tool Calls

**Symptom**: LLM outputs tool calls with invalid parameters or non-existent tool names, and the system crashes or behaves unpredictably.

**Why it's bad**: Fragile system that breaks on unexpected LLM outputs.

**Fix**:
- Strict schema validation on all tool call outputs (use Pydantic or JSON Schema)
- Tool registry with capability declarations; reject calls to unregistered tools
- Graceful degradation: if tool call is invalid, return error to agent as Observation

---

## Anti-Pattern 7: No Retry / No Fallback

**Symptom**: If LLM API fails or returns garbage, the agent crashes or returns an error to the user.

**Why it's bad**: Production systems must be resilient. LLM APIs are probabilistic and occasionally fail.

**Fix**:
- Implement retry with exponential backoff for LLM calls
- Maintain a fallback model (cheaper/faster) for non-critical tasks
- If all retries fail, return a graceful "I'm having trouble" message instead of crashing

---

## Anti-Pattern 8: Hidden Cost Explosion

**Symptom**: No tracking of token usage or tool execution costs. Agent enters infinite loops or makes expensive calls without budget checks.

**Why it's bad**: Unexpected bills, denial-of-wallet attacks, unsustainable product economics.

**Fix**:
- Track tokens per request and per session
- Set per-user and per-session budgets
- Implement circuit breakers for expensive operations
- Log cost metrics for analysis

---

## Anti-Pattern 9: Tight LLM Provider Coupling

**Symptom**: Direct calls to OpenAI API scattered throughout the codebase. Swapping to Claude or a local model requires changes in dozens of files.

**Why it's bad**: Vendor lock-in, inability to A/B test models, difficulty using local models for compliance.

**Fix**: Abstract all LLM calls behind a `LLMGateway` interface. Adapters per provider. Core logic depends only on the gateway interface.

---

## Anti-Pattern 10: Ignoring Human-in-the-Loop

**Symptom**: Agent acts autonomously for all tasks, including high-stakes or irreversible actions (sending emails, deleting data, making purchases).

**Why it's bad**: Trust and safety. Users need control over consequential actions.

**Fix**:
- Classify actions by risk level (read-only, write, destructive, financial)
- Require explicit user confirmation for high-risk actions
- Provide "undo" capability where possible
- Log all autonomous actions for audit
