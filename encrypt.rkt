(module libtoxcore-racket/encrypt
  racket/base
; libtoxcore-racket/encrypt.rkt
(require ffi/unsafe
         ffi/unsafe/define
         "enums.rkt")

(provide (except-out (all-defined-out)
                     define-encrypt
                     _Tox-pointer))

(define-ffi-definer define-encrypt (ffi-lib "libtoxencryptsave"))

#|###################
 # type definitions #
 ################## |#

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

(define _Tox-pointer (_cpointer 'Tox))

(define-cstruct _Tox-Pass-Key
  ([salt _bytes]
   [key _bytes]))

(define TOX_PASS_SALT_LENGTH 32)
(define TOX_PASS_KEY_LENGTH 3)
(define TOX_PASS_ENCRYPTION_EXTRA_LENGTH 80)

#|
 # This "module" provides functions analogous to tox_load and tox_save in toxcore,
 # as well as functions for encryption of arbitrary client data (e.g. chat logs).
 #
 # It is conceptually organized into two parts. The first part are the functions
 # with "key" in the name. To use these functions, first derive an encryption key
 # from a password with tox_derive_key_from_pass, and use the returned key to
 # encrypt the data. The second part takes the password itself instead of the key,
 # and then delegates to the first part to derive the key before de/encryption,
 # which can simplify client code; however, key derivation is very expensive
 # compared to the actual encryption, so clients that do a lot of encryption should
 # favor using the first part intead of the second part.
 #
 # The encrypted data is prepended with a magic number, to aid validity checking
 # (no guarantees are made of course).
 #
 # Clients should consider alerting their users that, unlike plain data, if even one bit
 # becomes corrupted, the data will be entirely unrecoverable.
 # Ditto if they forget their password, there is no way to recover the data.
 |#


#|
 # ############################### BEGIN PART 2 ###############################
 # For simplicty, the second part of the module is presented first. The API for
 # the first part is analgous, with some extra functions for key handling. If
 # your code spends too much time using these functions, consider using the part
 # 1 functions instead.
 |#

#|
 # Encrypts the given data with the given passphrase. The output array must be
 # at least data_len + TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long. This delegates
 # to tox_derive_key_from_pass and tox_pass_key_encrypt.
 #
 # returns true on success
 #
 # bool tox_pass_encrypt(const uint8_t *data, size_t data_len, uint8_t *passphrase,
 #                       size_t pplength, uint8_t *out, TOX_ERR_ENCRYPTION *error);
 |#
(define-encrypt pass-encrypt
  (_fun (data passphrase) ::
        [data : _bytes]
        [data-len : _uint32 = (bytes-length data)]
        [passphrase : _string]
        [pplength : _uint32 = (string-length passphrase)]
        [out : (_bytes o (+ data-len TOX_PASS_ENCRYPTION_EXTRA_LENGTH))]
        [err : _TOX-ERR-ENCRYPTION = 'ok]
        -> (success : _bool)
        -> (values success err out))
  #:c-id tox_pass_encrypt)

#|
 # Decrypts the given data with the given passphrase. The output array must be
 # at least data_len - TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long. This delegates
 # to tox_pass_key_decrypt.
 #
 # the output data has size data_length - TOX_PASS_ENCRYPTION_EXTRA_LENGTH
 #
 # returns true on success
 #
 # bool tox_pass_decrypt(const uint8_t *data, size_t length, uint8_t *passphrase,
 #                       size_t pplength, uint8_t *out, TOX_ERR_DECRYPTION *error);
 |#
(define-encrypt pass-decrypt
  (_fun (data passphrase) ::
        [data : _bytes]
        [len : _uint32 = (bytes-length data)]
        [passphrase : _string]
        [pplength : _size = (string-length passphrase)]
        [out : (_bytes o (- len TOX_PASS_ENCRYPTION_EXTRA_LENGTH))]
        [err : _TOX-ERR-DECRYPTION = 'ok]
        -> (success : _bool)
        -> (values success err out))
  #:c-id tox_pass_decrypt)

#|
 ############################### BEGIN PART 1 ###############################
 # And now part "1", which does the actual encryption, and is rather less cpu
 # intensive than part one. The first 3 functions are for key handling.
 |#

#|
 # Generates a secret symmetric key from the given passphrase. out_key must be at least
 # TOX_PASS_KEY_LENGTH bytes long.
 # Be sure to not compromise the key! Only keep it in memory, do not write to disk.
 # The password is zeroed after key derivation.
 # The key should only be used with the other functions in this module, as it
 # includes a salt.
 # Note that this function is not deterministic; to derive the same key from a
 # password, you also must know the random salt that was used. See below.
 #
 # returns true on success
 #
 # bool tox_derive_key_from_pass(uint8_t *passphrase, size_t pplength, TOX_PASS_KEY *out_key,
 #                               TOX_ERR_KEY_DERIVATION *error);
 |#
(define-encrypt derive-key-from-pass
  (_fun [passphrase : _string]
        [pplength : _uint32 = (string-length passphrase)]
        [out-key : _Tox-Pass-Key-pointer]
        [err : _TOX-ERR-KEY-DERIVATION = 'ok]
        -> (success : _bool)
        -> (values success err))
  #:c-id tox_derive_key_from_pass)

#|
 # Same as above, except use the given salt for deterministic key derivation.
 # The salt must be TOX_PASS_SALT_LENGTH bytes in length.
 #
 # bool tox_derive_key_with_salt(uint8_t *passphrase, size_t pplength, uint8_t *salt,
 #                               TOX_PASS_KEY *out_key, TOX_ERR_KEY_DERIVATION *error);
 |#
(define-encrypt derive-key-with-salt
  (_fun [passphrase : _string]
        [pplength : _uint32 = (string-length passphrase)]
        [salt : _bytes]
        [out-key : _Tox-Pass-Key-pointer]
        [err : _TOX-ERR-KEY-DERIVATION = 'ok]
        -> (success : _bool)
        -> (values success err))
  #:c-id tox_derive_key_with_salt)

#|
 # This retrieves the salt used to encrypt the given data, which can then be passed to
 # derive_key_with_salt to produce the same key as was previously used. Any encrpyted
 # data with this module can be used as input.
 #
 # returns true if magic number matches
 # success does not say anything about the validity of the data, only that data of
 # the appropriate size was copied
 #
 # bool tox_get_salt(const uint8_t *data, uint8_t *salt);
 |#
(define-encrypt salt
  (_fun [data : _bytes]
        [salt : (_bytes o 256)]
        -> (success : _bool)
        -> (list success salt))
  #:c-id tox_get_salt)

#|
 # Encrypt arbitrary with a key produced by tox_derive_key_*. The output
 # array must be at least data_len + TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long.
 # key must be TOX_PASS_KEY_LENGTH bytes.
 # If you already have a symmetric key from somewhere besides this module, simply
 # call encrypt_data_symmetric in toxcore/crypto_core directly.
 #
 # returns true on success
 #
 # bool tox_pass_key_encrypt(const uint8_t *data, size_t data_len, const TOX_PASS_KEY *key,
 #                           uint8_t *out, TOX_ERR_ENCRYPTION *error);
 |#
(define-encrypt pass-key-encrypt!
  (_fun (data key) ::
        [data : _bytes]
        [data-len : _uint32 = (bytes-length data)]
        [key : _Tox-Pass-Key-pointer]
        [out : (_bytes o (+ data-len TOX_PASS_ENCRYPTION_EXTRA_LENGTH))]
        [err : _TOX-ERR-ENCRYPTION = 'ok]
        -> (success : _bool)
        -> (values success err out))
  #:c-id tox_pass_key_encrypt)

#|
 # This is the inverse of tox_pass_key_encrypt, also using only keys produced by
 # tox_derive_key_from_pass.
 #
 # the output data has size data_length - TOX_PASS_ENCRYPTION_EXTRA_LENGTH
 #
 # returns true on success
 #
 # bool tox_pass_key_decrypt(const uint8_t *data, size_t length, const TOX_PASS_KEY *key,
 #                           uint8_t *out, TOX_ERR_DECRYPTION *error);
 |#
(define-encrypt pass-key-decrypt
  (_fun [data : _bytes]
        [data-len : _uint32 = (bytes-length data)]
        [key : _Tox-Pass-Key-pointer]
        [out : (_bytes o (- data-len TOX_PASS_ENCRYPTION_EXTRA_LENGTH))]
        [err : _TOX-ERR-DECRYPTION = 'ok]
        -> (success : _bool)
        -> (values success err out))
  #:c-id tox_pass_key_decrypt)

#|
 # Determines whether or not the given data is encrypted (by checking the magic number)
 #
 # bool tox_is_data_encrypted(const uint8_t *data);
 |#
(define-encrypt data-encrypted?
  (_fun [data : _bytes]
        -> (success : _int)
        -> (= 1 success)) ; returns -256 on false for some reason
  #:c-id tox_is_data_encrypted)
)
