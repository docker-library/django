#!/bin/bash
set -e

python_versions=(
	2.7
	3.4
)

current_django="$(curl -s https://www.djangoproject.com/download/ | sed -rn 's/^.*pip install Django==(([0-9]\.?){3}).*/\1/p')"
sed -ri '
	s/^(ENV DJANGO_VERSION) .*/\1 '"$current_django"'/
' Dockerfile
rm -rf python_*

set -x
for version in ${python_versions[@]}; do
	dir="python_$version"
	onbuildDir="$dir/onbuild"
	mkdir -p "$onbuildDir"
	cp Dockerfile "$dir/Dockerfile"

	pythonOnbuildDockerfile="https://raw.githubusercontent.com/docker-library/python/master/$version/onbuild/Dockerfile"
	curl -sSL "$pythonOnbuildDockerfile" -o "$onbuildDir/Dockerfile"
	echo >> "$onbuildDir/Dockerfile"
	grep 'RUN.*apt-get install' "$dir/Dockerfile" >> "$onbuildDir/Dockerfile"
	echo >> "$onbuildDir/Dockerfile"
	echo 'EXPOSE 8080' >> "$onbuildDir/Dockerfile"
	echo 'CMD ["python", "manage.py", "runserver"]' >> "$onbuildDir/Dockerfile"
	
	sed -ri 's/^FROM .*/'"$(grep '^FROM' "$onbuildDir"/Dockerfile | head -1)"'/' "$dir/Dockerfile"
done
