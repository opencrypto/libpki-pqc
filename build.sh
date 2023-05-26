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

# Release Information
RELEASE=2021-12-24-0002

echo "--> LibPKI-PQC Build Script (Rel: ${RELEASE}) ..."

# Base GitHub URL
OPENCA_BASE_URL=https://codeload.github.com/opencrypto
GITHUB_BASE_URL=https://codeload.github.com/open-quantum-safe
GITHUB_ARCHIVE_TYPE=zip

# LibOQS Latest Packages - See the Release Page here:
# https://github.com/open-quantum-safe/liboqs/releases
# LIBOQS_VERSION=0.7.2
LIBOQS_VERSION=0.8.0-rc1
LIBOQS_BASE_URL=${GITHUB_BASE_URL}/liboqs/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBOQS_FULL_URL=${LIBOQS_BASE_URL}/${LIBOQS_VERSION}
LIBOQS_OUTPUT=liboqs-${LIBOQS_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBOQS_DIR=liboqs-${LIBOQS_VERSION}

# Required by OpenSSL LibOQS wrapper
LIBOQS_DOCS_DIR=${LIBOQS_DIR}/docs

# OpenSSL OQS Wrapper Latest Packages - See the Release Page here:
# https://github.com/open-quantum-safe/openssl/releases
# OSSL_VERSION=OQS-OpenSSL_1_1_1-stable-snapshot-2021-12-rc1
# OSSL_VERSION=OQS-OpenSSL-1_1_1-stable-snapshot-2022-08
# OSSL_VERSION=OQS-OpenSSL-1_1_1-stable-snapshot-2023-02
OSSL_VERSION=OQS_0_8_0_rc1-OpenSSL_1_1_1-snapshot-2023-05-25
# OSSL_BASE_URL=${GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
OSSL_BASE_URL=${OPENCA_BASE_URL}/openssl-oqs/${GITHUB_ARCHIVE_TYPE}/refs/tags
OSSL_FULL_URL=${OSSL_BASE_URL}/${OSSL_VERSION}
# OSSL_OUTPUT=openssl-${OSSL_VERSION}.${GITHUB_ARCHIVE_TYPE}
# OSSL_DIR=openssl-${OSSL_VERSION}
OSSL_OUTPUT=openssl-oqs-${OSSL_VERSION}.${GITHUB_ARCHIVE_TYPE}
OSSL_DIR=openssl-oqs-${OSSL_VERSION}

# LibPKI Package - See the Release Page here:
# LIBPKI_VERSION=master
LIBPKI_VERSION=71-add-support-for-oqs-080
LIBPKI_BASE_URL=${GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBPKI_FULL_URL=${LIBPKI_BASE_URL}/${LIBPKI_VERSION}
LIBPKI_OUTPUT=libpki-${LIBPKI_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBPKI_DIR=libpki-${LIBPKI_VERSION}

PATCH_DIR=config-n-patch/latest-ossl-patch
# OSSL_DIR=openssl
# DEBUG_MODE=YES

SUDO=
WHOAMI=$( whoami )
NOW=$(date +%Y%m%d%H%M%S)

# Sets the SUDO command
[ "$WHOAMI" = "root" ] || SUDO=sudo

# Get liboqs latest repo
if [ ! -d "${LIBOQS_DIR}" -o "$1" = "liboqs" ] ; then

	# More Info on LibOQS options can be found at
	# https://github.com/open-quantum-safe/liboqs/wiki/Customizing-liboqs

	# LibOQS
	echo "--> Retrieving LibOQS package (${LIBOQS_VERSION}) ..."
	result=$(curl -s "${LIBOQS_FULL_URL}" --output "${LIBOQS_OUTPUT}")
	if [ $? -gt 0 ] ; then
	  echo "    [ERROR: Cannot access ${LIBOQS_FULL_URL}]"
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

	# Release Build options
	OQS_BUILD_OPTIONS="\
	  -DCMAKE_INSTALL_PREFIX='${DEST_DIR}' \
	  -DBUILD_SHARED_LIBS=ON \
	  -DCMAKE_BUILD_TYPE=Release \
          -DOQS_BUILD_ONLY_LIB=ON \
          -DOQS_DIST_BUILD=ON"

	# Debug Build options
	if [ "x${DEBUG_MODE}" = "xYES" ] ; then
	  OQS_BUILD_OPTIONS="\
	    -DCMAKE_INSTALL_PREFIX='${DEST_DIR}' \
	    -DBUILD_SHARED_LIBS=ON \
	    -DCMAKE_BUILD_TYPE=Debug \
            -DOQS_BUILD_ONLY_LIB=OFF \
            -DOQS_DIST_BUILD=OFF"
	fi

	# Execute the build
	echo "--> Building LibOQS ${LIBOQS_VERSION} ..."

	result=$(cd ${LIBOQS_DIR}/build \
		    && cmake ${OQS_BUILD_OPTIONS} -G Ninja .. \
		    && ninja \
		    && ${SUDO} ninja install)

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

	# Exits if we only wanted this component installed
	[ "x$1" = "x" ] || exit 0
fi


# Fetch the latest openssl-liboqs branch
if [ ! -d "${OSSL_DIR}" -o "$1" = "openssl" ] ; then

	# OpenSSL
	if ! [ -f "${OSSL_OUTPUT}" ] ; then
		echo "--> Retrieving OpenSSL package (${OSSL_VERSION}) ..."
		result=$(curl -s "${OSSL_FULL_URL}" --output "${OSSL_OUTPUT}")
		if [ $? -gt 0 ] ; then
		  echo "    [ERROR: Cannot access ${OSSL_FULL_URL}]"
		  echo
		  echo "--> Error Logs Follows:"
		  echo "$result"
		  exit 1
		else
		  echo "    [SUCCESS: Package Retrieved from ${OSSL_FULL_URL}]"
		fi
	
		result=$(unzip "${OSSL_OUTPUT}")
	fi


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


    # # Copies the crypto directories
    # echo "--> Copying Our Versions of the crypto layer ..."
    # cp -r ${PATCH_DIR}/crypto/composite ${OSSL_DIR}/crypto/ && \
    #   cp -r ${PATCH_DIR}/crypto/oqs ${OSSL_DIR}/crypto/
	
	# if [ $? -gt 0 ] ; then
	# 	echo "    [ERROR: Cannot copy the our composite or oqs directories!]"
	# 	echo
	# 	echo "$result"
	# 	echo
	# 	exit 1
	# else
	# 	echo "    [SUCCESS: successfully copied [composite] and [oqs] directories from ${PATCH_DIR}/crypto]"
	# fi

	# # Execute the build
	# echo "--> Applying latest OSSL patch (${PATCH_DIR}) ..."

	# # Apply the patch
	# # cd ${OSSL_DIR} && git apply -p1 < ../${PATCH_DIR}/openssl.patch 2>&1
	# cd ${OSSL_DIR} && patch -p1 < ../${PATCH_DIR}/openssl.patch 2>&1 && cd ..
	# if [ $? -gt 0 ] ; then
	# 	echo "    [ERROR: Cannot apply our patch!]"
	# 	echo
	# 	# echo "$result"
	# 	echo
	# 	exit 1
	# else
	# 	echo "    [SUCCESS: Patch applied with no rejections]"
	# fi

	# # Apply The Fixes
	# for patch_file in ${PWD}/config-n-patch/liboqs-fixes/*.patch ; do
	# 	orig_name=$(echo $patch_file | sed 's|.*\/||' | sed 's|\.patch||')
	# 	result=$(cd ${OSSL_DIR}/oqs-template && patch -p0 < "${patch_file}" 2>&1 && cd ..)
	# 	if [ $? -gt 0 ] ; then
	# 		echo "    [ERROR: Cannot apply our patch!]"
	# 		echo
	# 		echo "ERROR LOG:\n$result"
	# 		echo
	# 		exit 1
	# 	else
	# 		echo "    [SUCCESS: Patch applied with no rejections]"
	# 	fi
	# done

	# Base Directory for Patches
	CURRENT_PATCH=20230525

	# Build options
	if [ "x${DEBUG_MODE}" = "xYES" ] ; then
	  options="--prefix=${DEST_DIR} -d -shared -no-asm -g3 -ggdb -gdwarf-4 -fno-inline -O0 -fno-omit-frame-pointer"
	else
	  options="--prefix=${DEST_DIR} -shared"
	fi

	# Configure OpenSSL
	echo "--> Configuring OpenSSL and Generating Crypto Objects ..."
	result=$(cd ${OSSL_DIR} && ./config ${options} && \
		LIBOQS_DOCS_DIR=../${LIBOQS_DOCS_DIR} python3 oqs-template/generate.py && \
		make generate_crypto_objects)

	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot configure OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully configured]"
	fi

	# # Creates a copy of the crypto/objects/objects.txt
	# result=$([ -f "${OSSL_DIR}/crypto/objects/objects.txt.bak" ] || \
	# 	cp "${OSSL_DIR}/crypto/objects/objects.txt" "${OSSL_DIR}/crypto/objects/objects.txt.bak" 2>&1 )

	# # Applies the Replacements
	# result=$(cp "config-n-patch/ossl-replace/${CURRENT_PATCH}/objects.txt" "${OSSL_DIR}/crypto/objects/" 2>&1)
	# if [ $? -gt 0 ] ; then
	# 	echo "    [ERROR: Cannot replace crypto/objects/objects.txt]"
	# 	echo
	# 	echo "ERROR LOG:\n$result"
	# 	echo
	# 	exit 1
	# else
	# 	echo "    [SUCCESS: crypto/objects/objects.txt replaced successfully]"
	# fi

	# Creates a copy of the crypto/objects/obj_xref.txt
	result=$( cp "${OSSL_DIR}/crypto/objects/obj_xref.txt" "${OSSL_DIR}/crypto/objects/obj_xref.txt.bak" 2>&1 )

	# Applies the Replacements
	result=$(cp "config-n-patch/ossl-replace/${CURRENT_PATCH}/obj_xref.txt" "${OSSL_DIR}/crypto/objects/" 2>&1)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot replace crypto/objects/obj_xref.txt]"
		echo
		echo "ERROR LOG:\n$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: crypto/objects/obj_xref.txt replaced successfully]"
	fi

	# Creates a copy of the crypto/objects/obj_xref.txt
	result=$( cp "${OSSL_DIR}/crypto/rsa/rsa_local.h" "${OSSL_DIR}/crypto/rsa/rsa_local.h.bak" 2>&1 )

	# Applies the Replacements
	result=$(cp "config-n-patch/ossl-replace/${CURRENT_PATCH}/rsa_local.h" "${OSSL_DIR}/crypto/rsa/" 2>&1)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot replace crypto/rsa/rsa_local.h]"
		echo
		echo "ERROR LOG:\n$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: crypto/rsa/rsa_local.h replaced successfully]"
	fi

	# echo "Skipping OQS replacement for now ..."

	# Creates a copy of the main OQS file
	result=$([ -f "${OSSL_DIR}/crypto/ec/oqs_meth.c.bak" ] || \
		cp "${OSSL_DIR}/crypto/ec/oqs_meth.c" "${OSSL_DIR}/crypto/ec/oqs_meth.c.bak" 2>&1 )

	# Apply The Replacements
	result=$(cp "config-n-patch/ossl-replace/${CURRENT_PATCH}/oqs_meth.c" "${OSSL_DIR}/crypto/ec/" 2>&1)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot replace oqs_meth.c!]"
		echo
		echo "ERROR LOG:\n$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: crypto/ec/oqs_meth.c replaced successfully]"
	fi

	# echo "Please remember to re-enable OQS replacement in the script!"

	# Rebuild the objects (to build the objects.h from objects.txt
	# and obj_xref.h from obj_xref.txt)
	echo "--> Re-Generating Crypto Objects ..."
	result=$(cd ${OSSL_DIR} && make generate_crypto_objects)

	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot configure OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: Successfully rebuilt the OpenSSL's objects]"
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
	result=$(cd ${OSSL_DIR} && ${SUDO} make install_sw 2>&1 )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot install OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully installed on ${DEST_DIR}]"
	fi
	echo "--> Removing Compressed Archive (${OSSL_OUTPUT})"
	rm "${OSSL_OUTPUT}"
	echo "    [SUCCESS: Archive Removed]"

	# Exits if we only wanted this component installed
	[ "x$1" = "x" ] || exit 0
fi

# Fetch the latest openssl-liboqs branch
if [ ! -d "${LIBPKI_DIR}" -o "$1" = "libpki" ] ; then

	# Clears the directory, if it was forced
	[ -d "${LIBPKI_DIR}" ] || rm -rf "${LIBPKI_DIR}"

	echo "--> Cloning archive from github (repo: libpki, branch: ${LIBPKI_VERSION})"
	if ! [ -d "${LIBPKI_DIR}" ] ; then
		result=$(git clone -b ${LIBPKI_VERSION} "https://github.com/openca/libpki.git" "${LIBPKI_DIR}" 2>&1)
	fi
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot clone LibPKI (branch: ${LIBPKI_VERSION})!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: LibPKI repo (branch:  ${LIBPKI_VERSION}) successfully cloned]"
	fi

	# Execute the build
	echo "--> Building LibPKI (Debug Mode: ${DEBUG_MODE})"
	if [ "${DEBUG_MODE}" = "NO" ] ; then
		result=$(cd ${LIBPKI_DIR} && \
		   	./configure \
				--prefix=${DEST_DIR} \
				--with-openssl-prefix=${DEST_DIR} \
				--enable-extra-checks \
				--disable-ldap \
				--disable-pg \
				--disable-mysql \
				--enable-composite \
				--enable-oqs \
				2>&1 )
	else
		result=$(cd ${LIBPKI_DIR} && \
		   	./configure \
				--prefix=${DEST_DIR} \
				--with-openssl-prefix=${DEST_DIR} \
				--enable-extra-checks \
				--disable-ldap \
				--disable-pg \
				--disable-mysql \
				--enable-composite \
				--enable-oqs \
				--enable-debug \
				2>&1 )
	fi
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot build LibPKI (branch:  ${LIBPKI_VERSION})!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: LibPKI (branch:  ${LIBPKI_VERSION}) successfully built]"
	fi

	if ! [ -h "${DEST_DIR}/lib64" ] ; then
		echo "--> Consolidating lib and lib64 in the destination (${DEST_DIR}})"
		[ -d ${DEST_DIR}/lib64 ] && ${SUDO} rm -r ${DEST_DIR}/lib64
		[ -e ${DEST_DIR}/lib64 ] || ${SUDO} ln -s ${DEST_DIR}/lib ${DEST_DIR}/lib64
		echo "    [SUCCESS: Removed ${DEST_DIR}/lib64 and linked to ${DEST_DIR}/lib]"
	else
		echo "--> Libraries folders lib and lib64 already consolidated (${DEST_DIR}})"
	fi

	result=$(cd ${LIBPKI_DIR} && make && ${SUDO} make install 2>&1 )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot install LibPKI (branch: ${LIBPKI_VERSION}) on ${DEST_DIR}]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: LibPKI (branch: ${LIBPKI_VERSION}) successfully installed on ${DEST_DIR}]"
	fi

	cd ..

	# Exits if we only wanted this component installed
	[ "x$1" = "x" ] || exit 0
fi

