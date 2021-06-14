#!/bin/bash

# Generates some classic keys
openssl req -new -key rsa.key -subj "/C=US/OU=RSA" -out ossl-rsa.req
openssl req -new -key ec.key -subj "/C=US/OU=EC-P256" -out ossl-ec.req
 
# Generates some Post-Quantum keys
openssl req -new -key falcon.key -subj "/C=US/OU=Falcon512" -out ossl-falcon512.req
openssl req -new -key dilithium.key -subj "/C=US/OU=Dilithium2" -out ossl-dilithium2.req

# Generates a Classic Composite
# No Equivalent in OpenSSL
openssl req -new -key composite.key -subj "/C=US/OU=Composite One" -out ossl-composite-one.req
openssl req -new -key composite.key -subj "/C=US/OU=Composite Two" -out ossl-composite-two.req

exit 0

