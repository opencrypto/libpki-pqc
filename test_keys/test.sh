#!/bin/bash

pki-tool genkey -debug -verbose -algor composite -addkey falcon.key -addkey ec.key -addkey dilithium.key -addkey rsa.key -out composite.key

exit 0

