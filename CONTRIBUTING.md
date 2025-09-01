# 贡献指南

感谢你对 podsenv 项目的关注！我们欢迎所有形式的贡献，包括但不限于：

- 🐛 报告 Bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复
- 🧩 开发插件
- 🧪 编写测试

## 📋 目录

- [开发环境设置](#开发环境设置)
- [项目结构](#项目结构)
- [代码规范](#代码规范)
- [提交流程](#提交流程)
- [测试指南](#测试指南)
- [文档编写](#文档编写)
- [插件开发](#插件开发)
- [问题报告](#问题报告)
- [功能请求](#功能请求)

## 🛠️ 开发环境设置

### 前置要求

- **操作系统**: macOS, Linux, 或 Windows (WSL)
- **Shell**: Bash 4.0+, Zsh 5.0+, 或 Fish 3.0+
- **Ruby**: 2.6+ (用于 CocoaPods)
- **Git**: 2.0+

### 设置步骤

1. **Fork 仓库**

   在 GitHub 上 fork [podsenv 仓库](https://github.com/mohuwamg/podsenv)

2. **克隆你的 fork**

   ```bash
   git clone https://github.com/YOUR_USERNAME/podsenv.git
   cd podsenv
   ```

3. **添加上游仓库**

   ```bash
   git remote add upstream https://github.com/mohuwamg/podsenv.git
   ```

4. **安装开发版本**

   ```bash
   ./install.sh
   ```

5. **配置开发环境**

   ```bash
   # 启用调试模式
   export PODSENV_DEBUG=1
   
   # 重新加载 shell
   exec $SHELL
   ```

6. **验证安装**

   ```bash
   podsenv --version
   podsenv doctor
   ```

## 📁 项目结构

```
podsenv/
├── bin/                    # 主要可执行文件
│   └── podsenv            # 主入口脚本
├── libexec/               # 子命令实现
│   ├── podsenv-install    # 安装命令
│   ├── podsenv-uninstall  # 卸载命令
│   ├── podsenv-global     # 全局版本命令
│   ├── podsenv-local      # 局部版本命令
│   ├── podsenv-shell      # Shell 版本命令
│   ├── podsenv-versions   # 版本列表命令
│   ├── podsenv-version    # 当前版本命令
│   ├── podsenv-which      # 查找命令
│   ├── podsenv-exec       # 执行命令
│   ├── podsenv-prefix     # 路径命令
│   ├── podsenv-rehash     # 重建 shim 命令
│   ├── podsenv-doctor     # 诊断命令
│   ├── podsenv-plugin     # 插件管理命令
│   ├── podsenv-init       # 初始化命令
│   └── podsenv-help       # 帮助命令
├── lib/                   # 核心库文件
│   ├── podsenv-core.sh    # 核心功能
│   ├── podsenv-version.sh # 版本管理
│   └── podsenv-error.sh   # 错误处理
├── shims/                 # Shim 文件目录
├── versions/              # 版本安装目录
├── plugins/               # 插件目录
├── completions/           # 自动补全脚本
│   ├── podsenv.bash
│   ├── podsenv.zsh
│   └── podsenv.fish
├── test/                  # 测试文件
├── docs/                  # 文档
├── install.sh             # 安装脚本
├── README.md              # 项目说明
├── CHANGELOG.md           # 更新日志
├── CONTRIBUTING.md        # 贡献指南
├── LICENSE                # 许可证
└── ARCHITECTURE_DESIGN.md # 架构设计文档
```

## 📝 代码规范

### Shell 脚本规范

1. **文件头部**

   ```bash
   #!/usr/bin/env bash
   # podsenv-command: 命令描述
   # Usage: podsenv command [options] [arguments]
   
   set -euo pipefail
   ```

2. **变量命名**

   ```bash
   # 全局变量使用大写
   PODSENV_ROOT="${PODSENV_ROOT:-$HOME/.podsenv}"
   
   # 局部变量使用小写
   local version="$1"
   local install_dir="$PODSENV_ROOT/versions/$version"
   ```

3. **函数定义**

   ```bash
   # 函数名使用下划线分隔
   function podsenv_install_version() {
       local version="$1"
       # 函数实现
   }
   ```

4. **错误处理**

   ```bash
   # 使用统一的错误处理函数
   if [[ ! -d "$install_dir" ]]; then
       podsenv_error_version_not_found "$version"
       return 1
   fi
   ```

5. **注释规范**

   ```bash
   # 单行注释说明代码用途
   
   # 多行注释用于复杂逻辑说明
   # 这里处理版本检测的复杂逻辑
   # 包括向上查找和继承机制
   ```

### 代码质量检查

使用 [ShellCheck](https://www.shellcheck.net/) 检查代码质量：

```bash
# 安装 ShellCheck
brew install shellcheck  # macOS
sudo apt install shellcheck  # Ubuntu

# 检查单个文件
shellcheck bin/podsenv

# 检查所有脚本
find . -name "*.sh" -o -name "podsenv*" | grep -v test | xargs shellcheck
```

## 🔄 提交流程

### 分支策略

- `main` - 主分支，包含稳定代码
- `develop` - 开发分支，包含最新功能
- `feature/功能名` - 功能分支
- `bugfix/问题描述` - 修复分支
- `hotfix/紧急修复` - 热修复分支

### 提交步骤

1. **创建功能分支**

   ```bash
   git checkout -b feature/auto-version-switch
   ```

2. **进行开发**

   ```bash
   # 编写代码
   # 运行测试
   # 更新文档
   ```

3. **提交更改**

   ```bash
   git add .
   git commit -m "feat: 添加自动版本切换功能"
   ```

4. **推送分支**

   ```bash
   git push origin feature/auto-version-switch
   ```

5. **创建 Pull Request**

   在 GitHub 上创建 PR，详细描述你的更改。

### 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 格式：

```
<类型>[可选的作用域]: <描述>

[可选的正文]

[可选的脚注]
```

**类型**：
- `feat`: 新功能
- `fix`: 修复
- `docs`: 文档
- `style`: 格式
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建过程或辅助工具的变动

**示例**：
```
feat(plugin): 添加插件系统支持

- 实现插件加载机制
- 添加钩子系统
- 支持插件配置管理

Closes #123
```

## 🧪 测试指南

### 运行测试

```bash
# 运行所有测试
./test/run_tests.sh

# 运行特定测试
./test/test_install.sh

# 运行测试并显示详细输出
PODSENV_TEST_VERBOSE=1 ./test/run_tests.sh
```

### 编写测试

1. **测试文件命名**

   ```
   test/test_<功能名>.sh
   ```

2. **测试函数命名**

   ```bash
   function test_install_specific_version() {
       # 测试实现
   }
   ```

3. **测试结构**

   ```bash
   #!/usr/bin/env bash
   
   source "$(dirname "$0")/test_helper.sh"
   
   function test_feature() {
       # 准备测试环境
       setup_test_env
       
       # 执行测试
       run podsenv install 1.15.2
       
       # 验证结果
       assert_success
       assert_output_contains "Successfully installed"
       
       # 清理
       cleanup_test_env
   }
   
   # 运行测试
   run_tests
   ```

### 测试覆盖率

确保新功能有适当的测试覆盖：

- 正常情况测试
- 边界情况测试
- 错误情况测试
- 集成测试

## 📚 文档编写

### 文档类型

1. **README.md** - 项目概述和快速开始
2. **命令帮助** - 内置帮助系统
3. **架构文档** - 技术设计文档
4. **API 文档** - 插件开发文档

### 文档规范

1. **使用中文**
2. **清晰的标题层次**
3. **代码示例**
4. **截图说明**（如需要）
5. **链接检查**

### 更新文档

当你添加新功能时，请确保更新：

- README.md 中的功能列表
- 相关命令的帮助信息
- CHANGELOG.md 中的更改记录
- 必要时更新架构文档

## 🧩 插件开发

### 插件结构

```
my-plugin/
├── init.sh              # 插件初始化
├── hooks/               # 钩子脚本
│   ├── after_install.sh
│   └── before_uninstall.sh
├── README.md           # 插件文档
└── config/             # 配置目录
```

### 插件开发指南

1. **遵循命名约定**
2. **提供完整文档**
3. **处理错误情况**
4. **测试插件功能**
5. **考虑兼容性**

详细信息请参考插件开发文档。

## 🐛 问题报告

### 报告 Bug

在 [GitHub Issues](https://github.com/mohuwamg/podsenv/issues) 创建新问题，包含：

1. **问题描述** - 清晰描述问题
2. **重现步骤** - 详细的重现步骤
3. **期望行为** - 你期望的正确行为
4. **实际行为** - 实际发生的情况
5. **环境信息** - 操作系统、Shell 版本等
6. **错误日志** - 相关的错误输出

### 问题模板

```markdown
## 问题描述
简要描述遇到的问题。

## 重现步骤
1. 执行 `podsenv install 1.15.2`
2. 运行 `podsenv global 1.15.2`
3. 查看错误信息

## 期望行为
应该成功设置全局版本。

## 实际行为
出现错误：...

## 环境信息
- OS: macOS 12.0
- Shell: zsh 5.8
- podsenv version: 2.0.0

## 错误日志
```
错误输出内容
```
```

## 💡 功能请求

### 提出新功能

1. **搜索现有 Issues** - 确保功能未被提出
2. **详细描述功能** - 说明功能的用途和价值
3. **提供使用场景** - 具体的使用示例
4. **考虑实现方案** - 如果有想法可以分享

### 功能请求模板

```markdown
## 功能描述
简要描述建议的功能。

## 使用场景
描述什么情况下需要这个功能。

## 详细说明
详细描述功能的工作方式。

## 可能的实现
如果有实现想法，请分享。

## 替代方案
是否考虑过其他解决方案？
```

## 🎯 贡献优先级

我们特别欢迎以下类型的贡献：

### 高优先级
- 🐛 Bug 修复
- 📝 文档改进
- 🧪 测试覆盖率提升
- 🔒 安全问题修复

### 中优先级
- ✨ 新功能实现
- ⚡ 性能优化
- 🧩 插件开发
- 🎨 用户体验改进

### 低优先级
- 🔧 代码重构
- 📦 依赖更新
- 🏗️ 架构优化

## 📞 联系方式

如果你有任何问题或需要帮助：

- 📧 Email: maintainer@example.com
- 💬 GitHub Discussions: [项目讨论区](https://github.com/mohuwamg/podsenv/discussions)
- 🐛 Issues: [问题跟踪](https://github.com/mohuwamg/podsenv/issues)

## 🙏 致谢

感谢所有为 podsenv 项目做出贡献的开发者！你们的努力让这个项目变得更好。

---

**记住**：每一个贡献都很重要，无论大小。我们重视每一位贡献者的努力！