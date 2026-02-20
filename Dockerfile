FROM python:3.12-slim

# Install Node.js (required for the claude CLI)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copy dependency files first for layer caching
COPY pyproject.toml uv.lock .python-version ./

# Install dependencies
RUN uv sync --frozen --no-install-project

# Copy project source
COPY src/ src/
COPY eval/ eval/
COPY problems/ problems/

# Install the project itself
RUN uv sync --frozen

# Create workspace directory for agent tasks
RUN mkdir -p /workspaces

EXPOSE 9100

ENTRYPOINT ["uv", "run", "start-claude-code-server", "--host", "0.0.0.0", "--port", "9100", "--workspace", "/workspaces"]
