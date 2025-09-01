# Podsenv 2.0 架构设计

## 总体架构

### 设计原则
1. **简单性**: 纯 shell 脚本实现，减少外部依赖
2. **模块化**: 功能模块化，易于维护和扩展
3. **兼容性**: 与现有 shell 环境良好集成
4. **可扩展性**: 支持插件系统，允许功能扩展
5. **用户友好**: 提供清晰的错误信息和帮助

### 核心组件
```
podsenv/
├── bin/
│   └── podsenv              # 主执行文件
├── libexec/
│   ├── podsenv-install      # 安装命令实现
│   ├── podsenv-uninstall    # 卸载命令实现
│   ├── podsenv-global       # 全局版本设置
│   ├── podsenv-local        # 本地版本设置
│   ├── podsenv-shell        # Shell 版本设置
│   ├── podsenv-versions     # 版本列表
│   ├── podsenv-which        # 命令路径查询
│   ├── podsenv-exec         # 命令执行
│   ├── podsenv-prefix       # 版本路径查询
│   ├── podsenv-rehash       # Shim 重建
│   ├── podsenv-init         # Shell 初始化
│   └── podsenv-help         # 帮助信息
├── lib/
│   ├── podsenv-core.sh      # 核心函数库
│   ├── podsenv-version.sh   # 版本检测逻辑
│   ├── podsenv-install.sh   # 安装逻辑
│   ├── podsenv-shim.sh      # Shim 管理
│   └── podsenv-utils.sh     # 工具函数
├── plugins/
│   └── README.md            # 插件开发指南
├── completions/
│   ├── podsenv.bash         # Bash 自动补全
│   ├── podsenv.zsh          # Zsh 自动补全
│   └── podsenv.fish         # Fish 自动补全
└── share/
    ├── man/
    │   └── man1/
    │       └── podsenv.1     # Man 页面
    └── doc/
        ├── README.md        # 使用文档
        └── PLUGINS.md       # 插件开发文档
```

## 运行时目录结构

```
~/.podsenv/
├── version                  # 全局版本文件
├── versions/
│   ├── 1.11.3/
│   │   ├── bin/
│   │   │   └── pod
│   │   └── lib/
│   │       └── ruby/
│   └── 1.12.0/
│       ├── bin/
│       │   └── pod
│       └── lib/
│           └── ruby/
├── shims/
│   └── pod                  # Shim 脚本
├── cache/
│   ├── available-versions   # 可用版本缓存
│   └── install-cache/       # 安装包缓存
├── plugins/
│   └── podsenv-update/      # 示例插件
└── logs/
    ├── install.log          # 安装日志
    └── error.log            # 错误日志
```

## 核心模块设计

### 1. 主执行文件 (bin/podsenv)
```bash
#!/usr/bin/env bash
# 主入口点，负责:
# - 环境初始化
# - 命令分发
# - 错误处理
# - 插件加载
```

### 2. 版本检测模块 (lib/podsenv-version.sh)
```bash
# 版本检测优先级:
# 1. PODSENV_VERSION 环境变量
# 2. .podsenv-version 文件 (当前目录向上查找)
# 3. ~/.podsenv/version 全局版本文件
# 4. system (如果存在系统 CocoaPods)

podsenv_version_detect() {
    # 实现智能版本检测逻辑
}

podsenv_version_resolve() {
    # 解析版本别名 (latest, stable 等)
}
```

### 3. 安装模块 (lib/podsenv-install.sh)
```bash
# 支持多种安装方式:
# - 从 RubyGems 安装指定版本
# - 从本地 gem 文件安装
# - 从 Git 仓库安装开发版本

podsenv_install_version() {
    # 版本安装逻辑
}

podsenv_install_progress() {
    # 安装进度显示
}
```

### 4. Shim 管理模块 (lib/podsenv-shim.sh)
```bash
# Shim 脚本生成和管理
# 支持多命令 shim (pod, pod-install 等)

podsenv_shim_create() {
    # 创建 shim 脚本
}

podsenv_shim_rehash() {
    # 重新生成所有 shim
}
```

### 5. 插件系统 (plugins/)
```bash
# 插件发现和加载机制
# 插件命名规范: podsenv-<plugin-name>
# 插件接口标准化

podsenv_plugin_load() {
    # 加载插件
}

podsenv_plugin_list() {
    # 列出可用插件
}
```

## 配置文件格式

### 1. 版本文件格式
```
# .podsenv-version 或 ~/.podsenv/version
1.11.3

# 支持注释和别名
1.11.3  # 稳定版本
latest  # 最新版本别名
```

### 2. 配置文件 (~/.podsenv/config)
```bash
# Podsenv 配置文件
PODSENV_MIRROR="https://rubygems.org"  # Gem 镜像源
PODSENV_CACHE_ENABLED="true"           # 启用缓存
PODSENV_AUTO_INSTALL="false"          # 自动安装缺失版本
PODSENV_VERBOSE="false"               # 详细输出
```

## 命令接口设计

### 基础命令
```bash
podsenv install <version>     # 安装指定版本
podsenv uninstall <version>   # 卸载指定版本
podsenv global <version>      # 设置全局版本
podsenv local <version>       # 设置本地版本
podsenv shell <version>       # 设置 shell 版本
podsenv versions              # 列出已安装版本
```

### 高级命令
```bash
podsenv which <command>       # 显示命令路径
podsenv exec <version> <cmd>  # 在指定版本环境执行命令
podsenv prefix <version>      # 显示版本安装路径
podsenv rehash               # 重建 shim 脚本
podsenv init                 # 输出 shell 初始化代码
```

### 信息命令
```bash
podsenv version              # 显示 podsenv 版本
podsenv help [command]       # 显示帮助信息
podsenv doctor              # 诊断环境问题
```

### 扩展命令 (通过插件)
```bash
podsenv update              # 更新 podsenv (插件)
podsenv list-remote         # 列出远程可用版本 (插件)
podsenv migrate             # 迁移旧版本配置 (插件)
```

## 错误处理策略

### 1. 错误分类
- **用户错误**: 命令使用错误、版本不存在等
- **系统错误**: 权限问题、网络问题等
- **环境错误**: 依赖缺失、配置错误等

### 2. 错误信息格式
```bash
podsenv: <error-type>: <error-message>
<suggestion-or-help>

# 示例:
podsenv: version-not-found: CocoaPods version '1.15.0' is not installed
Run 'podsenv install 1.15.0' to install it.
```

### 3. 日志记录
- 安装日志: `~/.podsenv/logs/install.log`
- 错误日志: `~/.podsenv/logs/error.log`
- 调试模式: `PODSENV_DEBUG=1`

## 性能优化

### 1. 缓存机制
- 版本列表缓存
- 安装包缓存
- 版本检测结果缓存

### 2. 延迟加载
- 按需加载功能模块
- 插件延迟初始化

### 3. 并行处理
- 支持并行安装多个版本
- 异步版本检查

## 兼容性考虑

### 1. Shell 兼容性
- 支持 bash 4.0+
- 支持 zsh 5.0+
- 支持 fish 3.0+

### 2. 系统兼容性
- macOS 10.12+
- Linux (Ubuntu 18.04+, CentOS 7+)
- Windows (WSL)

### 3. 向后兼容
- 支持从 podsenv 1.x 迁移
- 保持核心命令接口不变