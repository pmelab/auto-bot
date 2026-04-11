#!/usr/bin/env bash
set -euo pipefail

# Detect available linters, type checkers, formatters, and CI from project root
# Output: JSON boolean checklist on stdout
# Exit 0: always

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

check() { [[ -e $1 ]] && echo true || echo false; }
check_glob() { compgen -G "$1" >/dev/null 2>&1 && echo true || echo false; }

ESLINT=$(check_glob ".eslintrc*" || check_glob "eslint.config.*")
BIOME=$(check "biome.json")
PRETTIER=$(check_glob ".prettierrc*" || check "prettier.config.js")
RUFF=$(check "ruff.toml" || check ".ruff.toml")
CLIPPY=$(if [[ -f Cargo.toml ]] && grep -q '\[lints\]' Cargo.toml 2>/dev/null; then echo true; else echo false; fi)
GOLANGCI=$(check_glob ".golangci*")
TYPESCRIPT=$(check "tsconfig.json")
MYPY=$(check "mypy.ini" || check ".mypy.ini" || check "setup.cfg")
PYRIGHT=$(check "pyrightconfig.json")
CI_GITHUB=$(check ".github/workflows")

# Package manager detection
PKG_MANAGER="none"
if [[ -f "package-lock.json" ]]; then PKG_MANAGER="npm"
elif [[ -f "yarn.lock" ]]; then PKG_MANAGER="yarn"
elif [[ -f "pnpm-lock.yaml" ]]; then PKG_MANAGER="pnpm"
elif [[ -f "bun.lockb" ]]; then PKG_MANAGER="bun"
elif [[ -f "Cargo.toml" ]]; then PKG_MANAGER="cargo"
elif [[ -f "pyproject.toml" ]]; then PKG_MANAGER="pip"
elif [[ -f "go.mod" ]]; then PKG_MANAGER="go"
fi

jq -n \
  --argjson eslint "$ESLINT" \
  --argjson biome "$BIOME" \
  --argjson prettier "$PRETTIER" \
  --argjson ruff "$RUFF" \
  --argjson clippy "$CLIPPY" \
  --argjson golangci "$GOLANGCI" \
  --argjson typescript "$TYPESCRIPT" \
  --argjson mypy "$MYPY" \
  --argjson pyright "$PYRIGHT" \
  --argjson ci_github "$CI_GITHUB" \
  --arg package_manager "$PKG_MANAGER" \
  '{
    eslint: $eslint,
    biome: $biome,
    prettier: $prettier,
    ruff: $ruff,
    clippy: $clippy,
    golangci: $golangci,
    typescript: $typescript,
    mypy: $mypy,
    pyright: $pyright,
    ci_github: $ci_github,
    package_manager: $package_manager
  }'
