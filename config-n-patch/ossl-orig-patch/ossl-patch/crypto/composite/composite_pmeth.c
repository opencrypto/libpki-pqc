// Composite Crypto authentication methods.
// (c) 2021 by Massimiliano Pala

#include "composite_pmeth.h"

// ===============
// Data Structures
// ===============

// ======================
// MACRO & Other Oddities
// ======================

#define DEBUG(args...) \
  fprintf(stderr, "[%s:%d] %s() - ", __FILE__, __LINE__, __func__) && \
  fprintf(stderr, ## args) && fflush(stderr)

// =========================
// EVP_PKEY_METHOD Functions
// =========================

// Not Implemented
static int init(EVP_PKEY_CTX *ctx) {
  /*
     RSA_PKEY_CTX *rctx = OPENSSL_zalloc(sizeof(*rctx));

    if (rctx == NULL)
        return 0;
    rctx->nbits = 2048;
    rctx->primes = RSA_DEFAULT_PRIME_NUM;
    if (pkey_ctx_is_pss(ctx))
        rctx->pad_mode = RSA_PKCS1_PSS_PADDING;
    else
        rctx->pad_mode = RSA_PKCS1_PADDING;
    // Maximum for sign, auto for verify
    rctx->saltlen = RSA_PSS_SALTLEN_AUTO;
    rctx->min_saltlen = -1;
    ctx->data = rctx;
    ctx->keygen_info = rctx->gentmp;
    ctx->keygen_info_count = 2;

    return 1;
  */
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int copy(EVP_PKEY_CTX * dst,
                EVP_PKEY_CTX * src) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static void cleanup(EVP_PKEY_CTX * ctx) {
  DEBUG("Not implemented, yet.");
  return;
}

// Not Implemented
static int paramgen_init(EVP_PKEY_CTX * ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int paramgen(EVP_PKEY_CTX * ctx,
                    EVP_PKEY     * pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int keygen_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int keygen(EVP_PKEY_CTX *ctx, EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int sign_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int sign(EVP_PKEY_CTX        * ctx, 
                               unsigned char       * sig,
                               size_t              * siglen,
                               const unsigned char * tbs,
                               size_t                tbslen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int verify_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int verify(EVP_PKEY_CTX        * ctx,
                                 const unsigned char * sig,
                                 size_t                siglen,
                                 const unsigned char * tbs,
                                 size_t                tbslen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int verify_recover_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int verify_recover(EVP_PKEY_CTX        * ctx,
                          unsigned char       * rout,
                          size_t              * routlen,
                          const unsigned char * sig,
                          size_t                siglen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int signctx_init(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int signctx (EVP_PKEY_CTX *ctx, unsigned char *sig, size_t *siglen, EVP_MD_CTX *mctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}


// Implemented
static int verifyctx_init(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int verifyctx (EVP_PKEY_CTX *ctx, const unsigned char *sig, int siglen, EVP_MD_CTX *mctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int encrypt_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int encrypt(EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int decrypt_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int decrypt(EVP_PKEY_CTX *ctx, unsigned char *out, size_t *outlen, const unsigned char *in, size_t inlen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int derive_init(EVP_PKEY_CTX *ctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int derive(EVP_PKEY_CTX *ctx, unsigned char *key, size_t *keylen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int ctrl(EVP_PKEY_CTX *ctx, int type, int p1, void *p2) {
  /*
  switch (type) {
    case EVP_PKEY_CTRL_MD:
        // NULL allowed as digest
        if (p2 == NULL)
            return 1;
        // accept SHA512 as digest for CMS
        if (*(int*)p2 == NID_sha512) {
               return 1;
        }
        ECerr(EC_F_PKEY_COMPOSITE_CTRL, EC_R_WRONG_DIGEST);
        return 0;

    case EVP_PKEY_CTRL_DIGESTINIT:
        return 1;

    case EVP_PKEY_CTRL_CMS_SIGN:
        return 1;
    }
    ECerr(EC_F_PKEY_COMPOSITE_CTRL, ERR_R_FATAL);
    return -2;
    */
  DEBUG("Not implemented, yet.");
  return -1;
}

// Not Implemented
static int ctrl_str(EVP_PKEY_CTX *ctx, const char *type, const char *value) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// ===================
// OpenSSL 1.1.x+ Only
// ===================

// Implemented
static int digestsign(EVP_MD_CTX *ctx, unsigned char *sig, size_t *siglen, const unsigned char *tbs, size_t tbslen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int digestverify(EVP_MD_CTX *ctx, const unsigned char *sig, size_t siglen, const unsigned char *tbs, size_t tbslen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int check(EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int public_check(EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_check(EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int digest_custom(EVP_PKEY_CTX *ctx, EVP_MD_CTX *mctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

