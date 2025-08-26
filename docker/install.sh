#!/bin/bash  -Eeu

mkdir /usr/include/catch2
cd /usr/include/catch2
apt-get install curl --yes

curl \
   --remote-header-name  `# -J Use the header-provided filename` \
   --location            `# -L Follow redirects` \
   --remote-name         `# -O Write output to a file named as the remote file` \
     https://github.com/catchorg/Catch2/releases/download/v2.13.10/catch.hpp

cd /usr/src
g++ -std=c++11 -Wall -c catch_main.cpp
mv /usr/src/catch_main.o /usr/lib