FROM node:20-bookworm-slim

ENV PNPM_HOME="/home/claude/.local/share/pnpm"
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="$PNPM_HOME:$PATH:/home/claude/.local/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git vim gosu ca-certificates build-essential procps\
    watchdog python3 python3-pip python3-venv python3-watchdog jq\
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p -m 755 /etc/apt/keyrings \
	&& curl "https://cli.github.com/packages/githubcli-archive-keyring.gpg" > /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
	&& apt update \
	&& apt install gh -y \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable pnpm

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Setup User directory
RUN useradd -m -s /bin/bash claude
USER claude

# Install Claude
RUN pnpm add -g vite @anthropic-ai/claude-code

# Install RTK (rust token killer)
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
RUN rtk init -g --auto-patch

# Install github mcp
RUN pnpm install -g \
    @modelcontextprotocol/server-github \
    && npm cache clean --force

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install codemap mcp (token-economical search)
RUN uv tool install codemap --from https://github.com/AZidan/codemap.git

# Install Context7 (language reference etc)
RUN claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

COPY init/USER.md /home/claude/.claude/USER.md
RUN echo "@USER.md" >> /home/claude/.claude/CLAUDE.md
COPY init/CODEMAP.md /home/claude/.claude/CODEMAP.md
RUN echo "@CODEMAP.md" >> /home/claude/.claude/CLAUDE.md
COPY init/settings.json /home/claude/.claude/settings.json

COPY init/skills /home/claude/.claude/skills
COPY init/hooks /home/claude/.claude/hooks
COPY init/agents /home/claude/.claude/agents
COPY codemap-show /home/claude/.local/bin/codemap-show

USER root
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
