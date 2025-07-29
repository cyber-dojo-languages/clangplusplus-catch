#!/bin/bash -Eeu

apt-get install --yes curl
mkdir /usr/include/catch2
cd /usr/include/catch2

curl \
   --remote-header-name  `# -J Use the header-provided filename` \
   --location            `# -L Follow redirects` \
   --remote-name         `# -O Write output to a file named as the remote file` \
     https://github.com/catchorg/Catch2/releases/download/v3.9.0/catch_amalgamated.hpp

curl \
   --remote-header-name  `# -J Use the header-provided filename` \
   --location            `# -L Follow redirects` \
   --remote-name         `# -O Write output to a file named as the remote file` \
     https://github.com/catchorg/Catch2/releases/download/v3.9.0/catch_amalgamated.cpp

apt-get remove --yes curl
cd /usr/src
clang++ -fPIC -Wall -c catch_amalgamated.cpp
mv /usr/src/catch_amalgamated.o /usr/lib
