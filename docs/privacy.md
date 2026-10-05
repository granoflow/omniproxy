# Preview privacy notes

The installer downloads the selected release from GitHub. GitHub receives normal request metadata under its own privacy policy. The installer does not collect telemetry, upload local files, download models, install a background service or start the gateway.

The optional Chrome AI bridge listens on loopback. AI Power Translator initiates the connection and executes supported text requests in Chrome when the native model is available. The bridge protocol does not authenticate the local consumer with a pairing key. Enable only a local service you trust.

OmniProxy can also call third-party models you configure. Request contents then go to those providers according to your configuration and their terms. The gateway may keep local request logs/ledger records according to its settings. Neither this preview nor the words “local gateway” guarantee that every configured route stays on your device.

Do not publish credentials, private prompts or request logs in GitHub Issues. Licensing contact: granoflow@anz.tv. Software publisher: A New Zero Innovations Limited, using the Granoflow brand.
