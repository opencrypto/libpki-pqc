/* BEGIN: composite_amenth.c */

// Composite Crypto authentication methods.
// (c) 2021 by Massimiliano Pala

#include "composite_ameth.h"

// ===============
// Data Structures
// ===============

// Definition from pem_pkey.c
struct X509_pubkey_st {
    X509_ALGOR *algor;
    ASN1_BIT_STRING *public_key;
    EVP_PKEY *pkey;
};

#include "composite_local.h"

// ======================
// MACRO & Other Oddities
// ======================

#define DEBUG(args...) \
  { fprintf(stderr, "[%s:%d] %s() - ", __FILE__, __LINE__, __func__) ; \
    fprintf(stderr, ## args) ; fprintf(stderr,"\n") ; fflush(stderr); }

// Retuurns a COPY of the stack
STACK_OF(EVP_PKEY) * COMPOSITE_KEY_sk_get1(COMPOSITE_KEY * key) {

  EVP_PKEY * tmp_pkey = NULL;
    // Pointer for the Data Structure

  STACK_OF(EVP_PKEY) * ret_sk = NULL;
    // Return Pointer

  // Input checks
  if (!key) return NULL;

  // Allocates the Stack
  if ((ret_sk = sk_EVP_PKEY_new_null()) == NULL)
    return NULL;

  for (int i = 0; i < COMPOSITE_KEY_num(key); i++) {

    if ((tmp_pkey = COMPOSITE_KEY_get0(key, i)) == NULL)
      goto err;
    
    if (!sk_EVP_PKEY_push(ret_sk, EVP_PKEY_dup(tmp_pkey)))
      goto err;
  }

  // All done
  return ret_sk;

err:

    if (ret_sk) {
      // Let's POP from the STACK but
      // no need to free the item's memory
      while(sk_EVP_PKEY_pop((STACK_OF(EVP_PKEY) *)ret_sk));
      sk_EVP_PKEY_free((STACK_OF(EVP_PKEY) *)ret_sk);
    }

    return NULL;
}

// ==============================
// EVP_PKEY_ASN1_METHOD Functions
// ==============================

// Implemented
static int pub_decode(EVP_PKEY *pk, X509_PUBKEY *pub) {

  // Strategy:
  //
  // Get the COMPOSITE_KEY and decode each EVP_PKEY from
  // each of the X509_PUBKEY that is encoded in ASN1_OCTET_STRING
  // from the generic sequence
  
  EVP_PKEY * tmp_pkey = NULL;
    // Containers for the different
    // encodings of the components

  X509_PUBKEY * tmp_pub = NULL;
    // Pointer to individual components
    // X509_PUBKEY structure

  STACK_OF(ASN1_TYPE) *sk = NULL;
    // Stack of ASN1_OCTET_STRINGs

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the Composite Key
    // (just a STACK_OF(EVP_PKEY))

  ASN1_TYPE * aType = NULL;
    // ASN1 generic wrapper

  ASN1_OCTET_STRING aOctetStr;
    // Temp Octet Pointer

  // Input Checking
  if (!pk || !pub) return 0;

  // Let's use the aOctetStr to avoid the internal
  // p8 pointers to be modified
  aOctetStr.data = pub->public_key->data;
  aOctetStr.length = pub->public_key->length;

  // Gets the Sequence from the data itself, error if
  // it is not a sequence of ASN1_OCTET_STRING
  if ((sk = d2i_ASN1_SEQUENCE_ANY(NULL, 
                (const unsigned char **)&aOctetStr.data,
                aOctetStr.length)) <= 0) {
    DEBUG("ERROR: Cannot ASN1 encode the Overall Composite Key");
    return 0;
  }

  // Allocates Memory for the inner key structure
  if ((comp_key = COMPOSITE_KEY_new_null()) == NULL) {
    DEBUG("ERROR: Memory Allocation");
    goto err;
  }

  for (int i = 0; i < sk_ASN1_TYPE_num(sk); i++) {

    if ((aType = sk_ASN1_TYPE_value(sk, i)) == NULL) {
      DEBUG("ERROR: Cannot get the ASN1_TYPE for key #%d", i);
      goto err;
    }

    // Checks we got the right type
    if ((aType->type != V_ASN1_SEQUENCE) ||
        (aType->value.sequence == NULL)) {
      DEBUG("ERROR: Multi-Key Encoding Format Error (expecting OCTET STRINGs) #%d", i);
      goto err;
    }

    // Sets the Pointers so that our original ones
    // are not moved (can cause memory issues)
    aOctetStr.data = aType->value.sequence->data;
    aOctetStr.length = aType->value.sequence->length;

    // Retrieve the EVP_PKEY from the ASN1_TYPE
    if ((tmp_pub = d2i_X509_PUBKEY(NULL, 
                      (const unsigned char **)&(aOctetStr.data),
                      (long)aOctetStr.length)) == NULL) {
      DEBUG("ERROR: Cannot Load X509_PUBKEY of Key #%d", i);
      goto err;
    }

    if ((tmp_pkey = X509_PUBKEY_get(tmp_pub)) == NULL) {
      DEBUG("ERROR: Cannot convert X509_PUBKEY of Key #%d", i);
      goto err;
    }

    // Here we can free the X509_PUBKEY structure
    X509_PUBKEY_free(tmp_pub);
    tmp_pub = NULL; // Safety

    // Add the component to the key
    if (!COMPOSITE_KEY_push(comp_key, tmp_pkey)) {
      DEBUG("ERROR: Cannot Add Component Key #%d to Multi-Key (Composite)", i);
      goto err;
    }

    // Adds a reference for mem management
    // EVP_PKEY_up_ref(tmp_pkey);
  }


  // Free the stack memory
  while ((aType = sk_ASN1_TYPE_pop(sk)) != NULL) {
    ASN1_TYPE_free(aType);
  } sk_ASN1_TYPE_free(sk);

  if (!EVP_PKEY_assign_COMPOSITE(pk, comp_key)) {
    DEBUG("ERROR: Cannot assign Composite Key to EVP_PKEY!");
    goto err;
  }

  return 1;

err:

  DEBUG("Function Failed.");

  // Free the Stack of ASN1_TYPE
  while ((sk != NULL) &&
        (aType = sk_ASN1_TYPE_pop(sk)) != NULL) {
    ASN1_TYPE_free(aType);
  } sk_ASN1_TYPE_free(sk);

  if (comp_key) COMPOSITE_KEY_free(comp_key);

  return 0;


  DEBUG("Not implemented, yet.");
  return 0;
}

// Implemented
static int pub_encode(X509_PUBKEY *pub, const EVP_PKEY *pk) {


  // Strategy:
  //
  // Get the COMPOSITE_KEY and encode each EVP_PKEY in a
  // separate X509_PUBKEY that is placed in an ASN1_OCTET_STRING
  // and then added to the generic SEQUENCE
  //
  // struct X509_pubkey_st {
  //    X509_ALGOR *algor;
  //    ASN1_BIT_STRING *public_key;
  //    EVP_PKEY *pkey;
  //  };
  //
  // Small Comments for ASN1_TYPE - The Structure is defined
  // in openssl/asn1.h and it is basically a type (int) and
  // a value (union). The value.sequence() is where you can
  // put the sequence to get encoded


  EVP_PKEY * tmp_pkey = NULL;
    // Containers for the different
    // encodings of the components

  X509_PUBKEY * tmp_pubkey = NULL;
    // Temp Structure for Privkey component

  STACK_OF(ASN1_TYPE) *sk = NULL;
    // Stack of ASN1_OCTET_STRINGs

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the Composite Key
    // (just a STACK_OF(EVP_PKEY))

  ASN1_OCTET_STRING * oct_string = NULL;
    // Output Buffer

  ASN1_TYPE * aType = NULL;
    // ASN1 generic wrapper

  unsigned char * buff = NULL;
  int buff_len = 0;
    // Temporary Storage for ASN1 data

  // Input Checking
  if (!pub || !pk) return 0;


  // First we should encode the parameters, however
  // in Composite, we do not have parameters, so we
  // can omit them entirely 

  // Gets the Key Bytes
  if ((comp_key = EVP_PKEY_get0(pk)) == NULL) {
    DEBUG("ERROR: Cannot get the Key Inner Structure");
    return 0;
  }
  
  if ((sk = sk_ASN1_TYPE_new_null()) == NULL) {
    DEBUG("ERROR: Memory Allocation");
    return 0;
  }

  // Gets the P8 info for each key and
  // adds it to the output stack
  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {

    // Get the component of the key
    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL) {
      DEBUG("ERROR: Cannot access [%d] component of the key", i);
      goto err;
    }

    if (tmp_pkey->ameth->pub_encode == NULL) {
      DEBUG("ERROR: Key %d of alg %d does not have a pub_encode ameth.",
          i, tmp_pkey->ameth->pkey_id);
      goto err;
    }

    if(!X509_PUBKEY_set(&tmp_pubkey, tmp_pkey)) {
      DEBUG("ERROR: Cannot set the PUBKEY for component #%d", i);
      goto err;
    }

    if ((buff_len = i2d_X509_PUBKEY(tmp_pubkey, &buff)) <= 0) {
      DEBUG("ERROR: Cannot ASN1 encode the [%d] component of the key", i);
      goto err;
    }

    if ((oct_string = ASN1_OCTET_STRING_new()) == NULL) {
      DEBUG("ERROR: Memory Allocation");
      goto err;
    }

    // This sets and transfer ownership
    ASN1_STRING_set0(oct_string, buff, buff_len);

    // Resets the pointer and length after ownership transfer
    buff = NULL; buff_len = 0;

    // Let's free the X509_PUBKEY structure
    X509_PUBKEY_free(tmp_pubkey);
    tmp_pubkey = NULL;

    // Let's now generate the ASN1_TYPE and add it to the stack
    if ((aType = ASN1_TYPE_new()) == NULL) {
      DEBUG("ERROR: Memory Allocation");
      goto err;
    }

    // Transfer Ownership to the aType structure
    ASN1_TYPE_set(aType, V_ASN1_SEQUENCE, oct_string);
    oct_string = NULL;

    // Adds the component to the stack
    if (!sk_ASN1_TYPE_push(sk, aType)) {
      DEBUG("ERROR: Cannot push the new Type");
      goto err;
    }

  }

  if ((buff_len = i2d_ASN1_SEQUENCE_ANY(sk, &buff)) <= 0) {
    DEBUG("ERROR: Cannot ASN1 encode the Overall Composite Key");
    goto err;
  }

  // Free the stack's memory
  while ((aType = sk_ASN1_TYPE_pop(sk)) == NULL) {
    ASN1_TYPE_free(aType);
  }
  sk_ASN1_TYPE_free(sk);
  sk = NULL;


  if (!X509_PUBKEY_set0_param(pub, OBJ_nid2obj(pk->ameth->pkey_id),
                              V_ASN1_UNDEF, NULL, buff, buff_len)) {
    DEBUG("ERROR: Cannot Set the Parameter")
    goto err;
  }

  return 1;

err:

  if (buff && buff_len >= 0) OPENSSL_secure_clear_free(buff, buff_len);

  if (oct_string) ASN1_OCTET_STRING_free(oct_string);

  if (aType) ASN1_TYPE_free(aType);

  if (sk) {
    while ((aType = sk_ASN1_TYPE_pop(sk)) == NULL) {
      ASN1_TYPE_free(aType);
    }
    sk_ASN1_TYPE_free(sk);
    sk = NULL;
  }

  DEBUG("Function Failed.");

  return 0;
}

// Implemented
static int pub_cmp(const EVP_PKEY *a, const EVP_PKEY *b) {

  // Strategy: We compare all keys from the two different
  // COMPOSITE_KEY within the EVP_PKEY ptr. If any difference,
  // we return !0

  COMPOSITE_KEY * comp_a = NULL;
  COMPOSITE_KEY * comp_b = NULL;
    // Pointers to inner data structures

  int ret = 0;
    // Return value

  // Input checks
  if (!a || !a->ameth || !b || !b->ameth) return -1;

  if (((comp_a = EVP_PKEY_get0(a)) == NULL) ||
      ((comp_b = EVP_PKEY_get0(b)) == NULL)) {

    return -1;
  }

  if (COMPOSITE_KEY_num(comp_a) != COMPOSITE_KEY_num(comp_b)) {
    return -1;
  }

  for (int i = 0; i < COMPOSITE_KEY_num(comp_b); i++) {
    
    // 'get0' returns the i-th EVP_PKEY, then we apply
    // the call to the two returned ones from a and b

    ret = EVP_PKEY_cmp(
              COMPOSITE_KEY_get0(comp_a, i),
              COMPOSITE_KEY_get0(comp_b, i));

    if (ret != 0) return ret;
  }

  return 0;
}

// Implemented
static int pub_print(BIO *out, const EVP_PKEY *pkey, int indent, ASN1_PCTX *pctx) {
  
  COMPOSITE_KEY * comp_key = NULL;

  if ((comp_key = EVP_PKEY_get0(pkey)) == NULL)
    return 0;

  if (!BIO_indent(out, indent, 128))
    return 0;

  BIO_printf(out, "Composite Public Multi-Key (%d Equivalent Keys):\n",
    COMPOSITE_KEY_num(comp_key));

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {

    EVP_PKEY * tmp_pkey = NULL;

    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL) {
      BIO_printf(out, "%*s", indent, "");
      BIO_printf(out, "Public Key Component #%d (UNKNOWN): <ERROR>\n", i);
      continue;
    }

    BIO_printf(out, "%*s", indent, "");
    BIO_printf(out, "[%d] Public Key Component (%s):\n",
      i, OBJ_nid2ln(tmp_pkey->ameth->pkey_id));

    if (tmp_pkey->ameth->pub_print) {
      tmp_pkey->ameth->pub_print(out, tmp_pkey, indent + 8, pctx);
    } else {
      BIO_printf(out, "        <NO TEXT FORMAT SUPPORT>\n");
    }
  }

  return 1;
}

// Implemented
static int priv_decode(EVP_PKEY *pk, const PKCS8_PRIV_KEY_INFO *p8) {

  // Strategy:
  //
  // GET the DER representation from the p8 info
  // then we can use the d21_ASN1_SEQUENCE_ANY() to get
  // the stack of P8.
  //
  // For each of the P8, we use the EVP_PKCS82PKEY() to
  // retrieve the corresponding PKEY. Once we have that,
  // we add it to the internal structure of the 'pk' param
  //
  // UPDATE: Let's look at using the auto type function,
  // which is crypto/asn1/d2i_pr.c:
  //
  //   EVP_PKEY *d2i_AutoPrivateKey(
  //                EVP_PKEY **a,
  //                const unsigned char **pp,
  //                long length)
  //
  // The P8 structure is quite simple and it is available
  // in includes/openssl/x509.h:
  //
  //   struct pkcs8_priv_key_info_st {
  //     ASN1_INTEGER *version;
  //     X509_ALGOR *pkeyalg;
  //     ASN1_OCTET_STRING *pkey;
  //     STACK_OF(X509_ATTRIBUTE) *attributes;
  //   };

  EVP_PKEY * tmp_pkey = NULL;
    // Containers for the different
    // encodings of the components

  STACK_OF(ASN1_TYPE) *sk = NULL;
    // Stack of ASN1_OCTET_STRINGs

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the Composite Key
    // (just a STACK_OF(EVP_PKEY))

  ASN1_TYPE * aType = NULL;
    // ASN1 generic wrapper

  ASN1_OCTET_STRING aOctetStr;
    // Temp Octet Pointer

  // Input Checking
  if (!p8 || !pk) return 0;

  // Let's use the aOctetStr to avoid the internal
  // p8 pointers to be modified
  aOctetStr.data = p8->pkey->data;
  aOctetStr.length = p8->pkey->length;

  // Gets the Sequence from the data itself, error if
  // it is not a sequence of ASN1_OCTET_STRING
  if ((sk = d2i_ASN1_SEQUENCE_ANY(NULL, 
                (const unsigned char **)&aOctetStr.data,
                aOctetStr.length)) <= 0) {
    DEBUG("ERROR: Cannot ASN1 encode the Overall Composite Key");
    return 0;
  }

  // Allocates Memory for the inner key structure
  if ((comp_key = COMPOSITE_KEY_new_null()) == NULL) {
    DEBUG("ERROR: Memory Allocation");
    goto err;
  }

  for (int i = 0; i < sk_ASN1_TYPE_num(sk); i++) {

    if ((aType = sk_ASN1_TYPE_value(sk, i)) == NULL) {
      DEBUG("ERROR: Cannot get the ASN1_TYPE for key #%d", i);
      goto err;
    }

    // Checks we got the right type
    if ((aType->type != V_ASN1_SEQUENCE) ||
        (aType->value.sequence == NULL)) {
      DEBUG("ERROR: Multi-Key Encoding Format Error (expecting OCTET STRINGs) #%d", i);
      goto err;
    }

    // Sets the Pointers so that our original ones
    // are not moved (can cause memory issues)
    aOctetStr.data = aType->value.sequence->data;
    aOctetStr.length = aType->value.sequence->length;

    // Retrieve the EVP_PKEY from the ASN1_TYPE
    if ((tmp_pkey = d2i_AutoPrivateKey(NULL, 
                      (const unsigned char **)&(aOctetStr.data),
                      (long)aOctetStr.length)) == NULL) {
      DEBUG("ERROR: Cannot Load Component Key #%d", i);
      goto err;
    }

    // Add the component to the key
    if (!COMPOSITE_KEY_push(comp_key, tmp_pkey)) {
      DEBUG("ERROR: Cannot Add Component Key #%d to Multi-Key (Composite)", i);
      goto err;
    }
  }


  // Free the stack memory
  while ((aType = sk_ASN1_TYPE_pop(sk)) != NULL) {
    ASN1_TYPE_free(aType);
  } sk_ASN1_TYPE_free(sk);

  DEBUG("Assigning comp_key to pk");

  if (!EVP_PKEY_assign_COMPOSITE(pk, comp_key)) {
    DEBUG("ERROR: Cannot assign Composite Key to EVP_PKEY!");
    goto err;
  }

  DEBUG("Key Decoded Successfully: pk = %p, comp_key = %p, pk->pkey->ptr = %p",
    pk, comp_key, pk->pkey.ptr);

  return 1;

err:

  DEBUG("Function Failed.");

  // Free the Stack of ASN1_TYPE
  while ((sk != NULL) &&
        (aType = sk_ASN1_TYPE_pop(sk)) != NULL) {
    ASN1_TYPE_free(aType);
  } sk_ASN1_TYPE_free(sk);

  if (comp_key) COMPOSITE_KEY_free(comp_key);

  return 0;

}

// Implemented
static int priv_encode(PKCS8_PRIV_KEY_INFO *p8, const EVP_PKEY *pk) {

  // Strategy:
  //
  // GET the DER representation of the different keys
  // by using the same function EVP_PKEY2PKCS8(pkey),
  // then you can use the PKCS8_pkey_get0() to get the
  // binary representation (ASN1_OCTET_STRING)
  // put them into the p8/
  //
  // Small Comments for ASN1_TYPE - The Structure is defined
  // in openssl/asn1.h and it is basically a type (int) and
  // a value (union). The value.sequence() is where you can
  // put the sequence to get encoded

  EVP_PKEY * tmp_pkey = NULL;
    // Containers for the different
    // encodings of the components

  PKCS8_PRIV_KEY_INFO * tmp_pkey_info = NULL;
    // Temp Structure for Privkey component

  STACK_OF(ASN1_TYPE) *sk = NULL;
    // Stack of ASN1_OCTET_STRINGs

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the Composite Key
    // (just a STACK_OF(EVP_PKEY))

  ASN1_OCTET_STRING * oct_string = NULL;
    // Output Buffer

  ASN1_TYPE * aType = NULL;
    // ASN1 generic wrapper

  unsigned char * buff = NULL;
  int buff_len = 0;
    // Temporary Storage for ASN1 data

  unsigned char * tot_buff = NULL;
  unsigned char * tmp_pnt = NULL;
  int tot_buff_len = 0;
    // Temporary Storage for ASN1 data

  // ASN1_STRING seq;
    // Final Storage for ASN1 data


  // Input Checking
  if (!p8 || !pk) return 0;

  // Gets the Key Bytes
  if ((comp_key = EVP_PKEY_get0(pk)) == NULL) {
    DEBUG("ERROR: Cannot get the Key Inner Structure");
    return 0;
  }
  
  if ((sk = sk_ASN1_TYPE_new_null()) == NULL) {
    DEBUG("ERROR: Memory Allocation");
    return 0;
  }

  // Gets the P8 info for each key and
  // adds it to the output stack
  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {

    // Get the component of the key
    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL) {
      DEBUG("ERROR: Cannot access [%d] component of the key", i);
      goto err;
    }

    if ((tmp_pkey_info = EVP_PKEY2PKCS8(tmp_pkey)) == NULL) {
      DEBUG("ERROR: Cannot generate PKCS8 for [%d] component of the key", i);
      goto err;
    }

    // NOTE: buff must be set to NULL, otherwise OpenSSL
    // thinks there is an already allocated buffer and
    // writes to it and moves the pointer at the end
    buff = NULL;

    // Generates the DER encoding of the component
    if ((buff_len = i2d_PKCS8_PRIV_KEY_INFO(tmp_pkey_info, &buff)) <= 0) {
      DEBUG("ERROR: Cannot ASN1 encode the [%d] component of the key", i);
      goto err;
    }

    if ((oct_string = ASN1_OCTET_STRING_new()) == NULL) {
      DEBUG("ERROR: Memory Allocation");
      goto err;
    }

    // This sets and transfer ownership
    ASN1_STRING_set0(oct_string, buff, buff_len);

    // Resets the pointer and length after ownership transfer
    buff = NULL; buff_len = 0;

    // Let's free the X509_PUBKEY structure
    PKCS8_PRIV_KEY_INFO_free(tmp_pkey_info);
    tmp_pkey_info = NULL;

    // Let's now generate the ASN1_TYPE and add it to the stack
    if ((aType = ASN1_TYPE_new()) == NULL) {
      DEBUG("ERROR: Memory Allocation");
      goto err;
    }

    // Transfer Ownership to the aType structure
    ASN1_TYPE_set(aType, V_ASN1_SEQUENCE, oct_string);
    oct_string = NULL;

    // Adds the component to the stack
    if (!sk_ASN1_TYPE_push(sk, aType)) {
      DEBUG("ERROR: Cannot push the new Type");
      goto err;
    }

  }

  buff = NULL;
  if ((buff_len = i2d_ASN1_SEQUENCE_ANY(sk, &buff)) <= 0) {
    DEBUG("ERROR: Cannot ASN1 encode the Overall Composite Key");
    goto err;
  }

  // Free the stack's memory
  while ((aType = sk_ASN1_TYPE_pop(sk)) == NULL) {
    ASN1_TYPE_free(aType);
  }
  sk_ASN1_TYPE_free(sk);
  sk = NULL;

  if (!PKCS8_pkey_set0(p8, OBJ_nid2obj(pk->ameth->pkey_id), 
                       0, /* V_ASN1_UNDEF */ V_ASN1_NULL, NULL, buff, buff_len)) {
    DEBUG("ERROR: Cannot set the P8 key contents");
    goto err;
  }

  return 1;

err:

  DEBUG("Function Failed.");

  if (buff && buff_len >= 0) OPENSSL_secure_clear_free(buff, buff_len);

  if (oct_string) ASN1_OCTET_STRING_free(oct_string);

  if (sk) {
    while ((aType = sk_ASN1_TYPE_pop(sk)) == NULL) {
      ASN1_TYPE_free(aType);
    }
    sk_ASN1_TYPE_free(sk);
    sk = NULL;
  }

  return 0;

}

// Implemented
static int priv_print(BIO *out, const EVP_PKEY *pkey, int indent, ASN1_PCTX *pctx) {

  COMPOSITE_KEY * comp_key = NULL;

  if ((comp_key = EVP_PKEY_get0(pkey)) == NULL)
    return 0;

  if (!BIO_indent(out, indent, 128))
    return 0;

  BIO_printf(out, "Composite Multi-Key (%d Equivalent Keys):\n",
    COMPOSITE_KEY_num(comp_key));

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {

    EVP_PKEY * tmp_pkey = NULL;

    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL) {
      BIO_printf(out, "    Key Component #%d (UNKNOWN): <ERROR>\n", i);
      continue;
    }

    BIO_printf(out, "    [%d] Key Component (%s):\n",
      i, OBJ_nid2ln(tmp_pkey->ameth->pkey_id));

    if (tmp_pkey->ameth->pub_print) {
      tmp_pkey->ameth->pub_print(out, tmp_pkey, indent + 8, pctx);
    } else {
      BIO_printf(out, "        <NO TEXT FORMAT SUPPORT>\n");
    }
  }

  return 1;
}

// Implemented
static int pkey_size(const EVP_PKEY *pk) {

  int ret = 0;
    // Return Value

  int key_num = 0;
    // Index for cycling across keys

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the inner structure

  EVP_PKEY * pkey = NULL;
    // Individual components keys

  // Input Check
  if (!pk || !pk->ameth) return 0;

  // Gets the Composite Key
  if ((comp_key = EVP_PKEY_get0(pk)) == NULL)
    return 0;

  key_num = COMPOSITE_KEY_num(comp_key);
  for (int i = 0; i < key_num; i++) {

    if ((pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL) {
      DEBUG("ERROR: Cannot get low-level Composite Key Bits");
      return 0;
    }
    ret += EVP_PKEY_size(pkey);
  }

  return ret;
}

// Implemented
static int pkey_bits(const EVP_PKEY *pk) {

  COMPOSITE_KEY * comp_Key = NULL;
    // Composite Key pointer

  // Input Checks
  if (pk == NULL) return 0;

  if ((comp_Key = EVP_PKEY_get0(pk)) == NULL) {
    DEBUG("ERROR: Cannot retrieve the Composite Key.");
    return 0;
  }

  // Gets the Bits from the COMPOSITE_KEY
  return COMPOSITE_KEY_bits(comp_Key);
}

// Implemented
static int pkey_security_bits(const EVP_PKEY *pk) {

  // Strategy:
  //
  // For Alternative Keys (OR logic Operation),
  // we should report the minimum sec_bits level
  // as any of the keys can be used.
  //
  // For Combined Keys (AND logic Operation),
  // we should report the maximum sec_bits level
  // as all of the keys must be used.

  int sec_bits = INT_MAX;
    // Security Bits, we start with
    // the max value and return the lowest

  COMPOSITE_KEY * comp_key = NULL;
    // Pointer to the inner data structure

  // Input Checks
  if (pk == NULL) return 0;

  if ((comp_key = EVP_PKEY_get0(pk)) == NULL) {
    DEBUG("ERROR: Cannot retrieve the Composite Key.");
    return 0;
  }

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {

    EVP_PKEY * tmp_pkey = COMPOSITE_KEY_get0(comp_key, i);

    int tmp_pkey_sec_bits = INT_MAX;

    if (tmp_pkey && tmp_pkey->ameth->pkey_security_bits) {
      // Checks if it is composite (OR) and use the lowest
      // of the current or pkey values
      tmp_pkey_sec_bits = 
          tmp_pkey->ameth->pkey_security_bits(tmp_pkey);
    }

    // If the current sec_bits is larger, let's get the
    // new (smaller) value
    sec_bits > tmp_pkey_sec_bits ? 
      sec_bits = tmp_pkey_sec_bits : sec_bits;
  }

  // If there are no components, we return '0'
  if (sec_bits == INT_MAX) return 0;

  // All Done.
  return sec_bits;
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
static void pkey_free(EVP_PKEY *pk) {

  // Purpose: free the algorithm-specific
  // data structure


  COMPOSITE_KEY * comp_key = NULL;
    // Composite Key Pointer

  // Input Validation
  if (!pk || !pk->ameth) return;

  // Gets the Key Bytes
  if ((comp_key = EVP_PKEY_get0(pk)) == NULL) {
    DEBUG("ERROR: Cannot get the Key Inner Structure");
    return;
  }

  DEBUG("ERROR: MUST CHECK THIS LINE -- MEMORY ERROR!");
  DEBUG("ERROR: When properly running COMPOSITE_KEY_free() we got a memory issue, deferring.");
  // Clears the Key and Frees the memory
  // COMPOSITE_KEY_free(comp_key);

  // All Done.
  return;
}

// Implemented
static int pkey_ctrl(EVP_PKEY *pkey, int op, long arg1, void *arg2) {

  /*
  # define ASN1_PKEY_CTRL_PKCS7_SIGN       0x1
  # define ASN1_PKEY_CTRL_PKCS7_ENCRYPT    0x2
  # define ASN1_PKEY_CTRL_DEFAULT_MD_NID   0x3
  # define ASN1_PKEY_CTRL_CMS_SIGN         0x5
  # define ASN1_PKEY_CTRL_CMS_ENVELOPE     0x7
  # define ASN1_PKEY_CTRL_CMS_RI_TYPE      0x8
  */

  DEBUG("ASN1 METHOD: PKEY CTRL - EVP_PKEY is HERE.");

  switch (op) {

    case ASN1_PKEY_CTRL_PKCS7_SIGN:
    case ASN1_PKEY_CTRL_CMS_SIGN: {
      DEBUG("Signing Operation (%d)", op);
    } break;

    case ASN1_PKEY_CTRL_PKCS7_ENCRYPT:
    case ASN1_PKEY_CTRL_CMS_ENVELOPE: {
      DEBUG("Encryption Operation (%d)", op);
    } break;

    case ASN1_PKEY_CTRL_CMS_RI_TYPE: {
      DEBUG("Other CMS Operations (%d)", op);
    } break;

    case ASN1_PKEY_CTRL_DEFAULT_MD_NID: {
      DEBUG("Default MD NID (%d) (arg1 = %ld, arg2 = %d)",
        op, arg1, *(int *)arg2);
      DEBUG("Returning NID_sha512 as default");

      // Let's return NID_sha512 as default
      *(int *)arg2 = NID_sha512;
    } break;

    default: {
      DEBUG("Unknown Operation [%d] (arg1 = %ld)", op, arg1);
      return 0;
    }

  }

  DEBUG("Not implemented, yet.");
  return 1;
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

    X509_ALGOR_set0(alg1, OBJ_nid2obj(NID_composite), V_ASN1_UNDEF, NULL);

    if (alg2 != NULL)
       X509_ALGOR_set0(alg2, OBJ_nid2obj(NID_composite), V_ASN1_UNDEF, NULL);

    // Algorithm identifier set: carry on as normal
    return 3;    

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

  COMPOSITE_KEY * comp_key = NULL;

  if (!pkey) return 0;

  if ((comp_key = EVP_PKEY_get0(pkey)) == NULL)
    return 0;

  if (COMPOSITE_KEY_num(comp_key) < 1)
    return 0;

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {
    EVP_PKEY * tmp_pkey = NULL;

    // If we cannot get any component, we have a problem
    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL)
      return 0;

    // We need an ASN1 method
    if (!tmp_pkey->ameth) return 0;

    // If the component has the check, let's perform
    // it on the single component and return 0 if any
    // of these fail at the component level
    if (tmp_pkey->ameth->pkey_check) {
      if (tmp_pkey->ameth->pkey_check(tmp_pkey) == 0) {
        DEBUG("ERROR: Key Check failed for"
            "Composite Key Component #%d", i)
        return 0;
      }
    }
  }

  DEBUG("Key Check Completed Successfully!");

  return 1;
}

// Not Implemented
static int pkey_public_check(const EVP_PKEY *pkey) {
  
  COMPOSITE_KEY * comp_key = NULL;

  if (!pkey) return 0;

  if ((comp_key = EVP_PKEY_get0(pkey)) == NULL)
    return 0;

  if (COMPOSITE_KEY_num(comp_key) < 1)
    return 0;

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {
    EVP_PKEY * tmp_pkey = NULL;

    // If we cannot get any component, we have a problem
    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL)
      return 0;

    // We need an ASN1 method
    if (!tmp_pkey->ameth) return 0;

    // If the component has the check, let's perform
    // it on the single component and return 0 if any
    // of these fail at the component level
    if (tmp_pkey->ameth->pkey_public_check) {
      if (tmp_pkey->ameth->pkey_public_check(tmp_pkey) == 0) {
        DEBUG("ERROR: Public Key Check failed for"
            "Composite Key Component #%d", i)
        return 0;
      }
    }
  }


  DEBUG("Public Key Check Completed Successfully!");

  return 1;
}

// Not Implemented
static int pkey_param_check(const EVP_PKEY *pkey) {

  COMPOSITE_KEY * comp_key = NULL;

  if (!pkey) return 0;

  if ((comp_key = EVP_PKEY_get0(pkey)) == NULL)
    return 0;

  if (COMPOSITE_KEY_num(comp_key) < 1)
    return 0;

  for (int i = 0; i < COMPOSITE_KEY_num(comp_key); i++) {
    EVP_PKEY * tmp_pkey = NULL;

    // If we cannot get any component, we have a problem
    if ((tmp_pkey = COMPOSITE_KEY_get0(comp_key, i)) == NULL)
      return 0;

    // We need an ASN1 method
    if (!tmp_pkey->ameth) return 0;

    // If the component has the check, let's perform
    // it on the single component and return 0 if any
    // of these fail at the component level
    if (tmp_pkey->ameth->pkey_param_check) {
      if (tmp_pkey->ameth->pkey_param_check(tmp_pkey) == 0) {
        DEBUG("ERROR: Public Key Check failed for"
            "Composite Key Component #%d", i)
        return 0;
      }
    }
  }

  DEBUG("Parameters Check Completed Successfully!");

  return 1;
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


/* END: composite_amenth.c */