Important Information:
======================

This substitutes the OQS implementation that was in the ec/ directory from
the OQS project. To use this implementation instead, simply copy this dir
to the openssl/crypto one and add it in the configdata.pm file (main OSSL
directory).

Also, remember to edit the crypto/ec/build.info file and remove the OQS
references there.
