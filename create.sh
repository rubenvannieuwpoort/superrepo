#!/usr/bin/env bash
#
# create.sh <name>
#
# Create a new subfolder <name> laid out so its `repo` working tree uses a
# sibling `repo.git` gitdir:
#
#   ./<name>/repo/.git   ->  "gitdir: ../repo.git"
#   ./<name>/repo.git/   (the real git dir, moved out of repo/)

set -euo pipefail

if [ "$#" -ne 1 ]; then
	echo "usage: $0 <name>" >&2
	exit 1
fi

name="$1"

if [ -e "$name" ]; then
	echo "error: '$name' already exists" >&2
	exit 1
fi

# Create the folder and an empty `repo` folder inside it.
mkdir -p "$name/repo"

# Initialize a git repo in `repo`, move its gitdir out, and link back to it.
git init "$name/repo"
mv "$name/repo/.git" "$name/repo.git"
printf 'gitdir: ../repo.git\n' > "$name/repo/.git"

echo "created $name"
