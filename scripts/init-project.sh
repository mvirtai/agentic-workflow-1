#!/bin/bash
set -e

# Universal Agentic Workflow System — Project Initialization Script
# Usage: init-project.sh <project-name> <language> [project-root]

if [ $# -lt 2 ]; then
  echo "Usage: $0 <project-name> <language> [project-root]"
  echo ""
  echo "Arguments:"
  echo "  project-name  Kebab-case project name (e.g., guitar-tuner)"
  echo "  language      go, python, node, or react"
  echo "  project-root  Optional project root (default: current directory)"
  echo ""
  echo "Example:"
  echo "  $0 guitar-tuner go /home/vivaldev/code/guitar_tuner"
  echo "  $0 my-app react /home/user/projects/my-app"
  exit 1
fi

PROJECT_NAME="$1"
LANGUAGE="$2"
PROJECT_ROOT="${3:-.}"
AGENTIC_HOME="${AGENTIC_HOME:-$HOME/.agentic}"

# Validate inputs
case "$LANGUAGE" in
  go|python|node|react)
    ;;
  *)
    echo "❌ Unsupported language: $LANGUAGE (supported: go, python, node, react)"
    exit 1
    ;;
esac

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "❌ Project root does not exist: $PROJECT_ROOT"
  exit 1
fi

if [ ! -f "$AGENTIC_HOME/config/defaults.yaml" ]; then
  echo "❌ Agentic system not found at $AGENTIC_HOME"
  echo "Please install ~/.agentic/ first"
  exit 1
fi

echo "🚀 Initializing agentic workflow for: $PROJECT_NAME ($LANGUAGE)"
echo ""

# Create project config
PROJECT_CONFIG="$AGENTIC_HOME/projects/${PROJECT_NAME}.yaml"
echo "📝 Creating project config: $PROJECT_CONFIG"

cat > "$PROJECT_CONFIG" << YAML_EOF
# Project Configuration — $PROJECT_NAME
version: "1.0"
metadata:
  name: $PROJECT_NAME
  language: $LANGUAGE
  root: $(cd "$PROJECT_ROOT" && pwd)
  created: $(date -u +%Y-%m-%dT%H:%M:%SZ)

workflow:
  phases: 5
  enabled_phases:
    - planning
    - branch
    - implementation
    - commit
    - pr

ci:
  platform: github
  coverage_threshold: 90
  codecov_enabled: true

git:
  default_branch: main

versioning:
  strategy: semver

pr_templates:
  compact: true
  extended: true
  visual: true
  default: extended

$LANGUAGE:
  # Language-specific config
  inherited_from_defaults: true

YAML_EOF

echo "✅ Project config created"

# Install Taskfile if not present
if [ ! -f "$PROJECT_ROOT/Taskfile.yml" ]; then
  echo "📝 Initializing Taskfile..."
  
  # Copy template
  cp "$AGENTIC_HOME/templates/project/Taskfile.yml.mustache" "$PROJECT_ROOT/Taskfile.yml"
  
  # Replace Mustache variables
  sed -i "s|{{projectName}}|$PROJECT_NAME|g" "$PROJECT_ROOT/Taskfile.yml"
  
  # Set language flags
  sed -i "s|{{#language_$LANGUAGE}}||g" "$PROJECT_ROOT/Taskfile.yml"
  sed -i "s|{{/language_$LANGUAGE}}||g" "$PROJECT_ROOT/Taskfile.yml"
  
  # Remove unused language blocks
  if [ "$LANGUAGE" != "go" ]; then
    sed -i '/{{#language_go}}/,/{{\/language_go}}/d' "$PROJECT_ROOT/Taskfile.yml"
  fi
  if [ "$LANGUAGE" != "python" ]; then
    sed -i '/{{#language_python}}/,/{{\/language_python}}/d' "$PROJECT_ROOT/Taskfile.yml"
  fi
  if [ "$LANGUAGE" != "node" ] && [ "$LANGUAGE" != "react" ]; then
    sed -i '/{{#language_node}}/,/{{\/language_node}}/d' "$PROJECT_ROOT/Taskfile.yml"
  fi
  
  # Clean up remaining Mustache syntax
  sed -i 's|{{[^}]*}}||g' "$PROJECT_ROOT/Taskfile.yml"
  
  echo "✅ Taskfile.yml created"
else
  echo "⏭️  Taskfile.yml already exists, skipping"
fi

# Create project directories
for dir in .plans pr_stories .github/workflows .kiro/steering .kiro/hooks; do
  mkdir -p "$PROJECT_ROOT/$dir"
done

echo "✅ Project directories created"

# Initialize VERSION file if not present
if [ ! -f "$PROJECT_ROOT/VERSION" ]; then
  echo "0.1.0" > "$PROJECT_ROOT/VERSION"
  echo "✅ VERSION file initialized (0.1.0)"
fi

# Create GitHub Actions CI/CD workflow
echo "📝 Setting up GitHub Actions CI/CD..."

case "$LANGUAGE" in
  go)
    cp "$AGENTIC_HOME/templates/ci/github-actions-go.yml.mustache" "$PROJECT_ROOT/.github/workflows/ci.yml"
    ;;
  python)
    cp "$AGENTIC_HOME/templates/ci/github-actions-python.yml.mustache" "$PROJECT_ROOT/.github/workflows/ci.yml"
    ;;
  node|react)
    cp "$AGENTIC_HOME/templates/ci/github-actions-node.yml.mustache" "$PROJECT_ROOT/.github/workflows/ci.yml"
    ;;
esac

# Replace project name in workflow
sed -i "s|{{projectName}}|$PROJECT_NAME|g" "$PROJECT_ROOT/.github/workflows/ci.yml"

# Create markdown linting config
cp "$AGENTIC_HOME/templates/project/.markdownlint.json.mustache" "$PROJECT_ROOT/.markdownlint.json"

echo "✅ GitHub Actions workflow created at .github/workflows/ci.yml"
echo "✅ Markdown linting config created at .markdownlint.json"

# Add language-specific notes
echo ""
echo "📋 Language-specific notes for $LANGUAGE:"
case "$LANGUAGE" in
  go)
    echo "  • Ensure go.mod is present in $PROJECT_ROOT"
    echo "  • Task reference: task workflow (view all Go tasks)"
    echo "  • CI/CD: .github/workflows/ci.yml (Go tests, linting, coverage)"
    ;;
  python)
    echo "  • Using uv as package manager"
    echo "  • Create pyproject.toml in $PROJECT_ROOT"
    echo "  • Task reference: task workflow (view all Python tasks)"
    echo "  • CI/CD: .github/workflows/ci.yml (uv tests, Ruff linting, coverage)"
    ;;
  node)
    echo "  • Using pnpm as package manager"
    echo "  • Ensure package.json exists in $PROJECT_ROOT"
    echo "  • Task reference: task workflow (view all Node tasks)"
    echo "  • CI/CD: .github/workflows/ci.yml (pnpm tests, linting, build)"
    ;;
  react)
    echo "  • Using React 19.3+ with React Compiler"
    echo "  • Ensure package.json and TypeScript setup in $PROJECT_ROOT"
    echo "  • React Compiler conventions enforced via ESLint"
    echo "  • Server Components preferred, 'use server'/'use client' directives"
    echo "  • Avoid useEffect, useRef, useLayoutEffect — prefer derived state"
    echo "  • Use useAction() for form submissions"
    echo "  • Task reference: task workflow (view all Node/React tasks)"
    echo "  • CI/CD: .github/workflows/ci.yml (Node tests, TypeScript check, build)"
    ;;
esac

echo ""
echo "✅ Project initialization complete!"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_ROOT"
echo "  2. task workflow          # View workflow reference"
echo "  3. task log               # Start project log"
echo "  4. git init && git remote add origin https://github.com/you/repo.git"
echo "  5. git add . && git commit -m 'Initial commit: agentic workflow'"
echo "  6. git push -u origin main"
echo ""
echo "Configuration saved to: $PROJECT_CONFIG"
