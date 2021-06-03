# ==========================================================
# Instructions:
# -------------
#
# After adding the included identifiers contained in the
# objects.txt.patch and obj_xfer.txt.patch, you will need
# to configure OpenSSL to rebuild the NID database. To do
# that, the Makefile is your friend. From the main OpenSSL
# directory, just execute:
#
#     $ make generate_crypto_objects
#
# This will rebuild the .h files. You will need to re-build
# and install the library again.
#
#     $ make && sudo make install_sw install_runtime
# 
# After that, you will need to rebuild also libpki to take
# advantage of the new definitions
# ==========================================================


