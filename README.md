# podsenv: CocoaPods 版本管理工具

podsenv 是一个灵感来源于 `pyenv` 的 CocoaPods 版本管理工具，它允许你在同一台机器上轻松安装、切换和管理多个不同版本的 CocoaPods。

## 特性

*   **多版本支持：** 在一台机器上安装任意数量的 CocoaPods 版本。
*   **无缝切换：** 轻松在全局、项目局部或当前 shell 会话中切换 CocoaPods 版本。
*   **轻量级：** 基于 Python 和 Shell 脚本实现，不依赖复杂的环境。
*   **Shim 机制：** 通过 shim 拦截 `pod` 命令，自动选择正确的 CocoaPods 版本。

## 安装

1.  **克隆仓库 (假设你已经将 `podsenv` 脚本和 `install.sh` 放在当前目录)：**

    ```bash
    # 如果你还没有这些文件，请手动创建或从源代码获取
    # 例如，你可以将 podsenv 脚本保存为 `podsenv`，将安装脚本保存为 `install.sh`
    ```

2.  **运行安装脚本：**

    ```bash
    bash install.sh
    ```

3.  **配置你的 Shell 环境：**

    安装脚本会提示你将以下行添加到你的 shell 配置文件中（例如 `~/.bashrc`, `~/.zshrc`）：

    ```bash
    # podsenv configuration
    export PATH="$HOME/.podsenv/bin:$HOME/.podsenv/shims:$PATH"
    eval "$(podsenv init -)"
    ```

    添加后，运行 `source ~/.bashrc` (或你的 shell 配置文件) 来应用更改。

    **注意：** `podsenv` 依赖于 `gem` 命令来安装 CocoaPods。如果你的系统上没有安装 Ruby 和 `gem`，你可能需要先安装它们。在 Ubuntu/Debian 系统上，你可以使用 `sudo apt install ruby-full build-essential`。

## 使用

### `podsenv install <version>`

安装指定版本的 CocoaPods。例如：

```bash
podsenv install 1.11.3
podsenv install 1.10.0
```

### `podsenv uninstall <version>`

卸载指定版本的 CocoaPods。例如：

```bash
podsenv uninstall 1.10.0
```

### `podsenv global <version>`

设置全局 CocoaPods 版本。这将是默认使用的版本，除非被局部或 shell 版本覆盖。例如：

```bash
podsenv global 1.11.3
```

### `podsenv local <version>`

设置当前目录的 CocoaPods 版本。这会在当前目录创建一个 `.podsenv-version` 文件，该版本仅在该目录及其子目录中生效。例如：

```bash
podsenv local 1.10.0
```

### `podsenv shell <version>`

设置当前 shell 会话的 CocoaPods 版本。这会设置一个环境变量，优先级最高。例如：

```bash
podsenv shell 1.11.3
```

### `podsenv versions`

列出所有已安装的 CocoaPods 版本，并标记当前激活的版本。例如：

```bash
podsenv versions
```

输出示例：

```
Installed CocoaPods versions:
  1.10.0
* 1.11.3 (set by global (~/.podsenv/version))
```

### `podsenv rehash`

更新 `podsenv` shims。在安装或卸载 CocoaPods 版本后，你需要运行此命令以确保 `pod` 命令能够正确地找到并执行对应版本的 CocoaPods。

```bash
podsenv rehash
```

## 工作原理

podsenv 的工作原理与 pyenv 类似，它通过在你的 `PATH` 环境变量中插入一个 `shims` 目录来拦截对 `pod` 命令的调用。当执行 `pod` 命令时，`shim` 会根据以下优先级确定要使用的 CocoaPods 版本：

1.  `PODSENV_VERSION` 环境变量（通过 `podsenv shell` 设置）。
2.  当前目录（或父目录）中的 `.podsenv-version` 文件（通过 `podsenv local` 设置）。
3.  通过 `podsenv global` 设置的全局版本（存储在 `~/.podsenv/version` 文件中）。

确定版本后，`shim` 会将命令委托给该特定版本的实际 `pod` 可执行文件。每个 CocoaPods 版本都安装在独立的 `GEM_HOME` 目录下，确保了版本之间的隔离。

