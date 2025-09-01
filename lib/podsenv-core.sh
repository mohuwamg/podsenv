#!/usr/bin/env bash
# Podsenv Core Library
# 核心函数库，提供基础功能和常量定义

set -euo pipefail

# 版本信息
PODSENV_VERSION="2.0.0"

# 核心目录定义
if [ -z "${PODSENV_ROOT:-}" ]; then
  if [ -n "${BASH_SOURCE:-}" ]; then
    PODSENV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  else
    PODSENV_ROOT="${HOME}/.podsenv"
  fi
fi

export PODSENV_ROOT
export PODSENV_VERSIONS_DIR="${PODSENV_ROOT}/versions"
export PODSENV_SHIMS_DIR="${PODSENV_ROOT}/shims"
export PODSENV_CACHE_DIR="${PODSENV_ROOT}/cache"
export PODSENV_PLUGINS_DIR="${PODSENV_ROOT}/plugins"
export PODSENV_LOGS_DIR="${PODSENV_ROOT}/logs"

# 颜色定义
if [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM}" != "dumb" ]; then
  export PODSENV_COLOR_RED="\033[31m"
  export PODSENV_COLOR_GREEN="\033[32m"
  export PODSENV_COLOR_YELLOW="\033[33m"
  export PODSENV_COLOR_BLUE="\033[34m"
  export PODSENV_COLOR_MAGENTA="\033[35m"
  export PODSENV_COLOR_CYAN="\033[36m"
  export PODSENV_COLOR_RESET="\033[0m"
  export PODSENV_COLOR_BOLD="\033[1m"
else
  export PODSENV_COLOR_RED=""
  export PODSENV_COLOR_GREEN=""
  export PODSENV_COLOR_YELLOW=""
  export PODSENV_COLOR_BLUE=""
  export PODSENV_COLOR_MAGENTA=""
  export PODSENV_COLOR_CYAN=""
  export PODSENV_COLOR_RESET=""
  export PODSENV_COLOR_BOLD=""
fi

# 日志函数
podsenv_log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  
  case "$level" in
    "error")
      echo -e "${PODSENV_COLOR_RED}podsenv: error: ${message}${PODSENV_COLOR_RESET}" >&2
      echo "[$timestamp] ERROR: $message" >> "${PODSENV_LOGS_DIR}/error.log" 2>/dev/null || true
      ;;
    "warn")
      echo -e "${PODSENV_COLOR_YELLOW}podsenv: warning: ${message}${PODSENV_COLOR_RESET}" >&2
      ;;
    "info")
      echo -e "${PODSENV_COLOR_BLUE}podsenv: ${message}${PODSENV_COLOR_RESET}"
      ;;
    "success")
      echo -e "${PODSENV_COLOR_GREEN}podsenv: ${message}${PODSENV_COLOR_RESET}"
      ;;
    "debug")
      if [ "${PODSENV_DEBUG:-}" = "1" ]; then
        echo -e "${PODSENV_COLOR_MAGENTA}podsenv: debug: ${message}${PODSENV_COLOR_RESET}" >&2
      fi
      ;;
  esac
}

# 错误处理函数
podsenv_error() {
  podsenv_log "error" "$*"
  exit 1
}

# 确保目录存在
podsenv_ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" || podsenv_error "Failed to create directory: $dir"
  fi
}

# 检查命令是否存在
podsenv_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# 检查版本格式是否有效
podsenv_version_valid() {
  local version="$1"
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][a-zA-Z0-9]+)*$ ]]; then
    return 0
  else
    return 1
  fi
}

# 比较版本号
podsenv_version_compare() {
  local version1="$1"
  local version2="$2"
  
  if [ "$version1" = "$version2" ]; then
    echo "0"
    return
  fi
  
  local IFS='.'
  local i ver1=($version1) ver2=($version2)
  
  # 填充较短的版本号
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do
    ver2[i]=0
  done
  
  for ((i=0; i<${#ver1[@]}; i++)); do
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      echo "1"
      return
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      echo "-1"
      return
    fi
  done
  
  echo "0"
}

# 获取版本安装路径
podsenv_version_dir() {
  local version="$1"
  echo "${PODSENV_VERSIONS_DIR}/${version}"
}

# 获取版本的 gem home
podsenv_gem_home() {
  local version="$1"
  echo "$(podsenv_version_dir "$version")/lib/ruby/gems"
}

# 获取版本的 gem bin 目录
podsenv_gem_bin_dir() {
  local version="$1"
  echo "$(podsenv_version_dir "$version")/bin"
}

# 检查版本是否已安装
podsenv_version_installed() {
  local version="$1"
  local version_dir
  version_dir="$(podsenv_version_dir "$version")"
  [ -d "$version_dir" ] && [ -x "$version_dir/bin/pod" ]
}

# 获取已安装的版本列表
podsenv_installed_versions() {
  if [ ! -d "$PODSENV_VERSIONS_DIR" ]; then
    return
  fi
  
  find "$PODSENV_VERSIONS_DIR" -maxdepth 1 -type d -name "*.*.*" -exec basename {} \; | sort -V
}

# 初始化 podsenv 环境
podsenv_init() {
  # 确保必要的目录存在
  podsenv_ensure_dir "$PODSENV_ROOT"
  podsenv_ensure_dir "$PODSENV_VERSIONS_DIR"
  podsenv_ensure_dir "$PODSENV_SHIMS_DIR"
  podsenv_ensure_dir "$PODSENV_CACHE_DIR"
  podsenv_ensure_dir "$PODSENV_PLUGINS_DIR"
  podsenv_ensure_dir "$PODSENV_LOGS_DIR"
  
  # 检查依赖
  if ! podsenv_command_exists "gem"; then
    podsenv_error "gem command not found. Please install Ruby first."
  fi
  
  podsenv_log "debug" "Podsenv initialized with root: $PODSENV_ROOT"
}

# 加载配置文件
podsenv_load_config() {
  local config_file="${PODSENV_ROOT}/config"
  if [ -f "$config_file" ]; then
    # shellcheck source=/dev/null
    source "$config_file"
    podsenv_log "debug" "Loaded config from: $config_file"
  fi
}

# 显示进度条
podsenv_progress() {
  local current="$1"
  local total="$2"
  local message="${3:-}"
  local width=50
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  
  printf "\r${PODSENV_COLOR_BLUE}[%s%s] %d%% %s${PODSENV_COLOR_RESET}" \
    "$(printf '%*s' "$filled" '' | tr ' ' '=')"\
    "$(printf '%*s' "$empty" '')"\
    "$percentage" \
    "$message"
  
  if [ "$current" -eq "$total" ]; then
    echo
  fi
}

# 清理函数
podsenv_cleanup() {
  local exit_code=$?
  # 清理临时文件等
  exit $exit_code
}

# 设置清理陷阱
trap podsenv_cleanup EXIT INT TERM

# 加载其他库
source "${PODSENV_ROOT}/lib/podsenv-error.sh"

# 导出核心函数
export -f podsenv_log
export -f podsenv_error
export -f podsenv_ensure_dir
export -f podsenv_command_exists
export -f podsenv_version_valid
export -f podsenv_version_compare
export -f podsenv_version_dir
export -f podsenv_gem_home
export -f podsenv_gem_bin_dir
export -f podsenv_version_installed
export -f podsenv_installed_versions
export -f podsenv_init
export -f podsenv_load_config
export -f podsenv_progress