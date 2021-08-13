#!/bin/bash

# Generates some classic keys
openssl genrsa 2048 > rsa.key
openssl ecparams -genkey -noout -curve prime256v1 -out ec.key
 
# Generates some Post-Quantum keys
openssl genpkey -algorithm falcon512 -out falcon.key
openssl genpkey -algorithm dilithium2 -out dilithium.key

# Generates a Classic Composite
pki-tool genkey -batch -algor composite \
	-addkey rsa.key -addkey ec.key \
	-out classic-composite.key

# Generates a Post-Quantum Composite
pki-tool genkey -batch -algor composite \
	-addkey falcon.key       \
	-addkey dilithium.key

# Generates an Hybrid key (i.e., a mix of Classic and Post-Quantum algorithms)
pki-tool genkey -batch -algor composite \
	-addkey falcon.key \
	-addkey ec.key \
	-addkey dilithium.key \
	-addkey rsa.key \
	-out composite.key

exit 0

