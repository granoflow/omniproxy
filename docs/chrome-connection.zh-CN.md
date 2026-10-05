# 安装 OmniProxy CLI 并连接 Chrome 内置 AI

这是独立运行的 CLI 预览版，不需要安装 OmniProxy 桌面应用。OmniProxy 实现不开源。本仓库只提供下载、安装脚本和用户文档。

## 使用条件与许可

- 首个下载包仅面向 Apple Silicon Mac。构建目标为 macOS 14 或更新版本；本轮验证使用 macOS 27，未验证所有旧系统。
- AI Power Translator 必须是支持本机工具连接 v2 的版本。扩展新版本尚未上架时，需要已取得的开发版；本文不提供不存在的商店安装链接。
- Chrome 的内置 AI 模型必须实际可用。若扩展没有显示“本机工具连接”，请先检查内置模型状态。OmniProxy 不会替你安装 Chrome 或下载 Chrome 模型。
- 个人独立使用免费；代表企业使用须购买企业许可，每个企业法人 68 美元一次性支付。授权主版本永久使用，同主版本已发布的更新免费，后续主版本升级另外收费。不升级不影响继续使用旧授权版本。购买联系 granoflow@anz.tv。

下载、安装或使用前请阅读[最终用户许可协议](../EULA.zh-CN.md)。安装脚本会要求明确确认。软件费用不包含第三方模型/API 费用。

## 1. 安装

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

打开 AI Power Translator 设置，进入“通用设置”，找到 Chrome 内置 AI 的“本机工具连接”。默认 OmniProxy 地址为 `127.0.0.1:56787`；确认启用，再点击“测试连接”。

连接由扩展主动发起。服务尚未启动时，扩展显示“未启动”，保留启用选择，并每分钟尝试恢复。关闭或删除工具项后，扩展停止该项重试。重新启动 OmniProxy 后可以等待自动恢复，或点击测试连接。

如果默认项此前被删除，手动新增名称 OmniProxy、地址 `127.0.0.1:56787` 的工具项。名称只是显示名称，不证明对端身份。

修改端口前先停止 CLI，例如：

```sh
omniproxy config set chrome.bridge.port 56790
omniproxy service start
```

同时把扩展中的地址改为 `127.0.0.1:56790`。只使用自己信任的本机服务地址；此工具连接协议没有密钥配对，不能因为地址是 localhost 就认定服务身份可信。

## 4. 核实可用性

工具连接的标准健康端点仅用于核实监听服务，不能证明模型已经准备好：

```sh
curl -i http://127.0.0.1:56787/browser-ai/v2/health
```

预期 HTTP 204，响应头包含 `x-apt-browser-ai: v2`。没有启动服务、端口不同或接入关闭时，不会得到这个响应。

模型是否可调用，应在同一已认证网关的 `/v1/models` 中核实 `chrome-nano`，并实际执行文本请求。网关地址和鉴权配置使用 `omniproxy gateway --help`、`omniproxy gateway auth --help` 查看，不能用 Chrome 工具端口替代。不要把 API key 粘贴到截图、GitHub Issue 或公开命令日志。

Chrome 路径支持文本聊天、流式输出和取消；不承诺图像、工具调用或任意生成参数。原生模型不可用时，不会因健康检查成功就变为可用。当前发布的协议 fixture 验证不是原生 Nano 生成证明。

## 5. 停止与关闭接入

先停止后台服务，再保存关闭选择：

```sh
omniproxy service stop
omniproxy config set chrome.bridge.enabled false
```

下次启动不会开启 Chrome 接入。不想让扩展继续探测时，同时在扩展里关闭该工具项。

不要同时启动 OmniProxy 桌面版和 standalone CLI 来占用同一网关或资料目录。发生端口冲突时，先查清已有服务，不要强制结束不认识的进程。

## 常见问题

| 现象 | 检查与操作 |
| --- | --- |
| `omniproxy: command not found` | 把 `~/.local/bin` 加入 PATH，或直接运行 `~/.local/bin/omniproxy`。 |
| 没有工具连接区域 | 检查扩展版本和 Chrome 内置模型资格；区域按真实模型状态显示。 |
| 一直显示“未启动” | 使用 `omniproxy service status` 检查后台服务是否运行、接入开关是否为 true、端口是否一致。保存配置后重启服务。 |
| 已连接但没有 `chrome-nano` | 连接成功不代表原生模型可用；检查 Chrome 模型状态及能力报告。 |
| 调用参数不支持 | 按当前文本聊天能力发送请求，查看返回错误，不要默认所有 OpenAI 参数都被支持。 |
| 下载或校验失败 | 保留已有安装，确认网络后重新执行安装脚本。不要跳过校验。 |

## 升级与卸载

后续版本按各自 Release 的安装命令安装；企业升级到新主版本前需取得对应许可。不同意新版本的许可时可继续使用仍获授权的旧版本。

先执行 `omniproxy service stop` 和 `omniproxy service disable`，再删除安装程序管理的命令链接和程序目录：

```sh
rm "$HOME/.local/bin/omniproxy"
rm -rf "$HOME/.local/share/omniproxy-cli"
```

这些命令不删除模型、配置和运行数据。自定义安装位置按实际路径卸载。若需要删除运行数据，先确认实际数据目录并备份，不将程序目录误当数据目录。
