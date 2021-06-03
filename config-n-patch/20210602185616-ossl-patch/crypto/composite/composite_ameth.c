// Composite Crypto authentication methods.
// (c) 2021 by Massimiliano Pala

#include "composite_ameth.h"

// ===============
// Data Structures
// ===============

// Composite Data Structure

typedef struct composite_crypto_key_st {
  int nid;
  int mode;
  STACK_OF(EVP_KEY) * sk_keys;
  EVP_MD_CTX * digest;
} EVP_COMPOSITE_CTX;

// ======================
// MACRO & Other Oddities
// ======================

#define DEBUG(args...) \
  fprintf(stderr, "[%s:%d] %s() - ", __FILE__, __LINE__, __func__) && \
  fprintf(stderr, ## args) && fflush(stderr)

/*
#define DEFINE_COMPOSITE_ITEM_SIGN(ALG, NID_ALG) \
static int composite_item_sign(EVP_MD_CTX *ctx, const ASN1_ITEM *it, void *asn,\
                         X509_ALGOR *alg1, X509_ALGOR *alg2,                   \
                         ASN1_BIT_STRING *str)                                 \
{                                                                              \
    // Set algorithm identifier.                                               \
    X509_ALGOR_set0(alg1, OBJ_nid2obj(NID_ALG), V_ASN1_UNDEF, NULL);           \
    if (alg2 != NULL)                                                          \
        X509_ALGOR_set0(alg2, OBJ_nid2obj(NID_ALG), V_ASN1_UNDEF, NULL);       \
    // Algorithm identifier set: carry on as normal                            \
    return 3;                                                                  \
}

#define DEFINE_COMPOSITE_SIGN_INFO_SET(ALG, NID_ALG) \
static int composite_siginfo_set(X509_SIG_INFO *siginf, const X509_ALGOR *alg,  \
                            const ASN1_STRING *sig)                              \
{                                                                                \
    X509_SIG_INFO_set(siginf, NID_sha512, NID_ALG, get_composite_pkey_security_bits(NID_ALG),\
                      X509_SIG_INFO_TLS);                                        \
    return 1;                                                                    \
}

int composite_pkey_ctrl(EVP_PKEY *pkey, int op, long arg1, void *arg2) {

   switch (op) {

   case ASN1_PKEY_CTRL_DEFAULT_MD_NID:
	*(int *)arg2 = NID_sha512;
	return 1;
   case ASN1_PKEY_CTRL_CMS_SIGN:
      if (arg1 == 0) {
            int snid, hnid;
            X509_ALGOR *alg1, *alg2;
            CMS_SignerInfo_get0_algs(arg2, NULL, NULL, &alg1, &alg2);
            if (alg1 == NULL || alg1->algorithm == NULL) {
                return -1;
	    }
            hnid = OBJ_obj2nid(alg1->algorithm);
            if (hnid == NID_undef) {
                return -1;
            }
            if (!OBJ_find_sigid_by_algs(&snid, hnid, EVP_PKEY_id(pkey))) {
                return -1;
            }
            X509_ALGOR_set0(alg2, OBJ_nid2obj(snid), V_ASN1_UNDEF, 0);
      }

      return 1;
   }
   ECerr(EC_F_PKEY_COMPOSITE_CTRL, ERR_R_FATAL);
   return 0;
}



static int composite_pkey_keygen(EVP_PKEY_CTX *ctx, EVP_PKEY *pkey);
static int composite_pkey_digestsign(EVP_MD_CTX *ctx, unsigned char *sig,
                               size_t *siglen, const unsigned char *tbs,
                               size_t tbslen);
static int composite_pkey_digestverify(EVP_MD_CTX *ctx, const unsigned char *sig,
                                 size_t siglen, const unsigned char *tbs,
                                 size_t tbslen);
static int composite_pkey_ctrl(EVP_PKEY_CTX *ctx, int type, int p1, void *p2);
{
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
}
*/

// ==============================
// EVP_PKEY_ASN1_METHOD Functions
// ==============================

// Implemented
static int pub_decode(EVP_PKEY *pk, X509_PUBKEY *pub) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pub_encode(X509_PUBKEY *pub, const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pub_cmp(const EVP_PKEY *a, const EVP_PKEY *b) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pub_print(BIO *out, const EVP_PKEY *pkey, int indent, ASN1_PCTX *pctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int priv_decode(EVP_PKEY *pk, const PKCS8_PRIV_KEY_INFO *p8inf) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int priv_encode(PKCS8_PRIV_KEY_INFO *p8, const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int priv_print(BIO *out, const EVP_PKEY *pkey, int indent, ASN1_PCTX *pctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pkey_size(const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pkey_bits(const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pkey_security_bits(const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_decode(EVP_PKEY *pkey, const unsigned char **pder, int derlen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_encode(const EVP_PKEY *pkey, unsigned char **pder) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_missing(const EVP_PKEY *pk) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_copy(EVP_PKEY *to, const EVP_PKEY *from) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int param_cmp(const EVP_PKEY *a, const EVP_PKEY *b) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int param_print(BIO *out, const EVP_PKEY *pkey, int indent, ASN1_PCTX *pctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int sig_print(BIO *out, const X509_ALGOR *sigalg, const ASN1_STRING *sig, int indent, ASN1_PCTX *pctx) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static void pkey_free(EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return;
}

// Implemented
static int pkey_ctrl(EVP_PKEY *pkey, int op, long arg1, void *arg2) {
  /*
  switch (op) {

   case ASN1_PKEY_CTRL_DEFAULT_MD_NID:
  *(int *)arg2 = NID_sha512;
  return 1;
   case ASN1_PKEY_CTRL_CMS_SIGN:
      if (arg1 == 0) {
            int snid, hnid;
            X509_ALGOR *alg1, *alg2;
            CMS_SignerInfo_get0_algs(arg2, NULL, NULL, &alg1, &alg2);
            if (alg1 == NULL || alg1->algorithm == NULL) {
                return -1;
      }
            hnid = OBJ_obj2nid(alg1->algorithm);
            if (hnid == NID_undef) {
                return -1;
            }
            if (!OBJ_find_sigid_by_algs(&snid, hnid, EVP_PKEY_id(pkey))) {
                return -1;
            }
            X509_ALGOR_set0(alg2, OBJ_nid2obj(snid), V_ASN1_UNDEF, 0);
      }

      return 1;
   }
   ECerr(EC_F_PKEY_COMPOSITE_CTRL, ERR_R_FATAL);
   return 0;
  */
  DEBUG("Not implemented, yet.");
  return 0;
}

// ============================
// Legacy Functions for old PEM
// ============================

// Not Implemented
static int old_priv_decode(EVP_PKEY *pkey, const unsigned char **pder, int derlen) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int old_priv_encode(const EVP_PKEY *pkey, unsigned char **pder) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// ==================================
// Custom ASN1 signature verification
// ==================================

// Implemented
static int item_verify(EVP_MD_CTX *ctx, const ASN1_ITEM *it, void *asn, X509_ALGOR *a, ASN1_BIT_STRING *sig, EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int item_sign(EVP_MD_CTX *ctx, const ASN1_ITEM *it, void *asn, X509_ALGOR *alg1, X509_ALGOR *alg2, ASN1_BIT_STRING *sig) {
    // X509_ALGOR_set0(alg1, OBJ_nid2obj(NID_ALG), V_ASN1_UNDEF, NULL);
    // if (alg2 != NULL)
    //    X509_ALGOR_set0(alg2, OBJ_nid2obj(NID_ALG), V_ASN1_UNDEF, NULL);
    // Algorithm identifier set: carry on as normal
    // return 3;    

  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int siginf_set(X509_SIG_INFO *siginf, const X509_ALGOR *alg, const ASN1_STRING *sig) {
  // X509_SIG_INFO_set(siginf, NID_sha512, NID_ALG, get_composite_pkey_security_bits(NID_ALG),
  //                    X509_SIG_INFO_TLS);                                        
  // return 1;
  DEBUG("Not implemented, yet.");
  return 0;
}

// ===================
// EVP Check Functions
// ===================

// Not Implemented
static int pkey_check(const EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int pkey_public_check(const EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int pkey_param_check(const EVP_PKEY *pkey) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// =================================
// Get/Set For Raw priv/pub key data
// =================================

// Not Implemented
static int set_priv_key(EVP_PKEY *pk, const unsigned char *priv, size_t len) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int set_pub_key(EVP_PKEY *pk, const unsigned char *pub, size_t len) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int get_priv_key(const EVP_PKEY *pk, unsigned char *priv, size_t *len) {
  DEBUG("Not implemented, yet.");
  return 0;
}

// Not Implemented
static int get_pub_key(const EVP_PKEY *pk, unsigned char *pub, size_t *len) {
  DEBUG("Not implemented, yet.");
  return 0;
}


