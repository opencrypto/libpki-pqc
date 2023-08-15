# libpki-pqc

Quick & Drafty tool for building the OQS OpenSSL and LibPKI w/ Support for Post-Quantum Algorithms - this is just an internal repo that might be useful for other developers and that is the only reason we are sharing it.

# Versions

The libpki-pqc package has been updated to support the latest version of LibOQS and its OpenSSL wrapper.
Specifically, the current version builds on top of LibOQS version 0.7.1 (Dec 2021) and the OpenSSL OQS
wrapper version 1.1.1m (Dec 2021)

# Usage
This is a quick tool we use to ease building LibPKI and OpenSSL w/ Open Quantum Safe support and an initial implementation for Composite Crypto.

To fetch and build the libraries and tools, you can run:
```
$ ./build.sh [ DEST_DIR ] [ LIBPKI_BRANCH ]
```
the script will fetch the liboqs repo and build that first. After installation it is the turn for the OQS OpenSSL's repo. After the openssl w/ OQS support is built and installed, the script fetches the libpki (libpki-oqs branch), builds it, and installs it in the same location. 

All compiled software will be installed in the directory that was specified (`DEST_DIR`). If not specified, the default
installation directory is `/opt/libpki-oqs`.

When the use of a specific branch from the LibPKI package is needed, you can specify any branch other than the default
`master` to download, compile, and install the code from the selected branch.

Please review the build.sh script and change the configuration there.

# Enabling Different OQS algorithms

In the config-n-patch/oqs-config inside the repo, you will find a YML config file (libpki-generate-template.yml) that you can use to generate support for different post-quantum algorithms in OpenSSL.

To use it, you edit and add/remove the options that are not needed in your environment and follow the procedures described in the OQS repo (https://github.com/open-quantum-safe/openssl) - see the code generation section from here (https://github.com/open-quantum-safe/openssl/wiki/Using-liboqs-algorithms-not-in-the-fork#code-generation).

# Enabling Composite Crypto (Besides OQS Composite Crypto Support)

In order to enable the use of Composite Crypto as a generic Algorithm OID and then use the PKEY creation to combine different Keys into your multi-key (Composite) one, you need to look into the config-n-patch/ossl_patch directory - there you will find the current skeleton for implementing the EVP_PKEY_METHOD and EVP_PKEY_ASN1_METHOD (and all pointers in different include files).

Remember that to enable the support for native OSSL Composite Crypto in LibPKI (i.e., to use 'pki-tool keygen -algorithm Composite -addkey tests/ec.key -addkey tests/rsa.key -addkey tests/falcon.key'), you need to use the '--enable-composite' flag when configuring the build. For example, to enable both OQS and Composite, you can use the following:

```
$ ./configure --prefix=<PREFIX> --enable-composite --enable-oqs
```

also, remember to turn off features you do not need - for example, if you do not need LDAP integration with the URL interface, simply disable it by using the '--disable-ldap'. The same goes for your Maria DB or other URL supported interfaces.

Enjoy Post-Quantum and Composite Crypto!

# Acknowledgments

A huge thanks goes to the Open Quantum Safe project and all its leaders, maintainers, and contributors. All this work for testing post-quantum algorithms and backward compatibility deployment options (Composite Crypto) could not be possible without the OQS.

Similarly, we thank the OpenSSL project and all its contributor since SSLEay... (remember the beginnings? fun times!)

Thank You! Thank You! Thank You!

Enjoy Open Source Software!
