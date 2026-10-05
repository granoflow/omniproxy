#!/bin/sh
set -eu

VERSION='v0.1.0-preview.1'
SHA256='459b3b45c10ff164bd591e4c8237a183fb78ce04e0719910c2430dfcc716b60b'
BASE="https://github.com/granoflow/omniproxy/releases/download/$VERSION"
EULA='https://github.com/granoflow/omniproxy/blob/main/EULA.zh-CN.md'
INSTALL_DIR=${OMNIPROXY_INSTALL_DIR:-"$HOME/.local/share/omniproxy-cli"}
BIN_DIR=${OMNIPROXY_BIN_DIR:-"$HOME/.local/bin"}
die() { printf '%s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] || die 'This preview requires an Apple Silicon Mac.'
os_major=$(sw_vers -productVersion | cut -d . -f 1)
[ "$os_major" -ge 14 ] || die 'This preview requires macOS 14 or later.'
case "$INSTALL_DIR:$BIN_DIR" in /*:/*) ;; *) die 'Installation paths must be absolute.' ;; esac
case "$INSTALL_DIR" in /|/usr|/usr/local|"$HOME"|"$BIN_DIR") die 'Choose a dedicated CLI installation directory.' ;; esac
accepted=false
case "${1:-}" in
  --accept-license) accepted=true; shift ;;
  '') ;;
  *) die 'Usage: sh install.sh [--accept-license]' ;;
esac
[ "$#" -eq 0 ] || die 'Unexpected arguments.'
printf '%s\n' "OmniProxy CLI $VERSION — proprietary preview." 'Personal use: free. Enterprise: USD 68 per legal entity for the licensed major version.' "Read the EULA: $EULA"
if [ "$accepted" = false ]; then
  [ -t 0 ] || die 'Read the EULA and pass --accept-license for an unattended installation.'
  printf 'Accept the EULA and install? [y/N] '
  read -r answer
  case "$answer" in y|Y|yes|YES) ;; *) die 'Installation cancelled.' ;; esac
fi
[ ! -L "$INSTALL_DIR" ] || die 'The installation directory must not be a symlink.'
if [ -e "$INSTALL_DIR" ]; then
  [ -f "$INSTALL_DIR/.omniproxy-installer" ] || die 'Existing directory is not managed by this installer.'
  [ "$(cat "$INSTALL_DIR/.omniproxy-installer")" = 'granoflow/omniproxy' ] || die 'Unknown installation owner.'
fi
if [ -e "$BIN_DIR/omniproxy" ] || [ -L "$BIN_DIR/omniproxy" ]; then
  [ -L "$BIN_DIR/omniproxy" ] && [ "$(readlink "$BIN_DIR/omniproxy")" = "$INSTALL_DIR/omniproxy" ] || die 'An unrelated omniproxy launcher already exists.'
fi
parent=$(dirname "$INSTALL_DIR")
mkdir -p "$parent" "$BIN_DIR"
tmp=$(mktemp -d "$parent/.omniproxy-install.XXXXXX")
backup="$tmp/previous"
committed=false
cleanup() {
  status=$?
  if [ "$committed" = false ] && [ -d "$backup" ]; then
    [ ! -e "$INSTALL_DIR" ] || rm -rf "$INSTALL_DIR"
    mv "$backup" "$INSTALL_DIR"
  fi
  rm -rf "$tmp"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
archive="$tmp/cli.zip"
curl -fL --proto '=https' --tlsv1.2 "$BASE/omniproxy-cli-$VERSION-macos-arm64.zip" -o "$archive"
actual=$(shasum -a 256 "$archive" | awk '{print $1}')
[ "$actual" = "$SHA256" ] || die 'Download checksum mismatch; installation stopped.'
unzip -q "$archive" -d "$tmp/extracted"
candidate="$tmp/extracted/omniproxy-cli"
for binary in "$candidate/omniproxy" "$candidate/runtime/facedetect-cli" "$candidate/runtime/voicedetect-cli" "$candidate/runtime/libapplefoundationmodels.dylib"; do
  codesign --verify --strict "$binary"
  codesign -dv --verbose=2 "$binary" 2>&1 | grep -q '^TeamIdentifier=LC7B9U9W53$' || die 'Unexpected publisher signature.'
done
spctl --assess --type install "$candidate/omniproxy" || die 'macOS could not verify notarization; installation stopped.'
"$candidate/omniproxy" --version | grep -q '^Distribution: standalone_cli$' || die 'Unexpected CLI distribution.'
printf '%s\n' 'granoflow/omniproxy' > "$candidate/.omniproxy-installer"
[ ! -e "$INSTALL_DIR" ] || mv "$INSTALL_DIR" "$backup"
mv "$candidate" "$INSTALL_DIR"
ln -s "$INSTALL_DIR/omniproxy" "$tmp/launcher"
mv -f "$tmp/launcher" "$BIN_DIR/omniproxy"
committed=true
printf '%s\n' "Installed: $BIN_DIR/omniproxy" 'No background service was started. Runtime data was preserved.'
