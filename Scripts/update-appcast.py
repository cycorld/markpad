#!/usr/bin/env python3
import argparse
import base64
from datetime import datetime, timezone
import os
import re
import sys
from cryptography.hazmat.primitives.asymmetric import ed25519


def main():
    parser = argparse.ArgumentParser(description="Sign release zip and update appcast.xml for Sparkle")
    parser.add_argument("--zip", required=True, help="Path to release zip file")
    parser.add_argument("--version", required=True, help="Short version string (e.g. 0.5.0)")
    parser.add_argument("--build", required=True, help="Bundle build number (e.g. 9)")
    parser.add_argument("--appcast", default="appcast.xml", help="Path to appcast.xml")
    parser.add_argument("--key", help="Base64 encoded Ed25519 private key")
    parser.add_argument("--key-file", help="Path to Ed25519 private key file")
    args = parser.parse_args()

    # Determine private key
    key_b64 = args.key or os.environ.get("SPARKLE_PRIVATE_KEY")
    if not key_b64:
        key_file = args.key_file or os.path.expanduser("~/.config/markpad/sparkle_ed25519.key")
        if os.path.exists(key_file):
            with open(key_file, "r") as f:
                key_b64 = f.read().strip()
        else:
            sys.exit(f"Error: No Ed25519 private key found. Set SPARKLE_PRIVATE_KEY or provide --key/--key-file.")

    priv_bytes = base64.b64decode(key_b64)
    priv = ed25519.Ed25519PrivateKey.from_private_bytes(priv_bytes)

    # Read and sign zip
    with open(args.zip, "rb") as f:
        zip_data = f.read()

    length = len(zip_data)
    sig = priv.sign(zip_data)
    sig_b64 = base64.b64encode(sig).decode("ascii")

    # Format pubDate in RFC 822 format
    now_rfc822 = datetime.now(timezone.utc).strftime("%a, %d %b %Y %H:%M:%S +0000")
    download_url = f"https://github.com/cycorld/markpad/releases/download/v{args.version}/MarkPad-v{args.version}.zip"
    release_notes_url = f"https://github.com/cycorld/markpad/releases/tag/v{args.version}"

    item_xml = f"""        <item>
            <title>Version {args.version}</title>
            <sparkle:releaseNotesLink>{release_notes_url}</sparkle:releaseNotesLink>
            <pubDate>{now_rfc822}</pubDate>
            <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
            <enclosure url="{download_url}"
                       sparkle:version="{args.build}"
                       sparkle:shortVersionString="{args.version}"
                       sparkle:edSignature="{sig_b64}"
                       length="{length}"
                       type="application/octet-stream" />
        </item>"""

    with open(args.appcast, "r", encoding="utf-8") as f:
        content = f.read()

    # Insert under <channel>
    if "<item>" in content:
        # Insert before first existing item
        new_content = re.sub(r"(\s*<item>)", f"\n{item_xml}\\1", content, count=1)
    else:
        # Insert before </channel>
        new_content = content.replace("</channel>", f"{item_xml}\n    </channel>")

    with open(args.appcast, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"✅ Successfully updated {args.appcast} with v{args.version} (build {args.build})")
    print(f"   Signature: {sig_b64}")
    print(f"   Size: {length} bytes")


if __name__ == "__main__":
    main()
