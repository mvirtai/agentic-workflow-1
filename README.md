# Universal Agentic Workflow System

A configuration-driven, standardized 5-phase development workflow that works across all project types (Go, Python, Node.js, React). Built for speed, consistency, and automation.

## Features

✅ **5-Phase Workflow**  
Planning → Branch → Implementation → Commit → PR-Story  

✅ **Multi-Language Support**  
Go, Python, Node.js, React (with React 19.3+ Compiler conventions)  

✅ **Automated Setup**  
Initialize any project with one command  

✅ **Taskfile Integration**  
Pre-configured task automation for all phases  

✅ **PR Story Templates**  
COMPACT, EXTENDED, VISUAL templates for every PR type  

✅ **Conventional Commits**  
Standardized commit format across all projects  

✅ **Local + GitHub Sync**  
Master copy at `~/.agentic/` with optional GitHub backup  

---

## Quick Start

### 1. Install the System

```bash
# Already installed at ~/.agentic/
# Verify installation:
ls -la ~/.agentic/
```

### 2. Initialize a Project

```bash
# Go project
~/.agentic/scripts/init-project.sh my-project go /path/to/my-project

# Python project (uses uv)
~/.agentic/scripts/init-project.sh my-project python /path/to/my-project

# Node.js project (uses pnpm)
~/.agentic/scripts/init-project.sh my-project node /path/to/my-project

# React project (with React 19.3+ Compiler conventions)
~/.agentic/scripts/init-project.sh my-app react /path/to/my-app
```

### 3. Start the Workflow

```bash
cd /path/to/my-project
task workflow        # View quick reference
task log             # Open project log
cat .plans/WORKFLOW.md  # Read full documentation
```

---

## System Architecture

```
~/.agentic/
├── README.md                      # This file
├── ARCHITECTURE.md                # Design details
├── LICENSE                        # PolyForm Noncommercial 1.0.0
├── .agentic.schema.yaml          # Configuration schema
├── config/
│   ├── defaults.yaml             # Global defaults (all projects)
│   └── templates/                # Workflow templates
├── templates/
│   ├── project/                  # Project-level templates
│   │   ├── Taskfile.yml.mustache
│   │   ├── .plans/WORKFLOW.md.mustache
│   │   ├── .plans/QUICK_START.md.mustache
│   │   └── [more]
│   ├── pr-stories/               # PR story templates (COMPACT, EXTENDED, VISUAL)
│   └── ci/                       # CI/CD templates (GitHub Actions, etc.)
├── scripts/
│   ├── init-project.sh           # Initialize new project
│   ├── render-templates.sh       # Render Mustache templates
│   └── validate-config.sh        # Validate project configs
└── projects/                      # Per-project configurations
    └── [project-name].yaml       # Generated on init
```

---

## The 5-Phase Workflow

### Phase 1: Planning
**What:** Understand requirements, design, document approach  
**Tools:** `.plans/` documentation, project log  
**Task:** `task log` — Update project log with plan

### Phase 2: Branch & Setup
**What:** Create feature branch, prepare environment  
**Task:** `task git:new-branch FEAT_TYPE=feat BRANCH_NAME=my-feature`

### Phase 3: Implementation & Testing
**What:** Code, test, ensure quality  
**Tasks:**
- `task check` — Run all quality checks
- `task test` — Run tests
- `task lint` — Run linters

### Phase 4: Commit
**What:** Create atomic, well-formatted commits  
**Task:** `task git:commit TYPE=feat SCOPE=core MSG="description" FILES="file.go"`

### Phase 5: PR-Story & PR
**What:** Write PR story, create GitHub PR  
**Tasks:**
- Choose template: `task pr:template`
- Create PR story in `pr_stories/`
- `task git:pr FILE=pr_stories/NNN-type-name.md`

---

## Conventions

### Git Branch Naming
```
<type>/<kebab-case-description>
```

**Types:** `feat`, `fix`, `test`, `docs`, `refactor`, `perf`, `ci`, `chore`

**Examples:**
- `feat/yin-pitch-detector`
- `fix/nan-comparison-bug`
- `docs/dsp-algorithm-explanation`

### Conventional Commits
```
type(scope): message
```

**Examples:**
```
feat(dsp): implement yin pitch detection algorithm
fix(audio): handle nan frequency correctly
test(dsp): add synthetic sine wave tests
```

### PR Story Templates

| Template | Size | Use Case |
|----------|------|----------|
| **COMPACT** | 500–800 words | Bug fixes, small features |
| **EXTENDED** | 1500–3000 words | Large features, multi-layer changes |
| **VISUAL** | 800–1500 words + diagrams | Data pipelines, UI flows |

---

## Language-Specific Defaults

### Go
- Min version: 1.21
- Test cmd: `go test -v ./...`
- Lint cmd: `go vet ./...`

### Python
- Min version: 3.9
- Package manager: **uv**
- Test cmd: `uv run pytest -v`
- Lint cmd: `uv run ruff check .`

### Node.js
- Min version: 18
- Package manager: **pnpm**
- Build cmd: `pnpm build`
- Test cmd: `pnpm test --run`

### React
- Min version: 19.3 (with React Compiler)
- Package manager: **pnpm**
- **Conventions:**
  - Use `'use server'` for Server Components
  - Use `'use client'` for Client Components
  - Prefer Server Components over Client Components
  - Use `useAction()` for form submissions
  - **Avoid:** `useEffect`, `useRef`, `useLayoutEffect`
  - Prefer derived state and direct state management
  - Use `Suspense` for async operations
  - Keep components pure (no side effects)
  - ESLint enforces React Compiler rules

---

## Configuration

### Global Defaults
See `~/.agentic/config/defaults.yaml` for global settings (workflow phases, git conventions, pr templates, etc.)

### Project Configs
Each project has a config at `~/.agentic/projects/<project-name>.yaml`:

```yaml
metadata:
  name: my-project
  language: go
  root: /path/to/my-project
  created: 2026-10-15T...

workflow:
  phases: 5
  enabled_phases: [planning, branch, implementation, commit, pr]

ci:
  platform: github
  coverage_threshold: 90
```

---

## Scripts

### `init-project.sh`
Initialize a new project with the agentic workflow.

```bash
~/.agentic/scripts/init-project.sh <name> <language> [root]
```

**Example:**
```bash
~/.agentic/scripts/init-project.sh guitar-tuner go /home/user/code/guitar_tuner
```

### `render-templates.sh` (Coming soon)
Render Mustache templates for a project.

### `validate-config.sh` (Coming soon)
Validate project configuration against schema.

---

## Storage Strategy

### Local Master (`~/.agentic/`)
- Fast, offline access
- Daily development use
- All configuration + templates

### GitHub Backup (Optional)
- Repository: `github.com/mvirtai/agentic-workflow` (or your fork)
- Versioning and team sharing
- Sync via `git push/pull`

**To set up GitHub backup:**
```bash
cd ~/.agentic
git init
git remote add origin https://github.com/your-org/agentic-workflow.git
git add .
git commit -m "Initial commit: agentic workflow system"
git push -u origin main
```

---

## Extending the System

### Add a New Language

1. Add language defaults to `~/.agentic/config/defaults.yaml`:
```yaml
language_defaults:
  rust:
    min_version: "1.70"
    package_manager: cargo
    build_cmd: "cargo build --release"
    test_cmd: "cargo test"
    lint_cmd: "cargo clippy"
```

2. Update `init-project.sh` to support the language:
```bash
case "$LANGUAGE" in
  go|python|node|react|rust)
    ;;
esac
```

3. Add language-specific Taskfile sections as needed

### Customize Workflow Phases

Edit `~/.agentic/config/defaults.yaml` and your project's config at `~/.agentic/projects/<name>.yaml`:

```yaml
workflow:
  phases: 7  # Custom number of phases
  enabled_phases:
    - planning
    - research
    - design
    - branch
    - implementation
    - testing
    - pr
```

---

## Project Log Template

See `.plans/templates/SESSION_LOG.template.md` for the structure. Update your project log regularly:

```bash
task log  # Opens editor to update project log
```

---

## Troubleshooting

### "Agentic system not found at $HOME/.agentic"
The system isn't installed. Check `~/.agentic/` exists and contains `config/`, `templates/`, `scripts/`.

### "task: command not found"
Install [Task](https://taskfile.dev/installation/) if not already installed:
```bash
# macOS
brew install go-task/tap/go-task

# Linux
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
```

### Taskfile.yml won't render
The init script uses simple `sed` substitution. For complex templates, ensure Mustache syntax is properly escaped.

---

## Best Practices

1. **Commit often** — Each logical unit = one commit
2. **Test continuously** — `task check` before every commit
3. **Write good PR stories** — Spend time on documentation
4. **Update project log** — After every session
5. **Keep PRs small** — Max 500–1000 lines
6. **Follow conventions** — Consistent naming, commits, branches

---

## References

- **Conventional Commits:** https://www.conventionalcommits.org/
- **Task:** https://taskfile.dev/
- **Go:** https://golang.org/
- **Python uv:** https://docs.astral.sh/uv/
- **pnpm:** https://pnpm.io/
- **React Compiler:** https://react.dev/learn/react-compiler
- **Mustache:** https://mustache.github.io/

---

## License

PolyForm Noncommercial License 1.0.0

See [LICENSE](LICENSE) for details.

---

## Author

Created as a universal agentic workflow system for cross-project consistency.

**Questions?** Check `~/.agentic/ARCHITECTURE.md` for deeper details.

