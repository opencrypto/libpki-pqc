#!/bin/bash

# Generates some classic keys
pki-tool genreq -batch -signkey rsa.key -subject "C=US, OU=RSA" -out libpki-rsa.req
pki-tool genreq -batch -signkey ec.key -subject "C=US, OU=EC-P256" -out libpki-ec.req
 
# Generates some Post-Quantum keys
pki-tool genreq -batch -signkey falcon.key -subject "C=US, OU=Falcon512" -out libpki-falcon512.req
pki-tool genreq -batch -signkey dilithium.key -subject "C=US, OU=Dilithium2" -out libpki-dilithium2.req

# Generates a Classic Composite
# No Equivalent in OpenSSL
pki-tool genreq -batch -signkey composite.key -subject "C=US, OU=Composite One" -out libpki-composite-one.req
pki-tool genreq -batch -signkey composite.key -subject "C=US, OU=Composite Two" -out libpki-composite-two.req

exit 0

