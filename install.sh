#!/usr/bin/env bash
set -euo pipefail

# RAMP (Reend's Awesome Modpack) — Linux Auto Scripto

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

#  Modworkshop mods
#  Format: "MOD_ID|TARGET"
MODWORKSHOP_MODS=(
    # "25629|mods"
    # "12345|mod_overrides"
)

#  Github mods
#  Format: "OWNER/REPO|TARGET"
GITHUB_MODS=(
    # "simon-wh/PAYDAY-2-BeardLib|mods"
    # "Luffyyy/BeardLib-Editor|mods"
)

REQUIRED_CMDS=(curl jq unzip)
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[ERROR] '$cmd' is required but not installed."
        exit 1
    fi
done

resolve_mws_url() {
    local api_json="$1"
    local dl_type
    dl_type=$(echo "$api_json" | jq -r '.download_type // empty')

    local url=""
    if [[ "$dl_type" == "link" ]]; then
        url=$(echo "$api_json" | jq -r '.download.url // empty')
    else
        url=$(echo "$api_json" | jq -r '.download.download_url // empty')
    fi
    echo "$url"
}

extract_archive() {
    local archive="$1"
    local dest="$2"

    case "$archive" in
        *.zip)    unzip -qo "$archive" -d "$dest" ;;
        *.tar.gz|*.tgz) tar -xzf "$archive" -C "$dest" ;;
        *.tar.bz2)      tar -xjf "$archive" -C "$dest" ;;
        *.rar)
            if command -v unrar &>/dev/null; then
                unrar x -o+ -idq "$archive" "$dest/"
            else
                echo "  [ERROR] .rar archive but 'unrar' is not installed. Skipping."
                return 1
            fi
            ;;
        *.7z)
            if command -v 7z &>/dev/null; then
                7z x -o"$dest" -y "$archive" >/dev/null
            else
                echo "  [ERROR] .7z archive but '7z' is not installed. Skipping."
                return 1
            fi
            ;;
        *)
            echo "  [ERROR] Unsupported archive format: $(basename "$archive")"
            return 1
            ;;
    esac
}

download_modworkshop() {
    local mod_id="$1"
    local target_dir="$2"

    echo "[ModWorkshop] Fetching mod $mod_id ..."
    local api_json
    api_json=$(curl -sfL "https://api.modworkshop.net/mods/$mod_id") || {
        echo "  [ERROR] API request failed for mod $mod_id. Skipping."
        return 1
    }

    local mod_name
    mod_name=$(echo "$api_json" | jq -r '.name // "Unknown"')

    local url
    url=$(resolve_mws_url "$api_json")
    if [[ -z "$url" ]]; then
        echo "  [ERROR] No download URL found for '$mod_name' ($mod_id). Skipping."
        return 1
    fi

    local filename
    filename=$(basename "${url%%\?*}")
    [[ "$filename" == *"."* ]] || filename="${mod_id}.zip"
    local archive="$TEMP_DIR/$filename"

    echo "  Downloading '$mod_name' ..."
    curl -sfL -o "$archive" "$url" || {
        echo "  [ERROR] Download failed for '$mod_name'. Skipping."
        return 1
    }

    echo "  Extracting to $(basename "$target_dir") ..."
    extract_archive "$archive" "$target_dir" || return 1
    echo "  [OK] $mod_name"
}

download_github() {
    local repo="$1"
    local target_dir="$2"

    echo "[GitHub] Fetching latest release for $repo ..."
    local api_json
    api_json=$(curl -sfL "https://api.github.com/repos/$repo/releases/latest") || {
        echo "  [ERROR] API request failed for $repo. Skipping."
        return 1
    }

    local tag
    tag=$(echo "$api_json" | jq -r '.tag_name // "unknown"')

    local asset_url
    asset_url=$(echo "$api_json" | jq -r '.assets[0].browser_download_url // empty')
    if [[ -z "$asset_url" ]]; then
        echo "  [ERROR] No release asset found for $repo. Skipping."
        return 1
    fi

    local filename
    filename=$(basename "$asset_url")
    local archive="$TEMP_DIR/$filename"

    echo "  Downloading $repo ($tag) ..."
    curl -sfL -o "$archive" "$asset_url" || {
        echo "  [ERROR] Download failed for $repo. Skipping."
        return 1
    }

    echo "  Extracting to $(basename "$target_dir") ..."
    extract_archive "$archive" "$target_dir" || return 1
    echo "  [OK] $repo ($tag)"
}

echo " RAMP — Reend's Awesome Modpack Auto Install Scripto"
echo

read -rp "Enter PAYDAY 2 root directory: " PD2_DIR
PD2_DIR="${PD2_DIR%/}"

if [[ ! -f "$PD2_DIR/payday2.exe" ]]; then
    echo "[ERROR] payday2.exe not found in '$PD2_DIR'."
    echo "        Please provide a valid PAYDAY 2 installation directory."
    exit 1
fi

if [[ ! -f "$PD2_DIR/wsock32.dll" ]]; then
    echo "[ERROR] wsock32.dll not found. SuperBLT is required to use mods."
    echo "        Install SuperBLT from https://superblt.znix.xyz before running this script."
    exit 1
fi

echo "[OK] PAYDAY 2 directory validated."
echo

MODS_DIR="$PD2_DIR/mods"
OVERRIDES_DIR="$PD2_DIR/assets/mod_overrides"
mkdir -p "$MODS_DIR" "$OVERRIDES_DIR"

total=$(( ${#MODWORKSHOP_MODS[@]} + ${#GITHUB_MODS[@]} ))
if [[ "$total" -eq 0 ]]; then
    echo "[WARN] No mods defined in the mod lists. Nothing to install."
    exit 0
fi

installed=0
failed=0

for entry in "${MODWORKSHOP_MODS[@]}"; do
    IFS='|' read -r mod_id target <<< "$entry"
    target_dir="$MODS_DIR"
    [[ "$target" == "mod_overrides" ]] && target_dir="$OVERRIDES_DIR"

    if download_modworkshop "$mod_id" "$target_dir"; then
        ((installed++))
    else
        ((failed++))
    fi
    echo
done

for entry in "${GITHUB_MODS[@]}"; do
    IFS='|' read -r repo target <<< "$entry"
    target_dir="$MODS_DIR"
    [[ "$target" == "mod_overrides" ]] && target_dir="$OVERRIDES_DIR"

    if download_github "$repo" "$target_dir"; then
        ((installed++))
    else
        ((failed++))
    fi
    echo
done

echo "=========================================="
echo " Installation complete!"
echo " Installed: $installed / $total"
[[ "$failed" -gt 0 ]] && echo " Failed:    $failed"
echo "=========================================="
