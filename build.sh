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

# Release Information
RELEASE=2023-09-01-0001
CURRENT_PATCH=20230901

echo "--> LibPKI-PQC Build Script (Rel: ${RELEASE})"

# Destination Directory
PRJ_DEST_DIR=/opt/libpki-ossl3
if ! [ "x$1" = "x" ] ; then
	PRJ_DEST_DIR=$1
fi
echo "    * Using PRJ_DEST_DIR=${PRJ_DEST_DIR} ($1)"

# LibPKI Branch Selection (default: master)
# example:
#   LIBPKI_VERSION=75-update-test-infrastructure-and-openssl-3
LIBPKI_VERSION=master
if ! [ "x$2" = "x" ] ; then
	LIBPKI_VERSION=$2
fi
echo "    * Using LIBPKI branch ... ${LIBPKI_VERSION}"

# Base GitHub URL
GITHUB_BASE_URL=https://codeload.github.com
OPENCA_GITHUB_BASE_URL=${GITHUB_BASE_URL}/openca
OPENCRYPTO_GITHUB_BASE_URL=${GITHUB_BASE_URL}/opencrypto
ENTRUST_GITHUB_BASE_URL=${GITHUB_BASE_URL}/EntrustCorporation
OQS_GITHUB_BASE_URL=${GITHUB_BASE_URL}/open-quantum-safe
OSSL_GITHUB_BASE_URL=${GITHUB_BASE_URL}/openssl

# Archive Type
GITHUB_ARCHIVE_TYPE=zip

# LibOQS Latest Packages - See the Release Page here:
# https://github.com/open-quantum-safe/liboqs/releases
# LIBOQS_VERSION=0.7.2
# LIBOQS_VERSION=0.8.0
# LIBOQS_VERSION=0.9.2
LIBOQS_VERSION=0.10.0-rc2
LIBOQS_BASE_URL=${OQS_GITHUB_BASE_URL}/liboqs/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBOQS_FULL_URL=${LIBOQS_BASE_URL}/${LIBOQS_VERSION}
LIBOQS_OUTPUT=liboqs-${LIBOQS_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBOQS_DIR=liboqs-${LIBOQS_VERSION}

# Required by OpenSSL LibOQS wrapper
LIBOQS_DOCS_DIR=${LIBOQS_DIR}/docs

# OpenSSL Libraries
# OSSL_VERSION=openssl-3.1.2
OSSL_VERSION=openssl-3.2.1
OSSL_BASE_URL=${OSSL_GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
OSSL_FULL_URL=${OSSL_BASE_URL}/${OSSL_VERSION}
OSSL_OUTPUT=openssl-${OSSL_VERSION}.${GITHUB_ARCHIVE_TYPE}
OSSL_DIR=openssl-${OSSL_VERSION}

# OpenCA's modified version of the OQS OpenSSL provider
# 
# Here we download the main code (not releases). Same ZIP file, but refs/heads
# instead of refs/tags
OQS_OSSL_PROV_VERSION=main
OQS_OSSL_PROV_BASE_URL=${OPENCRYPTO_GITHUB_BASE_URL}/oca-oqsprovider/${GITHUB_ARCHIVE_TYPE}/refs/heads
OQS_OSSL_PROV_FULL_URL=${OQS_OSSL_PROV_BASE_URL}/${OQS_OSSL_PROV_VERSION}
OQS_OSSL_PROV_CLONE_URL=https://github.com/opencrypto/oca-oqsprovider.git
OQS_OSSL_PROV_OUTPUT=${OQS_OSSL_PROV_VERSION}.${GITHUB_ARCHIVE_TYPE}
OQS_OSSL_PROV_DIR=oca-oqsprovider-${OQS_OSSL_PROV_VERSION}
USE_OSSL_PROVIDER=NO

# OpenCA's modified version of the OQS OpenSSL provider
# 
# Here we download the main code (not releases). Same ZIP file, but refs/heads
# instead of refs/tags
OQS_OCA_PROV_VERSION=main
OQS_OCA_PROV_BASE_URL=${OPENCRYPTO_GITHUB_BASE_URL}/oca-oqsprovider/${GITHUB_ARCHIVE_TYPE}/refs/heads
OQS_OCA_PROV_FULL_URL=${OQS_OCA_PROV_BASE_URL}/${OQS_OCA_PROV_VERSION}
OQS_OCA_PROV_CLONE_URL=https://github.com/opencrypto/oca-oqsprovider.git
OQS_OCA_PROV_OUTPUT=${OQS_OCA_PROV_VERSION}.${GITHUB_ARCHIVE_TYPE}
OQS_OCA_PROV_DIR=oca-oqsprovider-${OQS_OCA_PROV_VERSION}
USE_OCA_PROVIDER=NO

# Entrust OQS Provider
#
# Here we download the main code (not releases). Same ZIP file, but refs/heads
# instead of refs/tags
OQS_ENTRUST_PROV_VERSION=main
OQS_ENTRUST_PROV_BASE_URL=${ENTRUST_GITHUB_BASE_URL}/entrust-oqsprovider/${GITHUB_ARCHIVE_TYPE}/refs/heads
OQS_ENTRUST_PROV_FULL_URL=${OQS_ENTRUST_PROV_BASE_URL}/${OQS_ENTRUST_PROV_VERSION}
OQS_ENTRUST_PROV_CLONE_URL=https://github.com/EntrustCorporation/oqs-provider.git
OQS_ENTRUST_PROV_OUTPUT=${OQS_ENTRUST_PROV_VERSION}.${GITHUB_ARCHIVE_TYPE}
OQS_ENTRUST_PROV_DIR=entrust-oqsprovider-${OQS_ENTRUST_PROV_VERSION}
USE_ENTRUST_PROVIDER=YES

# LibPKI Package - See the Release Page here:
LIBPKI_BASE_URL=${GITHUB_BASE_URL}/openssl/${GITHUB_ARCHIVE_TYPE}/refs/tags
LIBPKI_FULL_URL=${LIBPKI_BASE_URL}/${LIBPKI_VERSION}
LIBPKI_OUTPUT=libpki-${LIBPKI_VERSION}.${GITHUB_ARCHIVE_TYPE}
LIBPKI_DIR=libpki-${LIBPKI_VERSION}

SUDO=
WHOAMI=$( whoami )
NOW=$(date +%Y%m%d%H%M%S)

# Sets the SUDO command
[ "$WHOAMI" = "root" ] || SUDO=sudo

# Get liboqs latest repo
if [ ! -d "${LIBOQS_DIR}" -o "$3" = "liboqs" ] ; then

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
	  -DCMAKE_INSTALL_PREFIX='${PRJ_DEST_DIR}' \
	  -DBUILD_SHARED_LIBS=ON \
	  -DCMAKE_BUILD_TYPE=Release \
          -DOQS_BUILD_ONLY_LIB=ON \
          -DOQS_DIST_BUILD=ON"

	# Debug Build options
	if [ "x${DEBUG_MODE}" = "xYES" ] ; then
	  OQS_BUILD_OPTIONS="\
	    -DCMAKE_INSTALL_PREFIX='${PRJ_DEST_DIR}' \
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
		    && ${SUDO} ninja install 2>&1 > liboqs_install_log.txt)

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
	[ "x$3" = "xliboqs" ] && exit 0
fi

# Consolidate the lib directory, ossl3 seems to change the default destination
# of OpenSSL from lib to lib64

echo "--> Checking lib and lib64 in the destination (${PRJ_DEST_DIR}})"
if ! [ -h "${PRJ_DEST_DIR}/lib64" ] ; then
	
	echo "--> Consolidating lib and lib64 in the destination (${PRJ_DEST_DIR}})"
	
	if [ -d ${PRJ_DEST_DIR}/lib64 ] ; then
		${SUDO} rm -r ${PRJ_DEST_DIR}/lib64
		echo "    [SUCCESS: Removed ${PRJ_DEST_DIR}/lib64]"
	fi

	if ! [ -h ${PRJ_DEST_DIR}/lib64 ] ; then
		${SUDO} ln -s ${PRJ_DEST_DIR}/lib ${PRJ_DEST_DIR}/lib64
		echo "    [SUCCESS: Linked ${PRJ_DEST_DIR}/lib64 ${PRJ_DEST_DIR}/lib]"
	fi
else
	echo "--> Libraries folders lib and lib64 already consolidated (${PRJ_DEST_DIR}})"
fi

# Fetch the latest openssl release (3.x)
if [ ! -d "${OSSL_DIR}" -o "$3" = "openssl" ] ; then

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
	
		result=$(unzip -q "${OSSL_OUTPUT}")
	fi

	# Build options
	if [ "x${DEBUG_MODE}" = "xYES" ] ; then
	  options="--prefix=${PRJ_DEST_DIR} -d -shared -no-asm -g3 -ggdb -gdwarf-4 -fno-inline -O0 -fno-omit-frame-pointer"
	else
	  options="--prefix=${PRJ_DEST_DIR} -shared"
	fi

	# Configure OpenSSL
	echo "--> Configuring OpenSSL and Generating Crypto Objects ..."
	result=$( cd ${OSSL_DIR} && ./config ${options} 2>&1 )

	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot configure OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully configured]"
	fi

	# Applies the Replacements
	result=$(cp "config-n-patch/ossl-replace/${CURRENT_PATCH}/rsa.h" "${OSSL_DIR}/include/crypto/" 2>&1)
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot replace include/crypto/rsa.h]"
		echo
		echo "ERROR LOG:\n$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: include/crypto/rsa.h replaced successfully]"
	fi

	# Execute the build
	echo "--> Building OpenSSL (${OSSL_VERSION}) ..."

	# Let's now build the OpenSSL library
	result=$(cd ${OSSL_DIR} && make build_libs 2>&1 >ossl_build_log.txt )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot build OpenSSL!]"
		echo
		echo "This is my first script"
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully built]"
	fi

	# Let's now build the OpenSSL library
	result=$(cd ${OSSL_DIR} && ${SUDO} make install_sw 2>&1 >ossl_install_log.txt )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot install OpenSSL!]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: OpenSSL successfully installed on ${PRJ_DEST_DIR}]"
	fi
	echo "--> Removing Compressed Archive (${OSSL_OUTPUT})"
	rm "${OSSL_OUTPUT}"
	echo "    [SUCCESS: Archive Removed]"

	# Exits if we only wanted this component installed
	[ "x$3" = "xopenssl" ] && exit 0
fi

# Fetch the OCA oqsprovider
if [ ! -d "${OQS_OSSL_PROV_DIR}" -o "$3" = "oqsprovider" ] ; then

	# Check we have one of the providers enabled
	if [ "x${USE_OSSL_PROVIDER}" = "xNO" -a "x${USE_OCA_PROVIDER}" = "xNO" -a "x${USE_ENTRUST_PROVIDER}" = "xNO" ] ; then
		echo "    [ERROR: No OQS Provider selected!]"
		echo
		exit 1
	fi

	if [ "x${USE_OSSL_PROVIDER}" = "xYES" ] ; then

		# OSSL oqsprovider - download process uses the same as releases
		#
		# Use this approach for ease-of-use with releases (instead of cloning repos)
		if ! [ -f "${OQS_OSSL_PROV_OUTPUT}" ] ; then
			echo "--> Retrieving OQS Provider package (${OQS_OSSL_PROV_VERSION}) ..."
			result=$(curl -s "${OQS_OSSL_PROV_FULL_URL}" --output "${OQS_OSSL_PROV_OUTPUT}")
			if [ $? -gt 0 ] ; then
			  echo "    [ERROR: Cannot access ${OQS_OSSL_PROV_FULL_URL}]"
			  echo
			  echo "--> Error Logs Follows:"
			  echo "$result"
			  exit 1
			else
			  echo "    [SUCCESS: Package Retrieved from ${OQS_OSSL_PROV_FULL_URL}]"
			fi
		
			result=$(unzip -q "${OQS_OSSL_PROV_OUTPUT}")
			if [ $? -gt 0 ] ; then
			  echo "    [ERROR: Cannot unzip ${OQS_OSSL_PROV_OUTPUT}]"
			  echo
			  echo "--> Error Logs Follows:"
			  echo "$result"
			  exit 1
			else
			  echo "    [SUCCESS: Package Unzipped correctly from ${OQS_OSSL_PROV_OUTPUT}]"
			fi
		fi
	fi

	if [ "x${USE_OCA_PROVIDER}" = "xYES" ] ; then
		# OCA oqsprovider - download process uses clone of repos
		#
		# Use this approach to be able to contribute back to the repo (development)
		echo "--> Cloning archive from github (repo: oca-oqsprovider, branch: ${OQS_OCA_PROV_VERSION})"
		if ! [ -d "${OQS_OCA_PROV_DIR}" ] ; then
			result=$( git clone -b ${OQS_OCA_PROV_VERSION} "${OQS_OCA_PROV_CLONE_URL}" "${OQS_OCA_PROV_DIR}" 2>&1 )
		fi
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot clone original OQS provider (branch: ${OQS_OCA_PROV_VERSION})!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: OQS original provider repo (branch:  ${OQS_OCA_PROV_VERSION}) successfully cloned]"
		fi

		# Build options
		if [ "x${DEBUG_MODE}" = "xYES" ] ; then
			options="-DOPENSSL_ROOT_DIR=${PRJ_DEST_DIR} -DCMAKE_BUILD_TYPE=Debug -S . -B _build"
		else
			options="-DOPENSSL_ROOT_DIR=${PRJ_DEST_DIR} -DCMAKE_BUILD_TYPE=Release -S . -B _build"
		fi

		# Configure OQS Provider
		echo "--> Configuring OCA oqsprovider ..."
		result=$( cd ${OQS_OSSL_PROV_DIR} && liboqs_DIR=${PRJ_DEST_DIR} cmake ${options} 2>&1 )

		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot configure OCA oqsprovider (${OQS_OSSL_PROV_FULL_URL})!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: OCA oqsprovider successfully configured]"
		fi

		# Execute the build
		echo "--> Building OCA oqsprovider (${OQS_OSSL_PROV_VERSION}) ..."

		# Let's now build the OpenSSL library
		result=$( cd ${OQS_OCA_PROV_DIR} && cmake --build _build 2>&1 )
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot build OCA oqsprovider!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: OCA oqsprovider successfully built]"
		fi

		# Let's now build the OpenSSL library
		result=$( cd ${OQS_OCA_PROV_DIR} && ${SUDO} cmake --install _build 2>&1 )
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot install OCA oqsprovider!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: OCA oqsprovider successfully installed on ${PRJ_DEST_DIR}]"
		fi
		echo "--> Removing Compressed Archive (${OQS_OCA_PROV_OUTPUT})"
		[ -f "${OQS_OCA_PROV_OUTPUT}" ] && rm "${OQS_OCA_PROV_OUTPUT}"
		echo "    [SUCCESS: Archive Removed]"
	fi

	if [ "x${USE_ENTRUST_PROVIDER}" = "xYES" ] ; then
		# ENTRUST oqsprovider - download process uses clone of repos
		#
		# Use this approach to be able to contribute back to the repo (development)
		echo "--> Cloning archive from github (repo: oqsprovider, branch: ${OQS_OSSL_PROV_VERSION})"
		if ! [ -d "${OQS_ENTRUST_PROV_DIR}" ] ; then
			result=$( git clone -b ${OQS_ENTRUST_PROV_VERSION} "${OQS_ENTRUST_PROV_CLONE_URL}" "${OQS_ENTRUST_PROV_DIR}" 2>&1 )
		fi
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot clone Entrust OQS Repo (branch: ${LIBPKI_VERSION})!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: Entrust OQS repo (branch:  ${LIBPKI_VERSION}) successfully cloned]"
		fi

		# Build options
		if [ "x${DEBUG_MODE}" = "xYES" ] ; then
			options="-DOPENSSL_ROOT_DIR=${PRJ_DEST_DIR} -DCMAKE_BUILD_TYPE=Debug -S . -B _build"
		else
			options="-DOPENSSL_ROOT_DIR=${PRJ_DEST_DIR} -DCMAKE_BUILD_TYPE=Release -S . -B _build"
		fi

		# Configure OQS Provider
		echo "--> Configuring Entrust oqsprovider ..."
		result=$( cd ${OQS_ENTRUST_PROV_DIR} && liboqs_DIR=${PRJ_DEST_DIR} cmake ${options} 2>&1 )

		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot configure Entrust oqs-provider (${OQS_ENTRUST_PROV_FULL_URL})!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: Entrust oqsprovider successfully configured]"
		fi

		# Execute the build
		echo "--> Building Entrust oqsprovider (${OQS_ENTRUST_PROV_VERSION}) ..."

		# Let's now build the OpenSSL library
		result=$( cd ${OQS_ENTRUST_PROV_DIR} && cmake --build _build 2>&1 )
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot build Entrust oqsprovider!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: Entrust oqsprovider successfully built]"
		fi

		# Let's now build the PROV library
		result=$( cd ${OQS_ENTRUST_PROV_DIR} && ${SUDO} cmake --install _build 2>&1 )
		if [ $? -gt 0 ] ; then
			echo "    [ERROR: Cannot install Entrust oqsprovider!]"
			echo
			echo "$result"
			echo
			exit 1
		else
			echo "    [SUCCESS: Entrust oqsprovider successfully installed on ${PRJ_DEST_DIR}]"
		fi
		echo "--> Removing Compressed Archive (${OQS_ENTRUST_PROV_OUTPUT})"
		[ -f "${OQS_ENTRUST_PROV_OUTPUT}" ] && rm "${OQS_ENTRUST_PROV_OUTPUT}"
		echo "    [SUCCESS: Archive Removed]"
	fi

	# Exits if we only wanted this component installed
	[ "x$3" = "xoqsprovider" ] && exit 0
fi

# Fetch the latest openssl-liboqs branch
if [ ! -d "${LIBPKI_DIR}" -o "$3" = "libpki" ] ; then

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

	# NOTE: Disabling the --enable-extra-checks support
	#       because of the deprecation of many functions in
	#       OpenSSL 3.x prevents the correct compilation
	#       of the library on Linux

	os=$(uname -s)
	EXTRA_CHECKS="--enable-extra-checks"
	if ! [ "x$os" = "xDarwin" ] ; then
		EXTRA_CHECKS=
	fi

	LIBPKI_COMMON_PARAMS="\
		--prefix=${PRJ_DEST_DIR} \
		--with-openssl-prefix=${PRJ_DEST_DIR} \
		--disable-composite \
		--enable-ocsprov \
		--enable-oqsprov \
		${EXTRA_CHECKS}"
	
	# Execute the build
	echo "--> Building LibPKI (Debug Mode: ${DEBUG_MODE})"
	if [ "${DEBUG_MODE}" = "NO" ] ; then
		result=$(cd ${LIBPKI_DIR} && \
		   	./configure \
				${LIBPKI_COMMON_PARAMS}
				2>&1 )
	else
		result=$(cd ${LIBPKI_DIR} && \
		   	./configure \
				${LIBPKI_COMMON_PARAMS} \
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

	result=$( cd ${LIBPKI_DIR} && \
		make 2>&1 > libpki_build_log.txt && \
		${SUDO} make install 2>&1 > libpki_install_log.txt )
	if [ $? -gt 0 ] ; then
		echo "    [ERROR: Cannot install LibPKI (branch: ${LIBPKI_VERSION}) on ${PRJ_DEST_DIR}]"
		echo
		echo "$result"
		echo
		exit 1
	else
		echo "    [SUCCESS: LibPKI (branch: ${LIBPKI_VERSION}) successfully installed on ${PRJ_DEST_DIR}]"
	fi

	cd ..

	# Exits if we only wanted this component installed
	[ "x$3" = "xlibpki" ] && exit 0
fi

# Updates the release number
# result=$( ${SUDO} echo -E -n "${RELEASE}" > "${PRJ_DEST_DIR}/LIBPKI_PQC_RELEASE" )

exit 0
