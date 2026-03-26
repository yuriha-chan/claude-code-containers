FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="$PNPM_HOME:$PATH:/home/claude/.local/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git vim gosu ca-certificates build-essential \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p -m 755 /etc/apt/keyrings \
	&& curl "https://cli.github.com/packages/githubcli-archive-keyring.gpg" > /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
	&& apt update \
	&& apt install gh -y \
  && rm -rf /var/lib/apt/lists/*

ENV PNPM_HOME="/home/claude/.local/share/pnpm"

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN useradd -m -s /bin/bash claude

RUN chown claude:claude /app
RUN corepack enable pnpm

USER claude

# Install Claude
RUN pnpm add -g vite @anthropic-ai/claude-code

# User Prompts
RUN mkdir -p .claude
COPY USER.md .claude/USER.md

# Install RTK (rust token killer)
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
RUN rtk init -g --auto-patch

# Install github mcp
RUN pnpm install -g \
    @modelcontextprotocol/server-github \
    && npm cache clean --force

# Install codemap mcp (token-economical search)
RUN uv tool install codemap --from https://github.com/AZidan/codemap.git

# Install Context7 (language reference etc)
RUN claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

WORKDIR /app
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
