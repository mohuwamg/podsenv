#!/usr/bin/env bash
# Podsenv Error Handling Library
# 提供统一的错误处理和用户友好的错误信息

# 防止重复加载
if [ -n "${PODSENV_ERROR_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
export PODSENV_ERROR_LOADED=1

set -euo pipefail

# 错误代码定义
readonly PODSENV_ERROR_SUCCESS=0
readonly PODSENV_ERROR_GENERAL=1
readonly PODSENV_ERROR_INVALID_USAGE=2
readonly PODSENV_ERROR_VERSION_NOT_FOUND=3
readonly PODSENV_ERROR_VERSION_NOT_INSTALLED=4
readonly PODSENV_ERROR_INSTALLATION_FAILED=5
readonly PODSENV_ERROR_NETWORK=6
readonly PODSENV_ERROR_PERMISSION=7
readonly PODSENV_ERROR_DEPENDENCY=8
readonly PODSENV_ERROR_CONFIG=9
readonly PODSENV_ERROR_SYSTEM=10

# 错误消息获取函数
podsenv_get_error_message() {
  local code="$1"
  case "$code" in
    "$PODSENV_ERROR_SUCCESS") echo "Success" ;;
    "$PODSENV_ERROR_GENERAL") echo "General error" ;;
    "$PODSENV_ERROR_INVALID_USAGE") echo "Invalid usage" ;;
    "$PODSENV_ERROR_VERSION_NOT_FOUND") echo "Version not found" ;;
    "$PODSENV_ERROR_VERSION_NOT_INSTALLED") echo "Version not installed" ;;
    "$PODSENV_ERROR_INSTALLATION_FAILED") echo "Installation failed" ;;
    "$PODSENV_ERROR_NETWORK") echo "Network error" ;;
    "$PODSENV_ERROR_PERMISSION") echo "Permission denied" ;;
    "$PODSENV_ERROR_DEPENDENCY") echo "Missing dependency" ;;
    "$PODSENV_ERROR_CONFIG") echo "Configuration error" ;;
    "$PODSENV_ERROR_SYSTEM") echo "System error" ;;
    *) echo "Unknown error" ;;
  esac
}

# 颜色变量已在 podsenv-core.sh 中定义

# 显示错误信息
podsenv_error() {
  local message="$1"
  local error_code="${2:-$PODSENV_ERROR_GENERAL}"
  local show_help="${3:-false}"
  
  echo -e "${PODSENV_COLOR_RED}${PODSENV_COLOR_BOLD}podsenv: error:${PODSENV_COLOR_RESET} $message" >&2
  
  if [ "$show_help" = "true" ]; then
    echo >&2
    echo -e "${PODSENV_COLOR_BLUE}Run 'podsenv help' for usage information.${PODSENV_COLOR_RESET}" >&2
  fi
  
  return "$error_code"
}

# 显示警告信息
podsenv_warn() {
  local message="$1"
  echo -e "${PODSENV_COLOR_YELLOW}${PODSENV_COLOR_BOLD}podsenv: warning:${PODSENV_COLOR_RESET} $message" >&2
}

# 显示信息
podsenv_info() {
  local message="$1"
  echo -e "${PODSENV_COLOR_BLUE}${PODSENV_COLOR_BOLD}podsenv:${PODSENV_COLOR_RESET} $message" >&2
}

# 显示成功信息
podsenv_success() {
  local message="$1"
  echo -e "${PODSENV_COLOR_GREEN}${PODSENV_COLOR_BOLD}podsenv:${PODSENV_COLOR_RESET} $message" >&2
}

# 显示调试信息
podsenv_debug() {
  if [ "${PODSENV_DEBUG:-0}" = "1" ]; then
    local message="$1"
    echo -e "${PODSENV_COLOR_BLUE}podsenv: debug:${PODSENV_COLOR_RESET} $message" >&2
  fi
}

# 版本相关错误处理
podsenv_error_version_not_found() {
  local version="$1"
  local available_versions
  
  podsenv_error "version '$version' not found" "$PODSENV_ERROR_VERSION_NOT_FOUND"
  
  # 尝试提供相似版本建议
  if command -v podsenv-versions >/dev/null 2>&1; then
    available_versions="$(podsenv-versions --available 2>/dev/null | head -5 | tr '\n' ' ' || echo "")"
    if [ -n "$available_versions" ]; then
      echo >&2
      echo -e "${PODSENV_COLOR_BLUE}Available versions:${PODSENV_COLOR_RESET} $available_versions" >&2
      echo -e "${PODSENV_COLOR_BLUE}Run 'podsenv versions --available' to see all available versions.${PODSENV_COLOR_RESET}" >&2
    fi
  fi
  
  return "$PODSENV_ERROR_VERSION_NOT_FOUND"
}

# 版本未安装错误
podsenv_error_version_not_installed() {
  local version="$1"
  
  podsenv_error "version '$version' is not installed" "$PODSENV_ERROR_VERSION_NOT_INSTALLED"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Install it with: podsenv install $version${PODSENV_COLOR_RESET}" >&2
  
  return "$PODSENV_ERROR_VERSION_NOT_INSTALLED"
}

# 安装失败错误
podsenv_error_installation_failed() {
  local version="$1"
  local reason="${2:-unknown}"
  
  podsenv_error "failed to install CocoaPods $version: $reason" "$PODSENV_ERROR_INSTALLATION_FAILED"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Troubleshooting:${PODSENV_COLOR_RESET}" >&2
  echo "  1. Check your internet connection" >&2
  echo "  2. Verify you have sufficient disk space" >&2
  echo "  3. Run 'podsenv doctor' to check for issues" >&2
  echo "  4. Try installing with verbose output: podsenv install $version --verbose" >&2
  
  return "$PODSENV_ERROR_INSTALLATION_FAILED"
}

# 网络错误
podsenv_error_network() {
  local operation="$1"
  
  podsenv_error "network error during $operation" "$PODSENV_ERROR_NETWORK"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Please check:${PODSENV_COLOR_RESET}" >&2
  echo "  1. Your internet connection" >&2
  echo "  2. Firewall settings" >&2
  echo "  3. Proxy configuration (if applicable)" >&2
  
  return "$PODSENV_ERROR_NETWORK"
}

# 权限错误
podsenv_error_permission() {
  local path="$1"
  local operation="${2:-access}"
  
  podsenv_error "permission denied: cannot $operation '$path'" "$PODSENV_ERROR_PERMISSION"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Try:${PODSENV_COLOR_RESET}" >&2
  echo "  1. Check file/directory permissions" >&2
  echo "  2. Ensure you have write access to PODSENV_ROOT" >&2
  echo "  3. Run 'podsenv doctor' to check permissions" >&2
  
  return "$PODSENV_ERROR_PERMISSION"
}

# 依赖缺失错误
podsenv_error_missing_dependency() {
  local dependency="$1"
  local install_hint="${2:-}"
  
  podsenv_error "missing required dependency: $dependency" "$PODSENV_ERROR_DEPENDENCY"
  
  if [ -n "$install_hint" ]; then
    echo >&2
    echo -e "${PODSENV_COLOR_BLUE}Install it with:${PODSENV_COLOR_RESET} $install_hint" >&2
  fi
  
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Run 'podsenv doctor' to check all dependencies.${PODSENV_COLOR_RESET}" >&2
  
  return "$PODSENV_ERROR_DEPENDENCY"
}

# 配置错误
podsenv_error_config() {
  local config_file="$1"
  local issue="${2:-invalid configuration}"
  
  podsenv_error "configuration error in '$config_file': $issue" "$PODSENV_ERROR_CONFIG"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Please check the configuration file and fix any syntax errors.${PODSENV_COLOR_RESET}" >&2
  
  return "$PODSENV_ERROR_CONFIG"
}

# 使用错误
podsenv_error_usage() {
  local command="$1"
  local message="${2:-invalid usage}"
  
  podsenv_error "$message" "$PODSENV_ERROR_INVALID_USAGE"
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Usage: podsenv $command --help${PODSENV_COLOR_RESET}" >&2
  
  return "$PODSENV_ERROR_INVALID_USAGE"
}

# 系统错误
podsenv_error_system() {
  local operation="$1"
  local details="${2:-}"
  
  podsenv_error "system error during $operation" "$PODSENV_ERROR_SYSTEM"
  
  if [ -n "$details" ]; then
    echo -e "${PODSENV_COLOR_BLUE}Details:${PODSENV_COLOR_RESET} $details" >&2
  fi
  
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Run 'podsenv doctor' to diagnose system issues.${PODSENV_COLOR_RESET}" >&2
  
  return "$PODSENV_ERROR_SYSTEM"
}

# 错误恢复建议
podsenv_suggest_recovery() {
  local error_code="$1"
  
  case "$error_code" in
    "$PODSENV_ERROR_VERSION_NOT_INSTALLED")
      echo -e "${PODSENV_COLOR_BLUE}Suggestion: Run 'podsenv versions --available' to see installable versions${PODSENV_COLOR_RESET}" >&2
      ;;
    "$PODSENV_ERROR_INSTALLATION_FAILED")
      echo -e "${PODSENV_COLOR_BLUE}Suggestion: Try 'podsenv doctor' to check for common issues${PODSENV_COLOR_RESET}" >&2
      ;;
    "$PODSENV_ERROR_NETWORK")
      echo -e "${PODSENV_COLOR_BLUE}Suggestion: Check your internet connection and try again${PODSENV_COLOR_RESET}" >&2
      ;;
    "$PODSENV_ERROR_PERMISSION")
      echo -e "${PODSENV_COLOR_BLUE}Suggestion: Check file permissions or run 'podsenv doctor --fix'${PODSENV_COLOR_RESET}" >&2
      ;;
  esac
}

# 捕获和处理未预期的错误
podsenv_handle_unexpected_error() {
  local exit_code="$1"
  local command="${2:-unknown}"
  local line="${3:-unknown}"
  
  echo >&2
  echo -e "${PODSENV_COLOR_RED}${PODSENV_COLOR_BOLD}podsenv: unexpected error occurred${PODSENV_COLOR_RESET}" >&2
  echo -e "${PODSENV_COLOR_BLUE}Command:${PODSENV_COLOR_RESET} $command" >&2
  echo -e "${PODSENV_COLOR_BLUE}Exit code:${PODSENV_COLOR_RESET} $exit_code" >&2
  echo -e "${PODSENV_COLOR_BLUE}Line:${PODSENV_COLOR_RESET} $line" >&2
  echo >&2
  echo -e "${PODSENV_COLOR_BLUE}Please report this issue at: https://github.com/mohuwamg/podsenv/issues${PODSENV_COLOR_RESET}" >&2
  echo -e "${PODSENV_COLOR_BLUE}Include the above information and steps to reproduce.${PODSENV_COLOR_RESET}" >&2
}

# 设置错误陷阱
podsenv_setup_error_trap() {
  trap 'podsenv_handle_unexpected_error $? "${BASH_COMMAND}" "${LINENO}"' ERR
}

# 导出函数（静默执行）
{
  export -f podsenv_error
  export -f podsenv_warn
  export -f podsenv_info
  export -f podsenv_success
  export -f podsenv_debug
  export -f podsenv_error_version_not_found
  export -f podsenv_error_version_not_installed
  export -f podsenv_error_installation_failed
  export -f podsenv_error_network
  export -f podsenv_error_permission
  export -f podsenv_error_missing_dependency
  export -f podsenv_error_config
  export -f podsenv_error_usage
  export -f podsenv_error_system
  export -f podsenv_suggest_recovery
  export -f podsenv_handle_unexpected_error
  export -f podsenv_setup_error_trap
} >/dev/null 2>&1