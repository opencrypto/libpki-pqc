#!/bin/bash

pki-tool genkey -algor composite -addkey falcon.key -addkey ec.key -addkey dilithium.key -addkey rsa.key

exit 0

