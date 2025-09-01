# podsenv: CocoaPods 版本管理工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash%2FZsh%2FFish-blue.svg)](https://github.com/mohuwamg/podsenv)

podsenv 是一个现代化的 CocoaPods 版本管理工具，灵感来源于 `pyenv` 和 `nvm`。它允许你在同一台机器上轻松安装、切换和管理多个不同版本的 CocoaPods，提供无缝的开发体验。

## ✨ 特性

- 🚀 **多版本支持** - 在一台机器上安装和管理任意数量的 CocoaPods 版本
- 🔄 **智能版本切换** - 支持全局、项目局部和 shell 会话级别的版本管理
- 📁 **版本继承** - 自动向上查找 `.podsenv-version` 文件，支持项目嵌套
- 🎯 **自动版本切换** - 进入包含 `.podsenv-version` 的目录时自动切换版本
- 🔧 **Shim 机制** - 通过 shim 拦截 `pod` 命令，自动选择正确的版本
- 🧩 **插件系统** - 支持扩展功能，提供丰富的钩子机制
- 🛠️ **诊断工具** - 内置 `doctor` 命令检查环境配置
- 🎨 **友好错误提示** - 彩色输出和详细的错误信息
- 🐚 **多 Shell 支持** - 支持 Bash、Zsh 和 Fish shell
- 📋 **自动补全** - 提供完整的命令行自动补全

## 📦 安装

### 自动安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/mohuwamg/podsenv/main/install.sh | bash
```

### 手动安装

1. **克隆仓库**

   ```bash
   git clone https://github.com/mohuwamg/podsenv.git ~/.podsenv
   ```

2. **配置环境变量**

   将以下内容添加到你的 shell 配置文件（`~/.bashrc`、`~/.zshrc` 或 `~/.config/fish/config.fish`）：

   **Bash/Zsh:**
   ```bash
   export PATH="$HOME/.podsenv/bin:$PATH"
   eval "$(podsenv init -)"
   ```

   **Fish:**
   ```fish
   set -gx PATH $HOME/.podsenv/bin $PATH
   podsenv init - | source
   ```

3. **重启 shell 或重新加载配置**

   ```bash
   exec $SHELL
   # 或者
   source ~/.bashrc  # 根据你的 shell 调整
   ```

4. **验证安装**

   ```bash
   podsenv --version
   podsenv doctor
   ```

## 🚀 快速开始

```bash
# 查看可用版本
podsenv versions --available

# 安装最新版本
podsenv install latest

# 设置全局版本
podsenv global 1.15.2

# 为项目设置特定版本
cd my-ios-project
podsenv local 1.14.3

# 验证当前版本
podsenv version
pod --version
```

## 📖 使用指南

### 版本管理

#### 安装版本

```bash
# 安装特定版本
podsenv install 1.15.2

# 安装最新版本
podsenv install latest

# 安装最新稳定版
podsenv install stable

# 强制重新安装
podsenv install 1.15.2 --force

# 详细输出
podsenv install 1.15.2 --verbose
```

#### 卸载版本

```bash
# 卸载特定版本
podsenv uninstall 1.14.3

# 强制卸载（跳过确认）
podsenv uninstall 1.14.3 --force
```

#### 查看版本

```bash
# 列出已安装的版本
podsenv versions

# 列出可安装的版本
podsenv versions --available

# 仅显示版本号
podsenv versions --bare
```

### 版本切换

#### 全局版本

```bash
# 设置全局默认版本
podsenv global 1.15.2

# 查看全局版本
podsenv global
```

#### 项目版本

```bash
# 为当前项目设置版本
podsenv local 1.14.3

# 查看项目版本
podsenv local

# 取消项目版本设置
podsenv local --unset
```

#### Shell 会话版本

```bash
# 为当前 shell 会话设置版本
podsenv shell 1.13.0

# 查看 shell 版本
podsenv shell

# 取消 shell 版本设置
podsenv shell --unset
```

### 高级功能

#### 版本信息

```bash
# 查看当前激活版本
podsenv version

# 显示版本来源
podsenv version --origin

# 详细版本信息
podsenv version --verbose
```

#### 查找命令

```bash
# 查看 pod 命令的实际路径
podsenv which pod

# 查看所有相关命令
podsenv which --all
```

#### 执行命令

```bash
# 使用特定版本执行命令
podsenv exec 1.14.3 pod install

# 在特定版本环境中启动 shell
podsenv exec 1.14.3 bash
```

#### 安装路径

```bash
# 查看版本安装路径
podsenv prefix 1.15.2

# 查看当前版本路径
podsenv prefix

# 列出所有版本路径
podsenv prefix --all
```

### 维护命令

#### 重建 Shims

```bash
# 重建所有 shim 文件
podsenv rehash

# 详细输出
podsenv rehash --verbose
```

#### 环境诊断

```bash
# 检查环境配置
podsenv doctor

# 尝试自动修复问题
podsenv doctor --fix

# 详细诊断信息
podsenv doctor --verbose
```

## 🧩 插件系统

podsenv 支持插件扩展功能，允许你自定义和增强工具的行为。

### 插件管理

```bash
# 列出所有插件
podsenv plugin list

# 安装插件
podsenv plugin install https://github.com/user/podsenv-plugin.git

# 启用插件
podsenv plugin enable plugin-name

# 禁用插件
podsenv plugin disable plugin-name

# 更新插件
podsenv plugin update plugin-name

# 卸载插件
podsenv plugin uninstall plugin-name

# 查看插件信息
podsenv plugin info plugin-name
```

### 创建插件

插件结构：

```
my-plugin/
├── init.sh              # 插件初始化脚本
├── hooks/               # 钩子脚本目录
│   ├── after_install.sh
│   ├── before_uninstall.sh
│   └── ...
├── README.md           # 插件文档
└── config/             # 插件配置（自动创建）
```

可用钩子：
- `before_install` / `after_install`
- `before_uninstall` / `after_uninstall`
- `before_version_change` / `after_version_change`
- `before_rehash` / `after_rehash`

## ⚙️ 配置

### 环境变量

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `PODSENV_ROOT` | `~/.podsenv` | podsenv 安装目录 |
| `PODSENV_VERSION` | - | 当前 shell 会话版本 |
| `PODSENV_AUTO_SWITCH` | `1` | 是否启用自动版本切换 |
| `PODSENV_AUTO_INSTALL` | `false` | 是否自动安装缺失版本 |
| `PODSENV_DEBUG` | `0` | 是否启用调试模式 |
| `PODSENV_QUIET` | `0` | 是否启用静默模式 |
| `PODSENV_NO_COLOR` | - | 禁用彩色输出 |

### 配置示例

```bash
# 禁用自动版本切换
export PODSENV_AUTO_SWITCH=0

# 启用自动安装
export PODSENV_AUTO_INSTALL=true

# 启用调试模式
export PODSENV_DEBUG=1

# 禁用彩色输出
export PODSENV_NO_COLOR=1
```

## 🔧 工作原理

podsenv 通过以下机制实现版本管理：

1. **Shim 拦截**: 在 `PATH` 中插入 shim 目录，拦截 `pod` 命令调用
2. **版本解析**: 按优先级查找版本配置：
   - `PODSENV_VERSION` 环境变量（shell 版本）
   - `.podsenv-version` 文件（项目版本，支持向上查找）
   - `~/.podsenv/version` 文件（全局版本）
3. **环境隔离**: 每个版本安装在独立的 `GEM_HOME` 中
4. **自动切换**: 监听目录变化，自动切换到对应版本

### 版本优先级

```
Shell 版本 (podsenv shell)
    ↓
项目版本 (.podsenv-version)
    ↓
全局版本 (podsenv global)
    ↓
系统版本 (system)
```

## 🐛 故障排除

### 常见问题

**Q: `podsenv: command not found`**

A: 确保已正确配置 `PATH` 并重启 shell：
```bash
echo 'export PATH="$HOME/.podsenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(podsenv init -)"' >> ~/.bashrc
exec $SHELL
```

**Q: `pod` 命令找不到或版本不对**

A: 运行 `podsenv rehash` 重建 shim 文件。

**Q: 版本安装失败**

A: 检查网络连接和权限，运行 `podsenv doctor` 诊断问题。

**Q: 自动版本切换不工作**

A: 确保已启用自动切换功能：
```bash
export PODSENV_AUTO_SWITCH=1
```

### 诊断命令

```bash
# 全面环境检查
podsenv doctor

# 查看当前配置
podsenv version --verbose

# 检查 shim 状态
podsenv which pod

# 启用调试模式
PODSENV_DEBUG=1 podsenv install 1.15.2
```

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细信息。

### 开发设置

```bash
# 克隆仓库
git clone https://github.com/mohuwamg/podsenv.git
cd podsenv

# 安装开发版本
./install.sh

# 运行测试
./test/run_tests.sh
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [pyenv](https://github.com/pyenv/pyenv) - Python 版本管理工具
- [nvm](https://github.com/nvm-sh/nvm) - Node.js 版本管理工具
- [rbenv](https://github.com/rbenv/rbenv) - Ruby 版本管理工具

## 📚 相关链接

- [CocoaPods 官网](https://cocoapods.org/)
- [问题反馈](https://github.com/mohuwamg/podsenv/issues)
- [更新日志](CHANGELOG.md)
- [架构设计](ARCHITECTURE_DESIGN.md)

