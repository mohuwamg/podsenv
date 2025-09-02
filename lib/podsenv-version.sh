#!/usr/bin/env bash
# Podsenv Version Detection Library
# 版本检测和解析功能

set -euo pipefail

# 加载核心库
if [ -z "${PODSENV_ROOT:-}" ]; then
  PODSENV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# shellcheck source=lib/podsenv-core.sh
source "${PODSENV_ROOT}/lib/podsenv-core.sh"

# 版本别名解析函数
podsenv_resolve_version_alias() {
  local version="$1"
  case "$version" in
    "latest"|"stable"|"lts")
      # 这里可以实现具体的别名解析逻辑
      # 目前返回空字符串，表示需要进一步处理
      echo ""
      ;;
    *)
      echo "$version"
      ;;
  esac
}

# 查找版本文件
podsenv_find_version_file() {
  local dir="${1:-$(pwd)}"
  
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.podsenv-version" ]; then
      echo "$dir/.podsenv-version"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  
  return 1
}

# 读取版本文件内容
podsenv_read_version_file() {
  local file="$1"
  if [ -f "$file" ]; then
    # 读取第一行，去除注释和空白
    head -n 1 "$file" | sed 's/#.*$//' | xargs
  fi
}

# 解析版本别名
podsenv_resolve_version_alias() {
  local version="$1"
  
  case "$version" in
    "latest")
      podsenv_get_latest_version
      ;;
    "stable")
      podsenv_get_stable_version
      ;;
    "lts")
      podsenv_get_lts_version
      ;;
    *)
      echo "$version"
      ;;
  esac
}

# 获取最新版本
podsenv_get_latest_version() {
  local cache_file="${PODSENV_CACHE_DIR}/latest-version"
  local cache_age=3600  # 1小时缓存
  
  # 检查缓存
  if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
    cat "$cache_file"
    return
  fi
  
  # 从 RubyGems API 获取最新版本
  local latest_version
  if podsenv_command_exists "curl"; then
    latest_version=$(curl -s "https://rubygems.org/api/v1/gems/cocoapods.json" | \
      grep -o '"version":"[^"]*"' | \
      head -n 1 | \
      cut -d'"' -f4)
  elif podsenv_command_exists "wget"; then
    latest_version=$(wget -qO- "https://rubygems.org/api/v1/gems/cocoapods.json" | \
      grep -o '"version":"[^"]*"' | \
      head -n 1 | \
      cut -d'"' -f4)
  else
    podsenv_error "curl or wget is required to fetch latest version"
  fi
  
  if [ -n "$latest_version" ]; then
    echo "$latest_version" > "$cache_file"
    echo "$latest_version"
  else
    podsenv_error "Failed to fetch latest version"
  fi
}

# 获取稳定版本 (假设最新版本就是稳定版本)
podsenv_get_stable_version() {
  podsenv_get_latest_version
}

# 获取 LTS 版本 (CocoaPods 没有 LTS 概念，返回稳定版本)
podsenv_get_lts_version() {
  podsenv_get_stable_version
}

# 查找本地版本文件（支持版本继承）
podsenv_find_local_version() {
  local dir="$(pwd)"
  
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.podsenv-version" ]; then
      local version
      version="$(cat "$dir/.podsenv-version" | head -n1 | tr -d '[:space:]')"
      if [ -n "$version" ]; then
        echo "$version"
        return 0
      fi
    fi
    dir="$(dirname "$dir")"
  done
  
  return 1
}

# 检测当前版本
podsenv_detect_version() {
  local version=""
  local source=""
  
  # 1. 检查环境变量
  if [ -n "${PODSENV_VERSION:-}" ]; then
    version="$PODSENV_VERSION"
    source="shell"
  else
    # 2. 查找本地版本文件（支持版本继承）
    if version="$(podsenv_find_local_version)"; then
      source="local"
    else
      # 3. 检查全局版本文件
      local global_version_file="${PODSENV_ROOT}/version"
      if [ -f "$global_version_file" ]; then
        version="$(podsenv_read_version_file "$global_version_file")"
        source="global"
      else
        # 4. 检查系统版本
        if podsenv_command_exists "pod" && [ "$(command -v pod)" != "${PODSENV_SHIMS_DIR}/pod" ]; then
          version="system"
          source="system"
        fi
      fi
    fi
  fi
  
  # 解析版本别名
  if [ -n "$version" ] && [ "$version" != "system" ]; then
    version="$(podsenv_resolve_version_alias "$version")"
  fi
  
  # 验证版本格式
  if [ -n "$version" ] && [ "$version" != "system" ] && ! podsenv_version_valid "$version"; then
    podsenv_error "Invalid version format: $version"
  fi
  
  # 输出结果
  if [ -n "$version" ]; then
    echo "$version"
    podsenv_log "debug" "Detected version: $version (source: $source)"
  else
    podsenv_log "debug" "No version detected"
    return 1
  fi
}

# 获取版本来源
podsenv_get_version_source() {
  local version="${1:-}"
  
  if [ -z "$version" ]; then
    version="$(podsenv_detect_version 2>/dev/null || echo "")"
  fi
  
  if [ -z "$version" ]; then
    echo "none"
    return
  fi
  
  # 检查环境变量
  if [ -n "${PODSENV_VERSION:-}" ] && [ "$PODSENV_VERSION" = "$version" ]; then
    echo "shell"
    return
  fi
  
  # 检查本地版本文件
  local version_file
  if version_file="$(podsenv_find_version_file)"; then
    local file_version
    file_version="$(podsenv_read_version_file "$version_file")"
    file_version="$(podsenv_resolve_version_alias "$file_version")"
    if [ "$file_version" = "$version" ]; then
      echo "local ($version_file)"
      return
    fi
  fi
  
  # 检查全局版本文件
  local global_version_file="${PODSENV_ROOT}/version"
  if [ -f "$global_version_file" ]; then
    local global_version
    global_version="$(podsenv_read_version_file "$global_version_file")"
    global_version="$(podsenv_resolve_version_alias "$global_version")"
    if [ "$global_version" = "$version" ]; then
      echo "global ($global_version_file)"
      return
    fi
  fi
  
  # 系统版本
  if [ "$version" = "system" ]; then
    echo "system"
    return
  fi
  
  echo "unknown"
}

# 验证版本是否可用
podsenv_version_available() {
  local version="$1"
  
  if [ "$version" = "system" ]; then
    podsenv_command_exists "pod" && [ "$(command -v pod)" != "${PODSENV_SHIMS_DIR}/pod" ]
    return $?
  fi
  
  podsenv_version_installed "$version"
}

# 获取版本的完整路径
podsenv_version_path() {
  local version="$1"
  
  if [ "$version" = "system" ]; then
    command -v pod 2>/dev/null | head -n 1
  else
    echo "$(podsenv_gem_bin_dir "$version")/pod"
  fi
}

# 设置版本环境变量
podsenv_set_version_env() {
  local version="$1"
  
  if [ "$version" = "system" ]; then
    unset GEM_HOME
    unset GEM_PATH
  else
    local gem_home
    gem_home="$(podsenv_gem_home "$version")"
    export GEM_HOME="$gem_home"
    export GEM_PATH="$gem_home"
  fi
  
  podsenv_log "debug" "Set environment for version: $version"
}

# 获取可用版本列表 (从缓存或远程)
podsenv_available_versions() {
  local cache_file="${PODSENV_CACHE_DIR}/available-versions"
  local cache_age=86400  # 24小时缓存
  
  # 检查缓存
  if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
    cat "$cache_file"
    return
  fi
  
  # 从 RubyGems API 获取版本列表
  local versions
  if podsenv_command_exists "curl"; then
    versions=$(curl -s "https://rubygems.org/api/v1/versions/cocoapods.json" | \
      grep -o '"number":"[^"]*"' | \
      cut -d'"' -f4 | \
      sort -V)
  elif podsenv_command_exists "wget"; then
    versions=$(wget -qO- "https://rubygems.org/api/v1/versions/cocoapods.json" | \
      grep -o '"number":"[^"]*"' | \
      cut -d'"' -f4 | \
      sort -V)
  else
    podsenv_error "curl or wget is required to fetch available versions"
  fi
  
  if [ -n "$versions" ]; then
    echo "$versions" > "$cache_file"
    echo "$versions"
  else
    podsenv_error "Failed to fetch available versions"
  fi
}

# 版本前缀匹配
podsenv_version_prefix_match() {
  local prefix="$1"
  local versions
  
  # 获取已安装的版本
  versions="$(podsenv_installed_versions)"
  
  # 查找匹配的版本
  echo "$versions" | grep "^${prefix}" | tail -n 1
}

# 获取版本信息
podsenv_version_info() {
  local version="$1"
  local show_origin="${2:-false}"
  
  if [ -z "$version" ]; then
    echo "podsenv: no version specified" >&2
    return 1
  fi
  
  local current_version source
  current_version="$(podsenv_detect_version)"
  
  if [ "$version" = "$current_version" ]; then
    if [ "$show_origin" = "true" ]; then
      source="$(podsenv_get_version_source)"
      echo "$version ($source)"
    else
      echo "$version"
    fi
  else
    echo "$version"
  fi
}

# 自动版本切换功能
podsenv_auto_switch() {
  # 只在启用自动切换时执行
  if [ "${PODSENV_AUTO_SWITCH:-1}" != "1" ]; then
    return 0
  fi
  
  local current_version new_version
  current_version="${PODSENV_VERSION:-}"
  new_version="$(podsenv_find_local_version)"
  
  # 如果找到本地版本且与当前版本不同，则切换
  if [ -n "$new_version" ] && [ "$new_version" != "$current_version" ]; then
    if podsenv_version_exists "$new_version"; then
      export PODSENV_VERSION="$new_version"
      if [ "${PODSENV_QUIET:-0}" != "1" ]; then
        echo "podsenv: switched to $new_version (from .podsenv-version)"
      fi
    else
      if [ "${PODSENV_QUIET:-0}" != "1" ]; then
        echo "podsenv: version '$new_version' is not installed" >&2
        echo "podsenv: run 'podsenv install $new_version' to install it" >&2
      fi
    fi
  fi
}

# 检查版本是否已安装
podsenv_version_exists() {
  local version="$1"
  [ -d "${PODSENV_ROOT}/versions/$version" ]
}

# 导出函数（静默执行）
{
  export -f podsenv_find_version_file
  export -f podsenv_read_version_file
  export -f podsenv_resolve_version_alias
  export -f podsenv_get_latest_version
  export -f podsenv_get_stable_version
  export -f podsenv_get_lts_version
  export -f podsenv_detect_version
  export -f podsenv_get_version_source
  export -f podsenv_version_available
  export -f podsenv_version_path
  export -f podsenv_set_version_env
  export -f podsenv_available_versions
  export -f podsenv_version_prefix_match
  export -f podsenv_version_info
  export -f podsenv_auto_switch
  export -f podsenv_version_exists
} >/dev/null 2>&1