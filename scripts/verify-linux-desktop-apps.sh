#!/usr/bin/env bash
set -euo pipefail

failures=0

note() {
  printf '%s\n' "$*"
}

ok() {
  printf 'ok: %s\n' "$*"
}

warn() {
  printf 'warn: %s\n' "$*" >&2
}

fail() {
  printf 'fail: %s\n' "$*" >&2
  failures=$((failures + 1))
}

require_command() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "command available: $1"
  else
    fail "command missing: $1"
  fi
}

check_path() {
  if [ -e "$1" ]; then
    ok "path exists: $1"
  else
    fail "path missing: $1"
  fi
}

check_executable() {
  if [ -x "$1" ]; then
    ok "executable: $1"
  else
    fail "not executable or missing: $1"
  fi
}

check_symlink_target_prefix() {
  link_path="$1"
  expected_prefix="$2"

  if [ ! -L "$link_path" ]; then
    fail "not a symlink: $link_path"
    return
  fi

  target="$(readlink -f "$link_path")"
  case "$target" in
    "$expected_prefix"/*)
      ok "$link_path points into $expected_prefix"
      ;;
    *)
      fail "$link_path points to $target, expected $expected_prefix"
      ;;
  esac
}

check_desktop_file() {
  desktop_file="$1"
  exec_path="$2"

  check_path "$desktop_file"

  if [ -f "$desktop_file" ] && grep -F "Exec=$exec_path" "$desktop_file" >/dev/null 2>&1; then
    ok "desktop Exec references $exec_path"
  else
    fail "desktop Exec does not reference $exec_path: $desktop_file"
  fi
}

note "Checking required shell commands"
require_command "command"
require_command "grep"
require_command "readlink"
require_command "find"

note ""
note "Checking 1Password"
check_path "/opt/1Password"
check_executable "/opt/1Password/1password"
check_path "/opt/1Password/after-install.sh"
require_command "1password"
check_desktop_file "/usr/share/applications/1password.desktop" "/opt/1Password/1password"

if [ -e "/etc/1password/custom_allowed_browsers" ]; then
  ok "1Password custom browser allow-list exists"
else
  warn "1Password custom browser allow-list not present: /etc/1password/custom_allowed_browsers"
fi

if [ -S "${SSH_AUTH_SOCK:-}" ]; then
  ok "SSH_AUTH_SOCK points to a socket: ${SSH_AUTH_SOCK}"
else
  warn "SSH_AUTH_SOCK is unset or not a socket; configure 1Password SSH agent in the app before SSH tests"
fi

note ""
note "Checking GitKraken"
check_path "/opt/gitkraken"
check_executable "/opt/gitkraken/gitkraken"
require_command "gitkraken"
check_symlink_target_prefix "/usr/local/bin/gitkraken" "/opt/gitkraken"
check_desktop_file "/usr/share/applications/gitkraken.desktop" "/opt/gitkraken/gitkraken"

note ""
note "Checking Zen Browser"
check_path "/opt/zen-browser"
check_executable "/opt/zen-browser/zen"
require_command "zen"
require_command "zen-browser"
check_symlink_target_prefix "/usr/local/bin/zen" "/opt/zen-browser"
check_symlink_target_prefix "/usr/local/bin/zen-browser" "/opt/zen-browser"
check_desktop_file "/usr/share/applications/zen-browser.desktop" "/opt/zen-browser/zen"
check_path "/opt/zen-browser/browser/chrome/icons/default/default128.png"

note ""
if [ "$failures" -eq 0 ]; then
  ok "verification completed without hard failures"
else
  fail "$failures verification check(s) failed"
  exit 1
fi
