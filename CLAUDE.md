# Claude Code Marketplace — GitLab Tools

This repository is a Claude Code plugin marketplace that provides GitLab integration via the glab CLI.

## Repository Structure

- `.claude-plugin/marketplace.json` — Marketplace catalog listing all available plugins
- `plugins/gitlab/` — The GitLab plugin with skills, hooks, agents, and scripts
- Plugin skills are in `plugins/gitlab/skills/` with SKILL.md files
- Hook configuration is in `plugins/gitlab/hooks/hooks.json`
- Shell scripts are in `plugins/gitlab/scripts/`

## Development

- Test plugins locally with `claude --plugin-dir ./plugins/gitlab`
- Validate marketplace with `claude plugin validate .`
- All paths in hooks and MCP configs must use `${CLAUDE_PLUGIN_ROOT}` for portability
- Skills use YAML frontmatter with `name` and `description` fields
- Plugin manifest is at `plugins/gitlab/.claude-plugin/plugin.json`
