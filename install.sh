#!/bin/bash

# Claude Skills Pack Installer
# Installs skills, marketplaces, and plugins for Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo "=========================================="
echo "  Claude Skills Pack Installer"
echo "=========================================="
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code CLI not found."
    echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

echo "Step 1: Installing Skills..."
echo "-------------------------------------------"

# Copy all skills
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    echo "  Installing skill: $skill_name"
    cp -r "$skill_dir" "$SKILLS_DIR/"
done

echo ""
echo "Step 2: Adding Plugin Marketplaces..."
echo "-------------------------------------------"

# Add marketplaces (these are the sources for plugins)
MARKETPLACES=(
    "every-marketplace|https://github.com/EveryInc/compound-engineering-plugin.git"
    "claude-code-workflows|https://github.com/wshobson/agents.git"
    "dotclaude-plugins|https://github.com/dotclaude/marketplace.git"
    "anthropic-agent-skills|https://github.com/anthropics/skills.git"
)

for marketplace in "${MARKETPLACES[@]}"; do
    IFS='|' read -r name url <<< "$marketplace"
    echo "  Adding marketplace: $name"
    claude plugins add-marketplace "$url" 2>/dev/null || echo "    (already exists or failed)"
done

echo ""
echo "Step 3: Installing Plugins..."
echo "-------------------------------------------"

# Install plugins from various marketplaces
PLUGINS=(
    "compound-engineering@every-marketplace"
    "frontend-design@claude-code-plugins"
    "feature-dev@claude-code-plugins"
    "pr-review-toolkit@claude-code-plugins"
    "security-guidance@claude-code-plugins"
    "code-review@claude-code-plugins"
    "python-development@claude-code-workflows"
    "javascript-typescript@claude-code-workflows"
    "code-refactoring@claude-code-workflows"
    "database-design@claude-code-workflows"
    "code-documentation@claude-code-workflows"
    "backend-development@claude-code-workflows"
    "frontend-excellence@dotclaude-plugins"
    "document-skills@anthropic-agent-skills"
)

for plugin in "${PLUGINS[@]}"; do
    echo "  Installing plugin: $plugin"
    claude plugins install "$plugin" 2>/dev/null || echo "    (already installed or failed)"
done

echo ""
echo "Step 4: MCP Servers (Optional)..."
echo "-------------------------------------------"
echo ""
read -p "Install MCP servers (Render, Modal)? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  Adding MCP server: render"
    claude mcp add render --type http --url https://mcp.render.com/mcp 2>/dev/null || echo "    (already exists or failed)"

    echo "  Adding MCP server: modal-toolbox"
    claude mcp add modal-toolbox --type stdio -- uvx modal-mcp-toolbox 2>/dev/null || echo "    (already exists or failed)"

    echo ""
    echo "  MCP servers installed!"
    echo "  Note: You may need to authenticate with Render and Modal separately."
else
    echo "  Skipping MCP servers."
    echo "  You can install them later with:"
    echo "    claude mcp add render --type http --url https://mcp.render.com/mcp"
    echo "    claude mcp add modal-toolbox --type stdio -- uvx modal-mcp-toolbox"
fi

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Installed:"
echo "  - 25 skills (available via /skill-name)"
echo "  - 4 marketplaces"
echo "  - 14 plugins"
echo "  - 2 MCP servers (if selected)"
echo ""
echo "To verify, run:"
echo "  claude plugins list"
echo "  claude mcp list"
echo ""
echo "Skills are automatically available in Claude Code."
echo "Use them by referencing them in your prompts or"
echo "Claude will automatically apply relevant skills."
echo ""
