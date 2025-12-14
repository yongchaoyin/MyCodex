#!/bin/bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-"$HOME/.claude"}"
BIN_DIR="${INSTALL_DIR}/bin"

mkdir -p "${BIN_DIR}"

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: go not found in PATH (required to build codeagent-wrapper)" >&2
  exit 127
fi

echo "Building codeagent-wrapper..."
cd ./codeagent-wrapper
go build -o "${BIN_DIR}/codeagent-wrapper" .
cd ..
chmod +x "${BIN_DIR}/codeagent-wrapper"

# Backward compatibility: codex-wrapper alias
if command -v ln >/dev/null 2>&1; then
  ln -sf "codeagent-wrapper" "${BIN_DIR}/codex-wrapper" || true
fi

echo "Installed:"
echo "  ${BIN_DIR}/codeagent-wrapper"
echo "  ${BIN_DIR}/codex-wrapper (alias)"

"${BIN_DIR}/codeagent-wrapper" --version >/dev/null 2>&1 || {
  echo "ERROR: installation verification failed" >&2
  exit 1
}
