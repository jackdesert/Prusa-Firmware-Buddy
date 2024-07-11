#! /bin/bash

set -e


# Acquire the git sha so we can include it in the suffix
GIT_SHA=$(git rev-parse --short HEAD)

# Count the number of git commits since the beginning, since that is what the
# builder uses as BUILD_NUMBER, and we want it to match so it does throw a warning
#
#
NUM_COMMITS=$(git rev-list --count HEAD)

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# Replace forward slashes with hyphens in branch name so that they are not considered
# directories when copying files
CURRENT_BRANCH_PRETTY="${CURRENT_BRANCH//\//-}"

# The following characters are allowed after the NUM_COMMITS:
#     [0-9a-zA-Z-]+
# See utils/pack_fw.py line 13
# Which basically means no underscores
VERSION_SUFFIX="+${NUM_COMMITS}--${CURRENT_BRANCH_PRETTY}--${GIT_SHA}"
echo "VERSION_SUFFIX: ${VERSION_SUFFIX}"


# Return error if git repository is dirty
# This ensures that the sha we compute is not littered with uncommitted changesCheck if the Git repository is dirty
# Note doing this late in the script so that we can see the output of the above for
# debugging without needing to commit to git
if [[ -n $(git status -s) ]]; then
  echo 'Error: Git repository is dirty. Commit or stash your changes before building.'
  exit 1
fi

# Remove the build directory so that it will only contain the new output
# Note only doing this after receiving go-ahead from git status
rm -rf build

# --bootloader yes tells it to only build the "_boot" version, not the "no_boot" version
# Using custom version suffix (matching +xxxx to show that it has been modified
# (Note bumping to +5737 to be one higher than the default +5736)
BUDDY_NO_VIRTUALENV=1 python utils/build.py --preset mini --generate-bbf --bootloader yes --version-suffix "$VERSION_SUFFIX"  --version-suffix-short "+${NUM_COMMITS}"

echo SUCCESS
