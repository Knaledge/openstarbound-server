#!/usr/bin/env bash
# Test harness for starbound-mod-updater-shared functions
# Mocks getModTimestamp to avoid external API calls

set -e

# Silence log output during tests
info() { :; }
debug() { :; }
warn() { :; }
error() { :; }

# Load shared functions
source "$(dirname "$0")/starbound-mod-updater-shared"

# Override getModTimestamp for deterministic behavior
getModTimestamp() {
  local mod_id=$1
  case "$mod_id" in
    123) echo 100 ;;
    456) echo 200 ;;
    *) echo 50 ;;
  esac
}

# Prepare a temporary test directory
tmpdir="$(mktemp -d)"
cd "$tmpdir"

# Create a fake modlist
echo -e "123\n# comment\n456\n" > modlist.txt

# Point variables to test files
export mod_version_file_path="$tmpdir/mod_versions.json"
export mod_directory="$tmpdir/mods"
export modlist_file="./modlist.txt"
# Ensure loadModList sees our test modlist
export modlist_directory="$tmpdir"

# Test loadModList
echo "== Running loadModList =="
loadModList
echo "mod_ids: ${mod_ids[@]}"

# Test saveCurrentVersions & loadCurrentVersions
echo "== Testing save/load versions =="
saveCurrentVersions "123 100" "789 50"
loadCurrentVersions
echo "current_versions: ${current_versions[@]}"

# Test pruneRemovedMods (should remove mod 789)
# Create dummy mod directories to simulate existing mods
mkdir -p "$mod_directory/123" "$mod_directory/789"
# Create dummy mod directories to simulate existing mods
mkdir -p "$mod_directory/123" "$mod_directory/789"
echo "== Testing pruneRemovedMods =="
pruneRemovedMods "${mod_ids[@]}"
loadCurrentVersions
echo "after prune current_versions: ${current_versions[@]}"
# Verify that directory 789 was removed and 123 remains
if [ -d "$mod_directory/123" ] && [ ! -d "$mod_directory/789" ]; then
  echo "Directory pruning OK"
else
  echo "Directory pruning FAILED"
  exit 1
fi

# Test checkForModUpdates (123 up-to-date, 456 new)
echo "== Testing checkForModUpdates =="
checkForModUpdates "${mod_ids[@]}"
echo "updates needed: ${update_list[@]}"

# Test updateModVersions
echo "== Testing updateModVersions =="
updateModVersions "${update_list[@]}"
loadCurrentVersions
echo "after update current_versions: ${current_versions[@]}"

# Test timestamp update for existing mod
echo "== Testing timestamp update =="
# Seed JSON with older timestamps
saveCurrentVersions "123 50" "456 50"
loadCurrentVersions
echo "before timestamp update: ${current_versions[@]}"
# Update only mod 123
updateModVersions "123"
loadCurrentVersions
echo "after timestamp update: ${current_versions[@]}"
# Verify timestamp for 123 was updated to 100
if echo "${current_versions[@]}" | grep -q '123 100'; then
  echo "Timestamp update OK"
else
  echo "Timestamp update FAILED"
  exit 1
fi

echo "All tests passed"
