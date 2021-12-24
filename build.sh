# Post-Quantum and Composite Crypto
# build environment
#
# (c) 2021 by Massimiliano Pala

# Install dependencies
# sudo \
# dnf install   \
# 	cmake \
# 	gcc   \
# 	ninja-build \
# 	python3-pytest \
# 	python3-pytest-xdist \
# 	unzip \
# 	doxygen \
# 	graphviz

# Destination Directory
DEST_DIR=/opt/libpki-pqc

# Base GitHub URL
GITHUB_BASE_URL=https://codeload.github.com/open-quantum-safe
GITHUB_ARCHIVE_TYPE=zip

# LibOQS Latest Packages - See the Release Page here:
# https://github.com/open-quantum-safe/liboqs/releases
LIBOQS_VERSION=0.7.1
LIBOQS_BASE_URL=${GITHUB_BASE_URL}/liboqs/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBOQS_FULL_URL=${LIBOQS_BASE_URL}/${LIBOQS_VERSION}
LIBOQS_OUTPUT=liboqs-${LIBOQS_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBOQS_DIR=liboqs-${LIBOQS_VERSION}

# Required by OpenSSL LibOQS wrapper
LIBOQS_DOCS_DIR=${LIBOQS_DIR}/docs

# OpenSSL OQS Wrapper Latest Packages - See the Release Page here:
# https://github.com/open-quantum-safe/openssl/releases
OSSL_VERSION=OQS-OpenSSL_1_1_1-stable-snapshot-2021-12-rc1
OSSL_BASE_URL=${GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
OSSL_FULL_URL=${OSSL_BASE_URL}/${OSSL_VERSION}
OSSL_OUTPUT=openssl-${OSSL_VERSION}.${GITHUB_ARCHIVE_TYPE}
OSSL_DIR=openssl-${OSSL_VERSION}

# LibPKI Package - See the Release Page here:
#
LIBPKI_VERSION=main
LIBPKI_BASE_URL=${GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBPKI_FULL_URL=${LIBPKI_BASE_URL}/${LIBPKI_VERSION}
LIBPKI_OUTPUT=libpki-${LIBPKI_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBPKI_DIR=libpki-${LIBPKI_VERSION}

PATCH_DIR=config-n-patch/latest-ossl-patch
# OSSL_DIR=openssl
DEBUG_MODE=YES

WHOAMI=$( whoami )
NOW=$(date +%Y%m%d%H%M%S)

# Get liboqs latest repo
if [ ! -d "${LIBOQS_DIR}" -o "$1" = "liboqs" ] ; then

	# LibOQS
	echo "--> Retrieving LibOQS package (${LIBOQS_VERSION}) ..."
	result=$(curl -s "${LIBOQS_FULL_URL}" --output "${LIBOQS_OUTPUT}")
	if [ $? -gt 0 ] ; then
	  echo "    [ERROR: Cannot acces ${LIBOQS_FULL_URL}]"
	  echo
	  echo "--> Error Logs Follows:"
	  echo "$result"
	  exit 1
	else
	  echo "    [SUCCESS: Package Retrieved from ${LIBOQS_FULL_URL}]"
	fi

	result=$(unzip "${LIBOQS_OUTPUT}")

	# Build the liboqs
	[ -d "${LIBOQS_DIR}/build" ] || mkdir -p "${LIBOQS_DIR}/build"

	# Execute the build
	echo "--> Building LibOQS ${LIBOQS_VERSION} ..."

	result=$(cd ${LIBOQS_DIR}/build && \
	         cmake -DCMAKE_INSTALL_PREFIX=${DEST_DIR} -GNinja .. && \
	         ninja && sudo ninja install)

	if ! [ $? -eq 0 ] ; then
	  echo "    [ERROR: Build failed with code $?]"
	  echo "    [ERROR: Logs following]"
	  echo "$result"
	  exit 1
	fi

	echo "    [SUCCESS: LibOQS Build and Install was Successful]"
	echo "--> Removing Compressed Archive (${LIBOQS_OUTPUT})"
	rm "${LIBOQS_OUTPUT}"
	echo "    [SUCCESS: Archive Removed]"

	echo "--> LibOQS: All Done."
	echo

fi


# Fetch the latest openssl-liboqs branch
if [ ! -d "${OSSL_DIR}" -o "$1" = "openssl" ] ; then
# OpenSSL
	if [ "x${DEBUG_MODE}" = "xYES" ] ; then
	  options="--prefix=${DEST_DIR} -d -shared -no-asm -g3 -ggdb -gdwarf-4 -fno-inline -O0 -fno-omit-frame-pointer"
	else
	  options="--prefix=${DEST_DIR} -shared"
	fi

	if ! [ -f "${OSSL_OUTPUT}" ] ; then
		echo "--> Retrieving OpenSSL package (${OSSL_VERSION}) ..."
		result=$(curl -s "${OSSL_FULL_URL}" --output "${OSSL_OUTPUT}")
		if [ $? -gt 0 ] ; then
		  echo "    [ERROR: Cannot acces ${OSSL_FULL_URL}]"
		  echo
		  echo "--> Error Logs Follows:"
		  echo "$result"
		  exit 1
		else
		  echo "    [SUCCESS: Package Retrieved from ${OSSL_FULL_URL}]"
		fi
	fi

	result=$(unzip "${OSSL_OUTPUT}")

	echo "--> Creating needed OQS links ..."
	[ -e "${OSSL_DIR}/oqs" ] || $(cd ${OSSL_DIR} && ln -s ../${LIBOQS_DIR}/build oqs)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot create needed OQS/OpenSSL symlinks!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: QS/OpenSSL symlinks created successfully]"
	fi

    # [ -e "${OSSL_DIR}/include/oqs" ] || $(cd ${OSSL_DIR)/include && ln -s ../../${LIBOQS_DIR}/build/include/oqs ${OSSL_DIR}/include/oqs)
    [ -e "${OSSL_DIR}/include/oqs" ] || $(cd ${OSSL_DIR}/include && ln -s ../../${LIBOQS_DIR}/build/include/oqs )

    # Copies the crypto directories
	echo "--> Copying Our Versions of the crypto layer ..."
    cp -r ${PATCH_DIR}/crypto/composite ${OSSL_DIR}/crypto/ && \
    	cp -r ${PATCH_DIR}/crypto/oqs ${OSSL_DIR}/crypto/
	
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot copy the our composite or oqs directories!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: successfully copied [composite] and [oqs] directories from ${PATCH_DIR}/crypto]"
	fi

	# Execute the build
	echo "--> Applying latest OSSL patch (${PATCH_DIR}) ..."

	# Apply the patch
	result=$(cd ${OSSL_DIR} && git apply -p1 < ../${PATCH_DIR}/openssl.patch)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot apply our patch!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: Patch applied with no rejections]"
	fi

	# Configure OpenSSL
	echo "--> Configuring OpenSSL and Generating Crypto Objects ..."
	result=$(cd ${OSSL_DIR} && \
	    ./config ${options} && \
		LIBOQS_DOCS_DIR=../${LIBOQS_DOCS_DIR} python3 oqs-template/generate.py && \
		make generate_crypto_objects && \
		./config ${options})

	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot configure OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: Patch applied with no rejections]"
	fi

	# Execute the build
	echo "--> Building OpenSSL (${OSSL_VERSION}) ..."

	# Let's now build the OpenSSL library
	result=$(cd ${OSSL_DIR} && make build_libs 2>&1 )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot build OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully built]"
	fi

	# Let's now build the OpenSSL library
	result=$(cd ${OSSL_DIR} ; \
			 if ! [ "$WHOAMI" = "root" ] ; then \
		        sudo make install_sw 2>&1 ; \
		 	 else \
		     	make install_sw ; \
			 fi)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot install OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully installed on ${}]"
	fi
	echo "--> Removing Compressed Archive (${OSSL_OUTPUT})"
	rm "${OSSL_OUTPUT}"
	echo "    [SUCCESS: Archive Removed]"


fi

# Fetch the latest openssl-liboqs branch
if [ ! -d "${LIBPKI_DIR}" -o "$1" = "libpki" ] ; then

	if ! [ -d "libpki" ] ; then
		git clone -b libpki-oqs https://github.com/openca/libpki.git
	fi

	# Execute the build
	if [ "${DEBUG_MODE}" = "NO" ] ; then
		cd libpki \
		   && ./configure --prefix=${DEST_DIR} --disable-ldap \
		   	          --enable-composite --enable-oqs --disable-pg --disable-mysql
	else
		cd libpki \
		   && ./configure --prefix=${DEST_DIR} --disable-ldap \
		   		  --enable-composite --enable-oqs --disable-pg --disable-mysql \
				  --enable-debug
	fi

	[ -d ${DEST_DIR}/lib64 ] && rm -r ${DEST_DIR}/lib64
	[ -e ${DEST_DIR}/lib64 ] || ln -s ${DEST_DIR}/lib ${DEST_DIR}/lib64

	make && \
	if ! [ "$WHOAMI" = "root" ] ; then \
		sudo make install ; \
	else \
		make install ; \
	fi

	cd ..
fi

