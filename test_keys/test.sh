#!/bin/bash

# Generates some classic keys
pki-tool genkey -algor ec -bits 256 -out ec.key
pki-tool genkey -algor rsa -bits 2048 -out rsa.key
 
# Generates some Post-Quantum keys
pki-tool genkey -algor falcon -bits 128 -out falcon.key
pki-tool genkey -algor dilithium -bits 128 -out dilithium.key

# Generates a Classic Composite
pki-tool genkey -algor composite -addkey rsa.key -addkey test_keys/ec.key

# Generates a Post-Quantum Composite
pki-tool genkey -algor composite -addkey falcon.key -addkey test_keys/dilithium.key

# Generates an Hybrid key (i.e., a mix of Classic and Post-Quantum algorithms)
pki-tool genkey -debug -verbose -algor composite -addkey falcon.key -addkey ec.key -addkey dilithium.key -addkey rsa.key -out composite.key

exit 0

