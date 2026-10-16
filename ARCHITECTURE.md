# Agentic Workflow System — Architecture & Design

This document describes the technical design, extension points, and implementation details of the universal agentic workflow system.

---

## System Overview

The agentic workflow system is a **configuration-driven, template-based automation platform** designed to standardize development workflows across different languages, project types, and teams.

### Core Principle
> **One workflow, any language.** Define workflows once in YAML, render templates for any language, execute consistently via Task.

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│  Project Layer                                           │
│  (per-project: Taskfile.yml, .plans/, pr_stories/)     │
└──────────────────┬──────────────────────────────────────┘
                   │ (inherits from)
┌──────────────────▼──────────────────────────────────────┐
│  Project Config Layer                                    │
│  (~/.agentic/projects/<name>.yaml)                      │
│  - Metadata, language, workflow phases, CI settings     │
└──────────────────┬──────────────────────────────────────┘
                   │ (extends)
┌──────────────────▼──────────────────────────────────────┐
│  Global Defaults Layer                                   │
│  (~/.agentic/config/defaults.yaml)                      │
│  - Workflow structure, git conventions, language defaults
└──────────────────┬──────────────────────────────────────┘
                   │ (instantiates)
┌──────────────────▼──────────────────────────────────────┐
│  Template Layer                                          │
│  (~/.agentic/templates/)                                │
│  - Mustache templates for Taskfile, docs, CI/CD        │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
init-project.sh
    ↓
1. Load ~/.agentic/config/defaults.yaml
2. Create ~/.agentic/projects/<name>.yaml (project config)
3. Render templates/ with project variables
4. Generate project files (Taskfile.yml, .plans/, etc.)
    ↓
Project Setup Complete
    ↓
task workflow   (users follow the 5-phase process)
    ↓
All phases use global conventions, but language-specific tasks
```

---

## Configuration Schema

### Global Defaults (`~/.agentic/config/defaults.yaml`)

```yaml
version: "1.0"

workflow:
  phases: 5
  enabled_phases: [planning, branch, implementation, commit, pr]

git:
  branch_naming: "type/kebab-case"
  commit_format: "conventional"
  commit_types: [feat, fix, test, docs, refactor, perf, ci, chore, build, style]

language_defaults:
  go:
    min_version: "1.21"
    test_cmd: "go test -v ./..."
    # ... (more language configs)
```

### Project Config (`~/.agentic/projects/<name>.yaml`)

```yaml
metadata:
  name: my-project
  language: go
  root: /path/to/project
  created: 2026-10-15T...

workflow:
  phases: 5
  enabled_phases: [planning, branch, implementation, commit, pr]

go:
  modules: [./...]  # Language-specific config
```

**Inheritance Rule:** Project config overrides global defaults for specific keys.

---

## Template System

### Mustache Templating

Templates use Mustache syntax `{{variable}}` for:
- **Conditional sections:** `{{#variable}} ... {{/variable}}`
- **Loops:** `{{#array}} ... {{/array}}`
- **Variable substitution:** `{{projectName}}`, `{{language}}`

### Template Locations

```
~/.agentic/templates/
├── project/
│   ├── Taskfile.yml.mustache          # Main automation
│   ├── .plans/WORKFLOW.md.mustache    # Workflow docs
│   ├── .plans/QUICK_START.md.mustache
│   └── .markdownlint.json.mustache
├── pr-stories/
│   ├── COMPACT.md.mustache
│   ├── EXTENDED.md.mustache
│   └── VISUAL.md.mustache
└── ci/
    ├── github-actions-go.yml.mustache
    ├── github-actions-python.yml.mustache
    └── github-actions-node.yml.mustache
```

### Rendering Logic (init-project.sh)

1. **Load project config** from defaults + project-specific overrides
2. **Copy template** (e.g., `Taskfile.yml.mustache`)
3. **Simple substitution** (using `sed`):
   ```bash
   sed -i "s|{{projectName}}|$PROJECT_NAME|g" Taskfile.yml
   ```
4. **Conditional removal** (for unused language sections):
   ```bash
   sed -i '/{{#language_go}}/,/{{\/language_go}}/d' Taskfile.yml
   ```

---

## The 5-Phase Workflow

### Phase Design

Each phase has:
1. **Clear Goal** — What should be accomplished
2. **Task Command** — Primary Taskfile target to run
3. **Quality Checks** — Validation before proceeding
4. **Outputs** — Artifacts produced

### Phase 1: Planning
- **Goal:** Understand requirements, design solution
- **Tasks:** `task log` (update project log)
- **Output:** `.plans/[NNN]-plan.md` documentation

### Phase 2: Branch & Setup
- **Goal:** Create feature branch
- **Task:** `task git:new-branch FEAT_TYPE=feat BRANCH_NAME=feature-name`
- **Output:** New local branch from `origin/main`

### Phase 3: Implementation & Testing
- **Goal:** Code, test, iterate
- **Tasks:**
  - `task check` (tidy + lint + test)
  - Language-specific: `task test`, `task lint`
- **Output:** Green tests, passing linters

### Phase 4: Commit
- **Goal:** Create atomic, conventional commits
- **Task:** `task git:commit TYPE=feat SCOPE=core MSG="msg" FILES="file.go"`
- **Output:** Formatted commits in git history

### Phase 5: PR-Story & PR
- **Goal:** Document and create GitHub PR
- **Tasks:**
  - Choose template: `task pr:template`
  - Write story in `pr_stories/[NNN]-name.md`
  - `task git:pr FILE=pr_stories/...md`
- **Output:** GitHub PR with rich documentation

---

## Language Support

### Extensibility Model

Each language defines:

```yaml
language_defaults:
  <language>:
    min_version: "X.Y"
    package_manager: "<tool>"
    build_cmd: "<cmd>"
    test_cmd: "<cmd>"
    lint_cmd: "<cmd>"
    # Language-specific conventions/metadata
```

### Adding a New Language

**Step 1:** Update `~/.agentic/config/defaults.yaml`:
```yaml
language_defaults:
  rust:
    min_version: "1.70"
    package_manager: "cargo"
    test_cmd: "cargo test"
```

**Step 2:** Update `~/.agentic/scripts/init-project.sh`:
```bash
case "$LANGUAGE" in
  go|python|node|react|rust)  # Add rust
    ;;
esac
```

**Step 3:** Create language-specific Taskfile sections (if needed):
```yaml
{{#language_rust}}
  build:
    desc: Build Rust project
    cmds:
      - cargo build --release
{{/language_rust}}
```

**Step 4:** Optional: Add language-specific templates and CI/CD configurations.

---

## Git Workflow Integration

### Branch Naming Convention

```
<type>/<kebab-case-description>
```

**Types** (from Conventional Commits):
- `feat` — New feature
- `fix` — Bug fix
- `test` — Tests
- `docs` — Documentation
- `refactor` — Code refactoring
- `perf` — Performance improvement
- `ci` — CI/CD changes
- `chore` — Other (dependencies, etc.)

### Commit Format

```
type(scope): message
```

**Example:**
```
feat(dsp): implement yin pitch detection algorithm
fix(audio): handle nan frequency correctly
test(dsp): add synthetic sine wave tests
```

### PR Flow

```
1. task git:new-branch FEAT_TYPE=feat BRANCH_NAME=yin-detector
2. [code, test, commit]
3. task git:commit TYPE=feat SCOPE=dsp MSG="..." FILES="..."
4. cp .plans/templates/PR_STORY_EXTENDED.template.md pr_stories/001-feat-yin-detector.md
5. [edit PR story]
6. task git:pr FILE=pr_stories/001-feat-yin-detector.md
7. [GitHub PR created automatically]
```

---

## Project Log System

### Purpose
Track project state, decisions, and progress across sessions.

### Structure
```
~/.plans/PROJECTLOG.md

## 2026-10-15 — Session 3: YIN Algorithm Implementation
**Goal:** Implement YIN pitch detection, create GitHub PR

**Completed:**
- ✅ YIN algorithm implemented (450 LOC)
- ✅ 100+ unit tests, all passing
- ✅ GitHub PR #1 created

**Decisions:**
- Use YIN over FFT for guitar tuning (accuracy on low frequencies)
- Tolerance: ±3 cents

**Next:** Audio capture (Vaihe 3)
```

### Update Frequency
- After every session: `task log`
- Automated reminder hook (optional)

---

## Customization Points

### 1. Workflow Phases
Override in project config:
```yaml
workflow:
  phases: 7
  enabled_phases: [planning, research, design, branch, implementation, testing, pr]
```

### 2. Language Defaults
Override in project config:
```yaml
go:
  min_version: "1.22"  # Override global 1.21
  modules: [./cmd/... ./internal/...]  # Custom modules
```

### 3. Git Conventions
Override in project config or globally:
```yaml
git:
  default_branch: "develop"  # Instead of "main"
  commit_types: [feat, fix, ...]  # Custom types
```

### 4. PR Templates
Choose default template per project:
```yaml
pr_templates:
  default: visual  # Instead of extended
```

### 5. CI/CD Settings
Enable/disable platforms:
```yaml
ci:
  platform: gitlab  # Instead of github
  coverage_threshold: 95  # Instead of 90
```

---

## Storage & Sync Strategy

### Local Master (`~/.agentic/`)

- **Purpose:** Fast, offline development access
- **Content:** All configs, templates, scripts, project configs
- **Versioning:** Git history (local only initially)

### GitHub Backup (Optional)

- **Repository:** `github.com/mvirtai/agentic-workflow` or fork
- **Purpose:** Team sharing, versioning, backup
- **Sync:** Manual `git push/pull` or automation hook

### Sync Workflow

```bash
# Local → GitHub
cd ~/.agentic
git add .
git commit -m "Update: add new language support"
git push origin main

# GitHub → Local (multiple machines)
cd ~/.agentic
git pull origin main
```

---

## Hooks & Automation (Future)

Planned automation triggers:

### Pre-Commit Hooks
```yaml
hooks:
  pre_commit:
    - "task lint"
    - "task test"
    - "task check"
```

### Post-Branch Hooks
```yaml
hooks:
  post_branch_create:
    - "git pull origin main"
    - "task check"  # Validate environment
```

### Pre-PR Hooks
```yaml
hooks:
  pre_pr:
    - "task check"
    - "coverage > 90%"
```

---

## Performance Considerations

### Template Rendering
- **Current:** Simple `sed` substitution (~50ms per file)
- **Scalable:** Can handle 100+ files without issue
- **Future:** Consider `mo` or `handlebars.js` for complex logic

### Task Execution
- **Sequential phases:** Each phase runs to completion
- **Parallel tasks:** Taskfile supports `task: [task1, task2]` parallelization
- **Caching:** Taskfile caches file hashes for incremental builds

### Configuration Loading
- **Lazy loading:** Only read project config when needed
- **Merging:** Local project config overrides global defaults
- **No DB:** All configs are YAML files (human-readable, git-friendly)

---

## Error Handling

### Validation
- **Project config:** `validate-config.sh` (coming soon) checks against schema
- **Templates:** Render script catches missing variables
- **Taskfile:** Task validation on startup (`task --list`)

### Recovery
- **Rollback:** Use `git` to revert failed changes
- **Re-init:** Re-run `init-project.sh` to regenerate config
- **Manual edits:** All configs are human-editable (YAML)

---

## Testing the System

### Unit Tests (Config Validation)
```bash
~/.agentic/scripts/validate-config.sh ~/.agentic/projects/guitar-tuner.yaml
```

### Integration Tests (End-to-End)
```bash
# Test with test project
~/.agentic/scripts/init-project.sh test-project go /tmp/test-project
cd /tmp/test-project
task workflow
task check
```

### Template Rendering Tests
```bash
# Verify Taskfile renders correctly
~/.agentic/scripts/render-templates.sh guitar-tuner go
cat Taskfile.yml | grep -c "task check"  # Should be present
```

---

## Future Enhancements

1. **Advanced Template Rendering**
   - Use `mo` (Mustache) or `handlebars` for complex logic
   - Support loops, nested conditionals

2. **Dynamic Configuration**
   - Interactive setup wizard (`init-project.sh --interactive`)
   - Configuration validation UI

3. **Automation Hooks**
   - Pre/post-commit, pre/post-PR automation
   - Kiro integration for IDE-based workflows

4. **Multi-Project Management**
   - Monorepo support
   - Project dependency graph

5. **Telemetry & Insights**
   - Workflow metrics (phase duration, commit frequency)
   - Team analytics dashboard

6. **Cloud Sync**
   - Automatic GitHub backup
   - Multi-machine synchronization

---

## References

- **Conventional Commits:** https://www.conventionalcommits.org/
- **Taskfile (Task Runner):** https://taskfile.dev/
- **Mustache Templating:** https://mustache.github.io/
- **YAML Spec:** https://yaml.org/spec/1.2/spec.html
- **Git Workflow:** https://git-scm.com/book/en/v2

---

## License

PolyForm Noncommercial License 1.0.0

See [LICENSE](LICENSE) for details.

