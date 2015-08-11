#!/bin/bash
set -e

latestPythonMajor='3'

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/django'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	pyMajor="${version%.*}"
	commit="$(cd "$version" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	fullVersion="$(grep -m1 'ENV DJANGO_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	versionAliases=( $fullVersion-$version )
	versionAliases=()
	while [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion-python$pyMajor )
		if [ "$pyMajor" = "$latestPythonMajor" ]; then
			versionAliases+=( $fullVersion )
		fi
		fullVersion="${fullVersion%[.-]*}"
	done
	versionAliases+=( $fullVersion-python$pyMajor )
	if [ "$pyMajor" = "$latestPythonMajor" ]; then
		versionAliases+=( $fullVersion )
	fi
	versionAliases+=( python$pyMajor )
	if [ "$pyMajor" = "$latestPythonMajor" ]; then
		versionAliases+=( latest )
	fi
	
	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
	
	for variant in onbuild; do
		commit="$(cd "$version/$variant" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
		
		versionAliases=( python$pyMajor-$variant )
		if [ "$pyMajor" = "$latestPythonMajor" ]; then
			versionAliases+=( $variant )
		fi
		
		echo
		for va in "${versionAliases[@]}"; do
			echo "$va: ${url}@${commit} $version/$variant"
		done
	done
done
