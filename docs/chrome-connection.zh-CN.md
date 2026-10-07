# 安装 OmniProxy CLI 并连接 Chrome 内置 AI

这是独立运行的 CLI 预览版，不需要安装 OmniProxy 桌面应用。OmniProxy 实现不开源。本仓库只提供下载、安装脚本和用户文档。

## 使用条件与许可

- [preview 2](https://github.com/granoflow/omniproxy/releases/tag/v0.1.0-preview.2) 提供 Apple Silicon macOS 和 Linux x86_64 GNU 包；没有 Windows 或 Intel Mac 包。macOS 构建目标为 14 或更新版本；本轮使用 macOS 27，未验证所有旧系统。
- AI Power Translator 必须是支持本机工具连接 v2 的版本。扩展新版本尚未上架时，需要已取得的开发版；本文不提供不存在的商店安装链接。
- Chrome 的内置 AI 模型必须实际可用。若“分享Chrome内置AI”不可用，请先检查内置模型状态。OmniProxy 不会替你安装 Chrome 或下载 Chrome 模型。
- 个人独立使用免费；代表企业使用须购买企业许可，每个企业法人 68 美元一次性支付。授权主版本永久使用，同主版本已发布的更新免费，后续主版本升级另外收费。不升级不影响继续使用旧授权版本。购买联系 granoflow@anz.tv。

下载、安装或使用前请阅读[最终用户许可协议](../EULA.zh-CN.md)。安装脚本会要求明确确认。软件费用不包含第三方模型/API 费用。

## 1. 安装

### macOS：安装 preview 1

以下脚本固定安装 **preview 1**，该版本已验证可与当前扩展连接。preview 2 没有安装脚本，不能把下面 URL 的版本号直接改成 preview 2。

在终端执行：

```sh
curl -fL --proto '=https' --tlsv1.2 https://github.com/granoflow/omniproxy/releases/download/v0.1.0-preview.1/install.sh -o /tmp/omniproxy-install.sh
sh /tmp/omniproxy-install.sh
```

先下载再执行，可以先查看脚本。安装时确认许可协议；不同意时退出，不安装。脚本只下载固定预览版本，检查 SHA-256 和代码签名，不要求 sudo，不修改 shell 配置，不安装后台服务，不自动启动模型或网关。

默认安装位置为 `~/.local/share/omniproxy-cli`，命令链接为 `~/.local/bin/omniproxy`。若终端提示找不到命令：

```sh
export PATH="$HOME/.local/bin:$PATH"
omniproxy --version
```

想安装到自定义位置，可设置 `OMNIPROXY_INSTALL_DIR` 和 `OMNIPROXY_BIN_DIR`。升级前停止正在运行的 CLI；安装成功后，脚本回收此前由同一脚本管理的旧程序包，不删除软件运行数据。

### Linux：下载 preview 2

先阅读并接受上述许可。在 Linux x86_64 环境中，新建一个空目录，在其中执行：

```sh
curl -fLO https://github.com/granoflow/omniproxy/releases/download/v0.1.0-preview.2/omniproxy-cli-v0.1.0-preview.2-linux-x86_64-gnu.tar.gz
curl -fLO https://github.com/granoflow/omniproxy/releases/download/v0.1.0-preview.2/SHA256SUMS-linux-x86_64-gnu.txt
sha256sum -c SHA256SUMS-linux-x86_64-gnu.txt
tar -xzf omniproxy-cli-v0.1.0-preview.2-linux-x86_64-gnu.tar.gz
./omniproxy-cli/omniproxy --version
```

保留解压出的完整目录，不要只移动 `omniproxy` 文件。以下命令中的 `omniproxy` 可替换为该程序的绝对路径。

正常后台服务需要可用的用户级 systemd；网关凭据需要当前用户的 D-Bus Secret Service 密钥库。最小 Docker 镜像通常没有这两项，不能把容器中的前台 Runtime 联调当作 Linux 桌面安装验收。本轮 Docker 联调使用原生 GNOME Secret Service 的会话集合，未验证重启后的密钥持久化。

## 2. 开启 Chrome 接入并启动服务

首先保存接入配置，再启动当前用户的后台服务：

```sh
omniproxy config get chrome.bridge.enabled
omniproxy config set chrome.bridge.enabled true
omniproxy service start
```

接入默认关闭。`config set` 保存你的选择；此预览版的配置在下一次服务启动时生效。正在运行时先执行 `omniproxy service stop`，再执行 `omniproxy service start`。端口配置同样需要重启。

执行 `omniproxy service status` 检查服务状态。启动命令会在当前用户下注册并启动后台服务；登录自动启动由 `omniproxy service enable` / `omniproxy service disable` 单独控制。Chrome 接入监听默认在本机 `127.0.0.1:56787`。它与模型 API 的网关端口不同，不要把工具连接地址当作模型 API 地址。

## 3. 在扩展设置中连接

打开 AI Power Translator 设置，进入“通用设置”，找到“分享Chrome内置AI”。打开 OmniProxy 开关，确认端口为 `56787`，扩展会自动连接，无需点击测试按钮。

连接由扩展主动发起。若 OmniProxy 尚未启动，先启动服务，再重新打开或聚焦设置页；也可以关闭并重新打开 OmniProxy 开关触发重连。当前界面只有一个 OmniProxy 连接，不需要新增或删除工具项。

修改端口前先停止 CLI，例如：

```sh
omniproxy service stop
omniproxy config set chrome.bridge.port 56790
omniproxy service start
```

同时把扩展中的端口改为 `56790`。只使用自己信任的本机服务地址；此工具连接协议没有密钥配对，不能因为地址是 localhost 就认定服务身份可信。

## 4. 核实可用性

工具连接的标准健康端点仅用于核实监听服务，不能证明模型已经准备好：

```sh
curl -i http://127.0.0.1:56787/browser-ai/v2/health
```

预期 HTTP 204，响应头包含 `x-apt-browser-ai: v2`。没有启动服务、端口不同或接入关闭时，不会得到这个响应。

模型是否可调用，应在同一已认证网关的 `/v1/models` 中核实 `chrome-nano`，并实际执行文本请求。网关地址和鉴权配置使用 `omniproxy gateway --help`、`omniproxy gateway auth --help` 查看，不能用 Chrome 工具端口替代。不要把 API key 粘贴到截图、GitHub Issue 或公开命令日志。

Chrome 路径支持文本聊天、流式输出和取消；不承诺图像、工具调用或任意生成参数。原生模型不可用时，不会因健康检查成功就变为可用。下表区分连接验证与实际模型调用，不以健康检查代替推理验证。

## 5. 停止与关闭接入

先停止后台服务，再保存关闭选择：

```sh
omniproxy service stop
omniproxy config set chrome.bridge.enabled false
```

下次启动不会开启 Chrome 接入。不想让扩展继续探测时，同时在扩展里关闭 OmniProxy 开关。

不要同时启动 OmniProxy 桌面版和 standalone CLI 来占用同一网关或资料目录。发生端口冲突时，先查清已有服务，不要强制结束不认识的进程。

## 常见问题

| 现象 | 检查与操作 |
| --- | --- |
| `omniproxy: command not found` | 把 `~/.local/bin` 加入 PATH，或直接运行 `~/.local/bin/omniproxy`。 |
| 分享开关不可用 | 检查扩展版本和 Chrome 内置模型资格。 |
| 无法连接 | 使用 `omniproxy service status` 检查后台服务是否运行、接入开关是否为 true、端口是否一致。保存配置后重启服务。 |
| 已连接但没有 `chrome-nano` | 连接成功不代表原生模型可用；检查 Chrome 模型状态及能力报告。 |
| 启动时报 `xpcproxy` 状态错误 | preview 1 本轮出现启动瞬态误报。执行 `omniproxy service status`；只有状态为运行且健康检查成功时才继续连接。若未运行，保留错误日志排查。 |
| 网关返回 401 | 使用网关对应的密钥。预览版不支持重新显示既有密钥；生成新密钥会替换旧密钥，需要同步更新所有客户端。 |
| 调用参数不支持 | 按当前文本聊天能力发送请求，查看返回错误，不要默认所有 OpenAI 参数都被支持。 |
| 下载或校验失败 | 保留已有安装，确认网络后重新执行安装脚本。不要跳过校验。 |

## 已验证的预览版兼容性（2026-10-07）

使用实际发布包、Chrome 154 和最终 AI Power Translator 1.0.8 ZIP：

| 环境 | 实际结果 | 边界 |
| --- | --- | --- |
| macOS，preview 1 | 连接、关闭后重连、设置页重开、Chrome 原生模型调用通过 | 已安装程序与公开下载包一致；未重置已有网关密钥，未验证该网关的鉴权推理 |
| macOS，preview 2 | 连接、重连、设置页重开、Chrome 原生模型调用通过 | 从公开包直接启动 Runtime；未验证安装器或该网关的鉴权推理 |
| Ubuntu 24.04 Docker，preview 2 | 连接、鉴权网关非流式/流式调用、收到内容后取消、取消后再次调用均通过 | Linux x86_64 在 Apple Silicon 上模拟运行，Chrome 在 macOS；不是原生 Linux Chrome 或 systemd 服务验收 |

Docker 仅把端口映射到宿主机 `127.0.0.1`，再转发到容器内 Runtime 的回环监听；没有向局域网开放服务。

preview 1 和 preview 2 尚不支持远端模型家族发现。因此扩展可分享 Chrome AI，但不会根据这些预览版中的 Gemini/Qwen 来源隐藏相应广告。健康、连接和广告发现是不同能力。

## 升级与卸载

后续版本按各自 Release 的安装命令安装；企业升级到新主版本前需取得对应许可。不同意新版本的许可时可继续使用仍获授权的旧版本。

先执行 `omniproxy service stop` 和 `omniproxy service disable`，再删除安装程序管理的命令链接和程序目录：

```sh
rm "$HOME/.local/bin/omniproxy"
rm -rf "$HOME/.local/share/omniproxy-cli"
```

这些命令不删除模型、配置和运行数据。自定义安装位置按实际路径卸载。若需要删除运行数据，先确认实际数据目录并备份，不将程序目录误当数据目录。
