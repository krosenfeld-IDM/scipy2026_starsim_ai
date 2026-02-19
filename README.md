# SciPy 2026: Starsim AI Evaluation

## Introduction

Submission for [SciPy 2026](https://pretalx.com/scipy-2026/cfp) evaluating Starsim-AI.

Deadline: **February 25, 2026**

Track: **Data-Driven Discovery, Machine Learning and Artificial Intelligence**

> This track aims to bring together the latest advances in Artificial Intelligence and Machine Learning (AI/ML) and areas of data-driven insights that focus on advancing novel discovery across fields and applications in science and industry. This includes the development and application of new and existing open-source tools and techniques that have been influential in advancing scientific progress. **We encourage submissions that include stories of applications and improvements to simulation and simulation-based inference.**

## Proposal

- Build a Claude Code plugin for Starsim that combines MCP servers for Starsim + individual models and general skills (e.g., a disease modeling expert subagent, a code quality subagent)
- Write an exam to test Starsim skills/knowledge
- Evaluate how well the enhanced AI performs compared to out-of-the-box versions on the exam

## Talk plan
- Intro to the problem (getting up to speed on a complex library) and Starsim
- How we developed the Starsim exam, and what worked well and didn't
- Describe which skills/subagents we developed and why
- Models and skillsets we tested
- Evaluation of each combination
- Open-source "gym" for users to plug in their own library, skills, and exam

## Architecture

### Claude Code A2A Server

The project includes an [A2A](https://google.github.io/A2A/) (Agent-to-Agent) server that exposes Claude Code as a discoverable, callable coding agent over HTTP.

**Server** (`src/ssai/claude_code_server.py`): Builds an Agent Card advertising four skills — code generation, code review & bug fixing, shell & DevOps, and research & exploration — and serves it via a Starlette/Uvicorn application. Configuration options:

| Flag | Default | Description |
|------|---------|-------------|
| `--host` | `0.0.0.0` | Bind address |
| `--port` | `9100` | Listen port |
| `--workspace` | parent dir | Root directory for per-task workspaces |
| `--model` | — | Claude model to use |
| `--max-turns` | — | Max agent loop iterations |
| `--mcp` | — | MCP servers to enable (repeatable) |

**Executor** (`src/ssai/claude_code_executor.py`): Bridges the A2A protocol to Claude Code via the Claude Agent SDK. Key behaviors:

- **Workspace isolation** — each A2A task gets its own workspace directory for file operations.
- **Multi-turn sessions** — tracks Claude Agent SDK session IDs per task so follow-up messages resume the same conversation context.
- **Streaming progress** — emits intermediate `TaskStatusUpdateEvent`s as Claude works, including text output and tool-use notifications.
- **Cancellation** — supports async cancellation via `asyncio.Event`.
- **Configurable tools** — defaults to Read, Write, Edit, MultiEdit, Bash, Glob, Grep, and WebSearch; runs with `bypassPermissions` mode.
- **MCP extensibility** — pluggable MCP servers for domain-specific capabilities (an example "secret" server is included in `src/ssai/mcp_secret.py`).

### Running the server

```bash
# Install dependencies
uv sync

# Start the server
start-claude-code-server --port 9100 --workspace ./workspaces
```

The agent card is served at `http://localhost:9100/.well-known/agent.json`.

### Running tests

```bash
uv run pytest tests/
```

Tests cover agent discovery, one-shot requests, and multi-turn conversations.