// Composite Crypto authentication methods.
// (c) 2021 by Massimiliano Pala
//
// This file contains the definitions for the EVP_PKEY_METHOD that implements:
//
//     Composite Crypto (OR Logic)
//
// the corresponding functions are defined in composite_ameth.c

#include <stdio.h>
#include "internal/cryptlib.h"
#include <openssl/x509.h>
#include "crypto/asn1.h"
#include "crypto/evp.h"


#ifndef OPENSSL_COMPOSITE_PKEY_METH_H
#define OPENSSL_COMPOSITE_PKEY_METH_H

// ===============
// Data Structures
// ===============

// ==========================
// EVP_PKEY_METHOD Prototypes
// ==========================

// Not Implemented
static int init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int copy(EVP_PKEY_CTX * dst,
                EVP_PKEY_CTX * src);

// Not Implemented
static void cleanup(EVP_PKEY_CTX * ctx);

// Not Implemented
static int paramgen_init(EVP_PKEY_CTX * ctx);

// Not Implemented
static int paramgen(EVP_PKEY_CTX * ctx,
                    EVP_PKEY     * pkey);

// Not Implemented
static int keygen_init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int keygen(EVP_PKEY_CTX *ctx, EVP_PKEY *pkey);

// Implemented
static int sign_init(EVP_PKEY_CTX *ctx);

// Implemented
static int sign(EVP_PKEY_CTX        * ctx, 
                               unsigned char       * sig,
                               size_t              * siglen,
                               const unsigned char * tbs,
                               size_t                tbslen);

// Implemented
static int verify_init(EVP_PKEY_CTX *ctx);

// Implemented
static int verify(EVP_PKEY_CTX        * ctx,
                                 const unsigned char * sig,
                                 size_t                siglen,
                                 const unsigned char * tbs,
                                 size_t                tbslen);

// Not Implemented
static int verify_recover_init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int verify_recover(EVP_PKEY_CTX        * ctx,
                          unsigned char       * rout,
                          size_t              * routlen,
                          const unsigned char * sig,
                          size_t                siglen);

// Implemented
static int signctx_init(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);

// Implemented
static int signctx (EVP_PKEY_CTX *ctx, unsigned char *sig, size_t *siglen, EVP_MD_CTX *mctx);

// Implemented
static int verifyctx_init(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);

// Implemented
static int verifyctx (EVP_PKEY_CTX *ctx, const unsigned char *sig, int siglen, EVP_MD_CTX *mctx);

// Not Implemented
static int encrypt_init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int encrypt(EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen);

// Not Implemented
static int decrypt_init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int decrypt(EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen);

// Not Implemented
static int derive_init(EVP_PKEY_CTX *ctx);

// Not Implemented
static int derive(EVP_PKEY_CTX *ctx, unsigned char *key, size_t *keylen);

// Implemented
static int ctrl(EVP_PKEY_CTX *ctx, int type, int p1, void *p2);

// Not Implemented
static int ctrl_str(EVP_PKEY_CTX *ctx, const char *type, const char *value);

// ===================
// OpenSSL 1.1.x+ Only
// ===================

// Implemented
static int digestsign(EVP_MD_CTX *ctx, unsigned char *sig, size_t *siglen, const unsigned char *tbs, size_t tbslen);

// Implemented
static int digestverify(EVP_MD_CTX *ctx, const unsigned char *sig, size_t siglen, const unsigned char *tbs, size_t tbslen);

// Not Implemented
static int check(EVP_PKEY *pkey);

// Not Implemented
static int public_check(EVP_PKEY *pkey);

// Not Implemented
static int param_check(EVP_PKEY *pkey);

// Implemented
static int digest_custom(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);


// ======================
// PKEY Method Definition
// ======================
//
// The Definition of the EVP_PKEY_METHOD is a typedef
// of the evp_pkey_method_st from:
//
// OPENSSL_SRC/crypto/evp/evp_locl.h (OPENSS_VERSION <= 1.1.0 or prior)
// OPENSSL_SRC/crypto/include/internal/evp_int.h (OPENSSL_VERSION >= 1.1.X+)

const EVP_PKEY_METHOD composite_pkey_meth = {
    NID_composite,  // int pkey_id;
    EVP_PKEY_FLAG_SIGCTX_CUSTOM, // int flags; (EVP_PKEY_FLAG_SIGCTX_CUSTOM
    init,           // int (*init)(EVP_PKEY_CTX *ctx);
    copy,           // int (*copy)(EVP_PKEY_CTX *dst, EVP_PKEY_CTX *src);
    cleanup,        // void (*cleanup)(EVP_PKEY_CTX *ctx);
    paramgen_init,  // int (*paramgen_init)(EVP_PKEY_CTX *ctx);
    paramgen,       // int (*paramgen)(EVP_PKEY_CTX *ctx, EVP_PKEY *pkey);
    keygen_init,    // int (*keygen_init)(EVP_PKEY_CTX *ctx);
    keygen,         // int (*keygen)(EVP_PKEY_CTX *ctx, EVP_PKEY *pkey);
    sign_init,      // int (*sign_init) (EVP_PKEY_CTX *ctx);
    sign,           // int (*sign) (EVP_PKEY_CTX *ctx, unsigned char *sig, size_t *siglen, const unsigned char *tbs, size_t tbslen);
    verify_init,    // int (*verify_init) (EVP_PKEY_CTX *ctx);
    verify,         // int (*verify) (EVP_PKEY_CTX *ctx, const unsigned char *sig, size_t siglen, const unsigned char *tbs, size_t tbslen);
    verify_recover_init,  // int (*verify_recover_init) (EVP_PKEY_CTX *ctx);
    verify_recover, // int (*verify_recover) (EVP_PKEY_CTX *ctx, unsigned char *rout, size_t *routlen, const unsigned char *sig, size_t siglen);
    signctx_init,   // int (*signctx_init) (EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);
    signctx,        // int (*signctx) (EVP_PKEY_CTX *ctx, unsigned char *sig, size_t *siglen, EVP_MD_CTX *mctx);
    verifyctx_init, // int (*verifyctx_init) (EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);
    verifyctx,      // int (*verifyctx) (EVP_PKEY_CTX *ctx, const unsigned char *sig, int siglen, EVP_MD_CTX *mctx);
    encrypt_init,   // int (*encrypt_init) (EVP_PKEY_CTX *ctx);
    encrypt,        // int (*encrypt) (EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen);
    decrypt_init,   // int (*decrypt_init) (EVP_PKEY_CTX *ctx);
    decrypt,        // int (*decrypt) (EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen);
    derive_init,    // int (*derive_init) (EVP_PKEY_CTX *ctx);
    derive,         // int (*derive) (EVP_PKEY_CTX *ctx, unsigned char *key, size_t *keylen);
    ctrl,           // int (*ctrl) (EVP_PKEY_CTX *ctx, int type, int p1, void *p2);
    ctrl_str,       // int (*ctrl_str) (EVP_PKEY_CTX *ctx, const char *type, const char *value);
#if (OPENSSL_VERSION_NUMBER >= 0x10100000L)
    // These are only available on OpenSSL v1.1.X+ //
    digestsign,     // int (*digestsign) (EVP_MD_CTX *ctx, unsigned char *sig, size_t *siglen, const unsigned char *tbs, size_t tbslen);
    digestverify,   // int (*digestverify) (EVP_MD_CTX *ctx, const unsigned char *sig, size_t siglen, const unsigned char *tbs, size_t tbslen);
    check,          // int (*check) (EVP_PKEY *pkey);
    public_check,   // int (*public_check) (EVP_PKEY *pkey);
    param_check,    // int (*param_check) (EVP_PKEY *pkey);
    digest_custom   // int (*digest_custom) (EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx);
#endif
};

#endif // OPENSSL_COMPOSITE_PKEY_METH_H
