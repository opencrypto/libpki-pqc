# Post-Quantum and Composite Crypto
# Patch and Diff Tools for Automation
# (c) 2021 by Massimiliano Pala

NOW=$(date +%Y%m%d%H%M%S)
PRJ_NAME=libpki-pqc
PRJ_VER=$(libpki-config --version)
PRJ_ARCH=$(uname -m)
BASE_DIR=${PRJ_NAME}

# Builds the Package Structure
mkdir -p ${BASE_DIR}/DEBIAN
cat << EOF > ${BASE_DIR}/DEBIAN/control
Package: ${PRJ_NAME}
Version: ${PRJ_VER}
Section: custom
Priority: optional
Architecture: all
Essential: no
Installed-Size: 1024
Maintainer: OpenCA.Org
Description: Provides Post-Quantum LibPKI and OpenSSL
EOF

# Copies the binary files from the installed directory
mkdir -p ${BASE_DIR}/opt/${BASE_DIR} && \
  cp -rvf /opt/${BASE_DIR}/* ${BASE_DIR}/opt/${BASE_DIR}

# Builds the package
dpkg-deb --build ${BASE_DIR}

# Fixes the name
mv ${PRJ_NAME}.deb ${PRJ_NAME}-${PRJ_VER}_${PRJ_ARCH}.deb

# All Done
exit 0
