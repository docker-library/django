#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%.*/}" )
url='git://github.com/docker-library/django'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'
echo

fullVersion="$(grep -m1 'ENV DJANGO_VERSION ' Dockerfile | cut -d' ' -f3)"
versionAliases=()
for pyVersion in "${versions[@]}"; do
	commit="$(git log -1 --format='format:%H')"
	temp="$fullVersion"
	while [ "${temp%.*}" != "$temp" ]; do
		echo "$temp-$pyVersion: $url@$commit"
		temp="${temp%.*}"
	done
	echo "$temp-$pyVersion: $url@$commit"
	if [ "$temp" == "1" ] && [ "$pyVersion" == "python-3" ]; then
		echo "latest: $url@$commit"
	fi
done

