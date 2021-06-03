Important to remember:
======================
- Patch all the files from the ossl-patch directory. The files are not yet
  in the patch format - just edit the corresponding files in the openssl/
  directory and add the new data there.
- Copy the new directories 'crypto/oqs/' and 'crypto/composite/' to the
  openssl/crypto directory
- Add the new directories to the build by editing the configdata.pm in the
  "sdirs" list (i.e., add ' "oqs", "composite" ' to the list);
- Regenerate the OID database by running 'make generate_crypto_objects'
- Re-Compile OpenSSL and install it (useful for developing to use the
  '--debug' or '-d' flag when running the './config' again)
