#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep --quiet '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep --quiet --fixed-strings "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

# Install the newest Catch2 release. GitHub redirects releases/latest to the
# newest release's tag, which is resolved here at build time so a rebuild
# picks up the next release by itself.
apt-get update
apt-get install --yes cmake curl
readonly CATCH2_LATEST_URL=$(curl --silent --fail --output /dev/null --write-out '%{redirect_url}' \
  https://github.com/catchorg/Catch2/releases/latest)
readonly CATCH2_TAG="${CATCH2_LATEST_URL##*/}"

# An empty tag means the redirect could not be read or has changed shape,
# not that Catch2 stopped releasing, so stop rather than install nothing.
if [ -z "${CATCH2_TAG}" ]; then
  echo 'Found no Catch2 release tag at github.com/catchorg/Catch2' >&2
  exit 1
fi

# Catch2 is built once here into libCatch2.a and libCatch2Main.a, the second
# holding main(), so a kata compiles only its own files and links these.
# It is built with clang++ because that is what compiles a kata.
cd /usr/src
curl --silent --fail --location \
  "https://github.com/catchorg/Catch2/archive/refs/tags/${CATCH2_TAG}.tar.gz" \
  | tar --extract --gzip
cd "Catch2-${CATCH2_TAG#v}"
cmake -S . -B build -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_CXX_COMPILER=clang++
cmake --build build
cmake --install build
cd /usr/src
rm -rf "Catch2-${CATCH2_TAG#v}"
apt-get remove --yes cmake

add_test_framework Catch2 "${CATCH2_TAG#v}"
cat /versions.json
