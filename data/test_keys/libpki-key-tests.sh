#!/bin/bash

# Generates some classic keys
pki-tool genkey -batch -algor ec -bits 256 -out ec.key
pki-tool genkey -batch -algor rsa -bits 2048 -out rsa.key
 
# Generates some Post-Quantum keys
pki-tool genkey -batch -algor falcon -bits 128 -out falcon.key
pki-tool genkey -batch -algor dilithium -bits 128 -out dilithium.key

# Generates a Classic Composite
pki-tool genkey -batch -algor composite \
	-addkey rsa.key -addkey ec.key  \
	-out composite-rsa-ec.key

pki-tool genkey -batch -algor composite \
	-addkey rsa.key -addkey rsa.key  \
	-out composite-rsa-rsa.key

# Generates a Post-Quantum Composite
pki-tool genkey -batch -algor composite \
	-addkey falcon.key       \
	-addkey dilithium.key    \
	-out composite-one.key

# Generates an Hybrid key (i.e., a mix of Classic and Post-Quantum algorithms)
pki-tool genkey -batch -algor composite \
	-addkey falcon.key \
	-addkey ec.key \
	-addkey dilithium.key \
	-addkey rsa.key \
	-out composite-two.key

cp composite-one.key composite.key

exit 0

