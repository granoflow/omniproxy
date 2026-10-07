# OmniProxy CLI

Personal AI gateway — closed-source CLI preview from Granoflow.

This repository hosts user documentation, installation scripts and binary releases. The OmniProxy implementation source is not published here.

- [Download the latest preview](https://github.com/granoflow/omniproxy/releases/tag/v0.1.0-preview.2)
- [安装与 Chrome 工具连接指南](docs/chrome-connection.zh-CN.md)
- [End User License Agreement / 最终用户许可协议](EULA.zh-CN.md)

## License

Personal use is free, including independent freelance use. Use on behalf of a company requires an enterprise license: **USD 68, one-time payment per legal entity**. The licensed major version may be used permanently; released updates in that major version are included. Later major-version upgrades require a separate purchase. Upgrading is optional and does not revoke your previous license.

For enterprise purchasing and authorization, contact **granoflow@anz.tv** before enterprise use. The price excludes any applicable tax and third-party model/API fees. Purchase confirmation identifies the licensed legal entity and major version. No subscription or automatic renewal is imposed.

Read the EULA before downloading, installing or using the software. The installer asks you to confirm acceptance. The Chinese EULA governs; this README is a summary.

## Install

Preview 2 provides Apple Silicon macOS and Linux x86_64 GNU archives. See the [installation guide](docs/chrome-connection.zh-CN.md) for Linux. Windows and Intel Mac binaries are not provided.

The following macOS installer is pinned to **preview 1**; preview 2 does not include an installer script. Preview 1 remains compatible with the current extension’s Chrome AI connection.

```sh
curl -fL --proto '=https' --tlsv1.2 https://github.com/granoflow/omniproxy/releases/download/v0.1.0-preview.1/install.sh -o /tmp/omniproxy-install.sh
sh /tmp/omniproxy-install.sh
```

The installer checks the fixed release checksum and code signatures. It installs the CLI and runtime files in `~/.local/share/omniproxy-cli`, and a launcher link in `~/.local/bin`. It does not install a background service, change shell configuration, download models or start the gateway.

If `~/.local/bin` is not in your PATH, use:

```sh
export PATH="$HOME/.local/bin:$PATH"
omniproxy --version
```

## Connect Chrome built-in AI

Use an AI Power Translator extension version that supports browser AI bridge v2. The extension needs a real, available Chrome built-in AI model; merely installing Chrome is insufficient.

Before starting the gateway:

```sh
omniproxy config set chrome.bridge.enabled true
omniproxy service start
```

Use `omniproxy service status` to check the current-user background service. In AI Power Translator settings, find **General settings → Share Chrome built-in AI**, enable OmniProxy and confirm the port. The connection starts automatically. Default address: `127.0.0.1:56787`. The extension initiates the local connection. When its built-in model is available, OmniProxy exposes `chrome-nano` to its authenticated model gateway.

Configuration changes in this preview take effect on the next service startup. Run `omniproxy service stop` before changing settings, then `omniproxy service start` to apply them. To disable access:

```sh
omniproxy service stop
omniproxy config set chrome.bridge.enabled false
```

Do not run the desktop app and standalone CLI simultaneously against the same gateway/state. Public preview compatibility was tested with Chrome 154 and AI Power Translator 1.0.8 on October 7, 2026. Model availability still depends on the local Chrome installation. Published previews do not support remote model discovery for hiding provider advertisements. See the guide for verification and troubleshooting.

## Uninstall

Run `omniproxy service stop` and `omniproxy service disable` first, then remove its installer-managed files:

```sh
rm "$HOME/.local/bin/omniproxy"
rm -rf "$HOME/.local/share/omniproxy-cli"
```

The software's model/data storage is separate and is not removed by these commands. If you installed to a custom location, use that location instead.

## Support and privacy

Use GitHub Issues for reproducible bugs; never include API keys, credentials or private prompts. Send licensing or private questions to granoflow@anz.tv.

OmniProxy processes requests through the model routes you select and may retain local logs according to its configuration. Third-party providers have their own terms and fees. [Preview privacy notes](docs/privacy.md) explain the installation and Chrome bridge boundaries.
