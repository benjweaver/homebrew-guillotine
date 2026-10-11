#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Verify the release asset against its published checksum before updating the cask.
set -euo pipefail
cd "$(dirname "$0")/.."
tag=${1:-$(gh release view --repo benjweaver/guillotine --json tagName --jq .tagName)}
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Expected a stable vX.Y.Z release tag' >&2; exit 1; }
version=${tag#v}
asset="Guillotine-$version-macOS.zip"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
gh release download "$tag" --repo benjweaver/guillotine --pattern "$asset" --pattern SHA256SUMS.txt --dir "$tmp"
python3 - "$version" "$tmp" <<'PY'
import hashlib,pathlib,re,sys
version,temporary=sys.argv[1:]
folder=pathlib.Path(temporary); name=f'Guillotine-{version}-macOS.zip'
entries=[line.split() for line in (folder/'SHA256SUMS.txt').read_text().splitlines()]
checksums=[parts[0] for parts in entries if len(parts)==2 and parts[1]==name]
if len(checksums)!=1 or not re.fullmatch(r'[0-9a-f]{64}',checksums[0]):
    raise SystemExit('Missing or invalid release checksum')
actual=hashlib.sha256((folder/name).read_bytes()).hexdigest()
if actual!=checksums[0]: raise SystemExit('Release checksum mismatch')
path=pathlib.Path('Casks/guillotine.rb');text=path.read_text()
text,count=re.subn(r'^  version ".*"$',f'  version "{version}"',text,flags=re.M)
if count!=1: raise SystemExit('Expected exactly one cask version')
text,count=re.subn(r'^  sha256 ".*"$',f'  sha256 "{actual}"',text,flags=re.M)
if count!=1: raise SystemExit('Expected exactly one cask checksum')
path.write_text(text)
print(f'guillotine {version} {actual}')
PY
