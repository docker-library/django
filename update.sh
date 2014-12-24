#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

current="$(curl -sSL 'https://pypi.python.org/pypi/django/json' | awk -F '"' '$2 == "version" { print $4 }')"

for version in "${versions[@]}"; do
	( set -x; sed -ri 's/^(ENV DJANGO_VERSION) .*/\1 '"$current"'/' "$version/Dockerfile" )
	
	pythonOnbuildDockerfile="https://raw.githubusercontent.com/docker-library/python/master/$version/onbuild/Dockerfile"
	( set -x; curl -sSL "$pythonOnbuildDockerfile" -o "$version/onbuild/Dockerfile" )
	{
		echo
		grep 'RUN.*apt-get install' "$version/Dockerfile"
		echo
		echo 'EXPOSE 8080'
		echo 'CMD ["python", "manage.py", "runserver"]'
	} >> "$version/onbuild/Dockerfile"
	
	from="$(awk '$1 == "FROM" { print $2 }' "$version/onbuild/Dockerfile")"
	( set -x; sed -ri 's/^(FROM) .*/\1 '"$from"'/' "$version/Dockerfile" )
done
