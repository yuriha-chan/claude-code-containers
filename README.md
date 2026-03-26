# Claude Code Docker Workspace

A lightweight utility to create isolated Docker-based workspaces for [Claude Code](https://github.com/anthropics/claude-code) with pre‑configured tools.

## Features

- **Isolated workspaces** – Each workspace has its own Docker volumes and configuration.
- **Pre‑installed tools** – Includes `rtk`, `codemap`, `context7-mcp`, GitHub CLI, and more.
- **Secure permissions** – The container runs as a non‑root user (`claude`) with proper ownership handling.
- **Simple CLI** – One command creates a new workspace with environment variables.

## Prerequisites

- Docker installed.
- Environment variables (see below) set in your shell.

## Setup

Clone this repository:

```bash
git clone <repo-url> claude-workspace
cd claude-workspace
```

## Environment Variables

Set the following variables in your shell (they will be embedded into each workspace's `.env` file):

| Variable          | Required | Description                                 |
|-------------------|----------|---------------------------------------------|
| `ANTHROPIC_API_KEY` | Yes    | Your Anthropic API key for Claude Code.     |
| `GITHUB_TOKEN`      | No     | Personal access token for GitHub MCP.       |
| `CONTEXT7_API_KEY`  | No     | API key for context7 (language reference).  |

Example:

```bash
export ANTHROPIC_API_KEY=sk-...
export GITHUB_TOKEN=ghp_...
```

## Usage

### Create a new workspace

```bash
./create <workspace-name>
```

This creates a directory `workspaces/<workspace-name>/` containing:

- `docker-compose.yml` – derived from the template
- `.env` – with the variables you exported

### Start the workspace

```bash
cd workspaces/<workspace-name>
docker compose up -d
```

### Enter the container

```bash
docker exec -it claude-code-<workspace-name> bash
```

Once inside, you can run `claude` or use any of the pre-installed tools.

### Stop the workspace

```bash
docker compose down
```

To remove volumes (clearing all data), add `-v`.

## Customisation

- **User prompts** – Place a `USER.md` file in the repository root before building the image; it will be copied to `~/.claude/USER.md` and referenced in `CLAUDE.md`.  
- **Dockerfile** – Modify `Dockerfile` to add or remove tools as needed.
- **docker-compose.tmpl.yml** – Adjust resource limits, ports, or mount points.

## Directory Structure

```
.
├── create                     # Workspace creation script
├── docker-compose.tmpl.yml    # Template for docker compose
├── Dockerfile                 # Container image definition
├── docker-entrypoint.sh       # Fixes permissions and drops privileges
└── workspaces/                # Generated workspaces (not tracked by git)
```

## Notes

- The image is built locally – make sure you run `docker compose up` from inside the workspace directory, which references the parent context.
- Each workspace uses three Docker volumes: one for `/app` (workspace data), one for `.claude` (configuration), and one for `rtk` data.
- The container is started with `restart: unless-stopped`, so it will survive host reboots.

## License

MIT
