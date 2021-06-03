# Post-Quantum and Composite Crypto
# Patch and Diff Tools for Automation
# (c) 2021 by Massimiliano Pala

NOW=$(date +%Y%m%d%H%M%S)
PATCH_DIR=config-n-patch/${NOW}-ossl-patch
LIBOQS_DIR=liboqs
OSSL_CLEAN=openssl
OSSL_PATCHED=openssl-patched
DEBUG_MODE=NO

if ! [ "x$1" = "x" ] ; then
  OSSL_PATCHED=$1
fi

if ! [ -d "${OSSL_PATCHED}" ] ; then
	echo
	echo "    ERROR: missing patch origin directory [${OSS_PATCHED}]"
	echo "           (use $0 <directory> to specify a different one)"
	echo
	exit 1;
fi

# Saves the old patch
# if [ -e config-n-patch/ossl-patch/openssl-1.1.1-composite.patch ] ; then
#   cp config-n-patch/ossl-patch/openssl-1.1.1-composite.patch \
#      config-n-patch/ossl-patch/openssl-1.1.1-composite.patch.bak
# fi

# Prepares the destination for the patch
mkdir ${PATCH_DIR} ${PATCH_DIR}/crypto \
      ${PATCH_DIR}/crypto/composite ${PATCH_DIR}/crypto/oqs \
      ${PATCH_DIR}/oqs-template

# Generate a new patch
cd ${OSSL_PATCHED} \
   && git diff -U --cc > ../${PATCH_DIR}/openssl.patch \
   && cp -r crypto/composite ../${PATCH_DIR}/crypto/ \
   && cp -r crypto/oqs ../${PATCH_DIR}/crypto/ \
   && cp -r oqs-template/generate.yml ../${PATCH_DIR}/oqs-template/ \
   && cd ..

# Archive the Patched OpenSSL source code
tar -cvpz --exclude="*\.git\/*" -f ${PATCH_DIR}/${NOW}-openssl-patched-src.tar.gz ${OSSL_PATCHED}

echo
echo "OpenSSL OQS/Composite Patch generated at ${PATCH_DIR}."
echo
echo "All Done."
echo

exit 0;

# Copy the our template for enabled algorithms
cp config-n-patch/oqs-config/libpki-generate-template.yml ${OSSL_CLEAN}/oqs-template/generate.yml

# Execute the build
cd ${OSSL_CLEAN}

if [ "x${DEBUG_MODE}" = "xYES" ] ; then
  options="--prefix=/opt/libpki-oqs -d -shared -no-asm -g3 -ggdb -gdwarf-4 -fno-inline -O0 -fno-omit-frame-pointer"
else
  options="--prefix=/opt/libpki-oqs -shared"
fi

# Configure OpenSSL
./config ${options}

# Rebuilds the Objects database
python3 oqs-template/generate.py
make generate_crypto_objects

# Let's now build the OpenSSL library
make && sudo make install

# Done
cd ..

