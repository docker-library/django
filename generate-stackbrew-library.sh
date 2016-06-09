#!/bin/bash
set -eu

latestPythonMajor='3'

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

pyVersions=( */ )
pyVersions=( "${pyVersions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; pyVersions=( $(echo "${pyVersions[*]}" | sort -rV) ); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

cat <<-EOH
# this file is generated via https://github.com/docker-library/django/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/django.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for pyVersion in "${pyVersions[@]}"; do
	pyMajor="${pyVersion%.*}"

	commit="$(dirCommit "$pyVersion")"

	fullVersion="$(git show "$commit":"$pyVersion/Dockerfile" | awk '$1 == "ENV" && $2 == "DJANGO_VERSION" { print $3; exit }')"

	versionAliases=()
	while [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%[.-]*}"
	done
	versionAliases+=(
		$fullVersion
		latest
	)

	variant="python$pyMajor"

	variantAliases=( "${versionAliases[@]/%/-$variant}" )
	variantAliases=( "${variantAliases[@]//latest-/}" )

	if [ "$pyMajor" = "$latestPythonMajor" ]; then
		variantAliases+=( "${versionAliases[@]}" )
	fi

	echo
	cat <<-EOE
		Tags: $(join ', ' "${variantAliases[@]}")
		GitCommit: $commit
		Directory: $pyVersion
	EOE

	for subVariant in onbuild; do
		[ -f "$pyVersion/$subVariant/Dockerfile" ] || continue

		commit="$(dirCommit "$pyVersion/$subVariant")"

		variantAliases=( "$variant-$subVariant" )
		if [ "$pyMajor" = "$latestPythonMajor" ]; then
			variantAliases+=( "$subVariant" )
		fi

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			GitCommit: $commit
			Directory: $pyVersion/$subVariant
		EOE
	done
done
