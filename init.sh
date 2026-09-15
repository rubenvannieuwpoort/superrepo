#!/usr/bin/env bash
#
# init.sh
#
# For every subfolder that has a `repo.git` gitdir but no `repo` working tree,
# make sure the gitdir has its minimal `objects` and `refs` directories, then
# reconstruct the `repo` working tree by checking out the gitdir.
#
# Resulting layout (per subfolder):
#
#   ./<subfolder>/repo.git/
#       objects/
#       refs/
#   ./<subfolder>/repo/.git   ->  "gitdir: ../repo.git"

set -euo pipefail

for dir in */; do
	# strip trailing slash to get a clean folder name
	dir="${dir%/}"

	# continue only for folders with a `repo.git` but no `repo` sibling
	[ -e "$dir/repo.git" ] || continue
	[ -e "$dir/repo" ] && continue

	# ensure the gitdir has `objects` and `refs` directories.
	gitdir="$dir/repo.git"
	for sub in objects refs; do
		if [ ! -d "$gitdir/$sub" ]; then
			mkdir -p "$gitdir/$sub"
			echo "created $gitdir/$sub"
		fi
	done

	# create the `repo` working tree and point its `.git` file at the gitdir.
	mkdir "$dir/repo"
	printf 'gitdir: ../repo.git\n' > "$dir/repo/.git"

	# check out the gitdir into the working tree, if it has any commits.
	if git -C "$dir/repo" rev-parse --verify --quiet HEAD >/dev/null; then
		git -C "$dir/repo" checkout -f HEAD
		echo "checked out $dir/repo"
	else
		echo "skipped checkout for $dir/repo (no commits yet)"
	fi
done
