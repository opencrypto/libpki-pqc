# Post-Quantum and Composite Crypto
# Patch and Diff Tools for Automation
# (c) 2021 by Massimiliano Pala

NOW=$(date +%Y%m%d%H%M%S)
PATCH_DIR=$(echo config-n-patch/ossl-patch-* | sed -e 's|.*\s||')
LIBOQS_DIR=liboqs
OSSL_CLEAN=openssl
DEBUG_MODE=NO

if ! [ "x$1" = "x" ] ; then
  OSSL_CLEAN=$1
fi

if ! [ -d "${OSSL_CLEAN}" ] ; then
	echo
	echo "    ERROR: missing patch destination directory [${OSSL_CLEAN}]"
	echo "           (use $0 <directory> to specify a different one)"
	echo
	echo " ... did you forget to checkout the latest OQS repo ? Try this:"
	echo
	echo "        $ git clone git@github.com:open-quantum-safe/openssl.git"
	echo
	exit 1;
fi

# Creates a missing link
[ -e "${OSSL_CLEAN}/oqs" ] || ln -s ../${LIBOQS_DIR}/build ${OSSL_CLEAN}/oqs

# Links the includes in the current dir
[ -e "${OSSL_CLEAN}/include/oqs" ] || ln -s ../../${LIBOQS_DIR}/build/include/oqs ${OSSL_CLEAN}/include/oqs

# Copies the crypto directories
cp -r ${PATCH_DIR}/crypto/composite ${OSSL_CLEAN}/crypto/
cp -r ${PATCH_DIR}/crypto/oqs ${OSSL_CLEAN}/crypto/

# Copy the our template for enabled algorithms
# cp ${PATCH_DIR}/oqs-template/libpki-generate-template.yml ${OSSL_CLEAN}/oqs-template/generate.yml

# Execute the build
cd ${OSSL_CLEAN}

# Apply the patch
git apply -p1 < ../${PATCH_DIR}/openssl.patch

exit 0

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

# Configure OpenSSL
./config ${options}

# Let's now build the OpenSSL library
# make && sudo make install_sw

# Done
cd ..

echo
echo "All Done."
echo

exit 0
