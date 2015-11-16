#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

#current="$(curl -sSL 'https://pypi.python.org/pypi/django/json' | awk -F '"' '$2 == "version" { print $4 }')" # UGH "1.8a1"
current="$(curl -sSL 'https://pypi.python.org/pypi/django/json' | grep '^        "[0-9].*\[$' | cut -d '"' -f2 | grep -vE '[0-9]([abc]|rc)[0-9]' | sort -V | tail -1)" # TODO remove this heinous thing in favor of something better since it just filters out "1.8a1" and "1.8b1"

travisEnv=
for version in "${versions[@]}"; do
	( set -x; sed -ri 's/^(ENV DJANGO_VERSION) .*/\1 '"$current"'/' "$version/Dockerfile" )
	
	pythonOnbuildDockerfile="https://raw.githubusercontent.com/docker-library/python/master/$version/onbuild/Dockerfile"
	( set -x; curl -sSL "$pythonOnbuildDockerfile" -o "$version/onbuild/Dockerfile" )
	{
		echo
		# see http://stackoverflow.com/a/12776899 (line continuations eat our lunch)
		sed -n ': begin; /\\$/ { N; b begin }; /apt-get/ p' "$version/Dockerfile"
		echo
		echo 'EXPOSE 8000'
		echo 'CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]'
	} >> "$version/onbuild/Dockerfile"
	
	from="$(awk '$1 == "FROM" { print $2 }' "$version/onbuild/Dockerfile")"
	( set -x; sed -ri 's/^(FROM) .*/\1 '"$from"'-slim/' "$version/Dockerfile" )
	
	travisEnv='\n  - PY_VERSION='"$version$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
