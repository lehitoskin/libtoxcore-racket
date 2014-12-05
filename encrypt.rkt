(module libtoxcore-racket/encrypt
  racket/base
; libtoxcore-racket/encrypt.rkt
(require ffi/unsafe
         ffi/unsafe/define)

(provide (except-out (all-defined-out)
                     define-encrypt
                     _Tox-pointer
                     _uint32_t))

(define-ffi-definer define-encrypt (ffi-lib "libtoxencryptsave"))

#|###################
 # type definitions #
 ################## |#

; *_t definitions
(define _uint32_t _uint32)

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

(define _Tox-pointer (_cpointer 'Tox))

; these functions provice access to these defines in toxencryptsave.c, which
; otherwise aren't actually available in clients
(define-encrypt pass-encryption-extra-length (_fun -> _int)
  #:c-id tox_pass_encryption_extra_length)

(define-encrypt pass-key-length (_fun -> _int)
  #:c-id tox_pass_key_length)

(define-encrypt pass-salt-length (_fun -> _int)
  #:c-id tox_pass_salt_length)

; return size of the messenger data (for encrypted Messenger saving).
; uint32_t tox_encrypted_size(const Tox *tox);
(define-encrypt encrypted-size (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_encrypted_size)

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
 # at least data_len + tox_pass_encryption_extra_length() bytes long. This delegates
 # to tox_derive_key_from_pass and tox_pass_key_encrypt.
 #
 # tox_encrypted_save() is a good example of how to use this function.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_pass_encrypt(const uint8_t *data, uint32_t data_len, uint8_t *passphrase,
 #                      uint32_t pplength, uint8_t *out);
 |#
(define-encrypt pass-encrypt
  (_fun [data : _bytes]
        [data-len : _uint32_t]
        [passphrase : _string]
        [pplength : _uint32_t]
        [out : _bytes] -> _int)
  #:c-id tox_pass_encrypt)

#|
 # Save the messenger data encrypted with the given password.
 # data must be at least tox_encrypted_size().
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_encrypted_save(const Tox *tox, uint8_t *data, uint8_t *passphrase,
 #                        uint32_t pplength);
 |#
(define-encrypt encrypted-save
  (_fun [tox : _Tox-pointer]
        [data : _bytes]
        [passphrase : _string]
        [pplength : _uint32_t] -> _int)
  #:c-id tox_encrypted_save)

#|
 # Decrypts the given data with the given passphrase. The output array must be
 # at least data_len - tox_pass_encryption_extra_length() bytes long. This delegates
 # to tox_pass_key_decrypt.
 #
 # tox_encrypted_load() is a good example of how to use this function.
 #
 # returns the length of the output data (== data_len - tox_pass_encryption_extra_length())
 # on success
 # returns -1 on failure
 #
 # int tox_pass_decrypt(const uint8_t *data, uint32_t length, uint8_t *passphrase,
 #                      uint32_t pplength, uint8_t *out);
 # Load the messenger from encrypted data of size length.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_encrypted_load(Tox *tox, const uint8_t *data, uint32_t length, uint8_t *passphrase,
 #                        uint32_t pplength);
 |#
(define-encrypt encrypted-load
  (_fun [tox : _Tox-pointer]
        [data : _bytes]
        [len : _uint32_t]
        [passphrase : _string]
        [pplength : _uint32_t] -> _int)
  #:c-id tox_encrypted_load)

#|
 ############################### BEGIN PART 1 ###############################
 # And now part "1", which does the actual encryption, and is rather less cpu
 # intensive than part one. The first 3 functions are for key handling.
 |#

#|
 # Generates a secret symmetric key from the given passphrase. out_key must be at least
 # tox_pass_key_length() bytes long.
 # Be sure to not compromise the key! Only keep it in memory, do not write to disk.
 # The password is zeroed after key derivation.
 # The key should only be used with the other functions in this module, as it
 # includes a salt.
 # Note that this function is not deterministic; to derive the same key from a
 # password, you also must know the random salt that was used. See below.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_derive_key_from_pass(uint8_t *passphrase, uint32_t pplength, uint8_t *out_key);
 |#
(define-encrypt derive-key-from-pass
  (_fun [passphrase : _string]
        [pplength : _uint32_t]
        [out-key : _bytes] -> _int)
  #:c-id tox_derive_key_from_pass)

#|
 # Same as above, except with use the given salt for deterministic key derivation.
 # The salt must be tox_salt_length() bytes in length.
 #
 # int tox_derive_key_with_salt(uint8_t *passphrase, uint32_t pplength, uint8_t *salt,
 #                              uint8_t *out_key);
 |#
(define-encrypt derive-key-with-salt
  (_fun [passphrase : _string]
        [pplength : _uint32_t]
        [salt : _bytes]
        [out-key : _bytes] -> _int)
  #:c-id tox_derive_key_with_salt)

#|
 # This retrieves the salt used to encrypt the given data, which can then be passed to
 # derive_key_with_salt to produce the same key as was previously used. Any encrpyted
 # data with this module can be used as input.
 #
 # returns -1 if the magic number is wrong
 # returns 0 otherwise (no guarantee about validity of data)
 #
 # int tox_get_salt(uint8_t *data, uint8_t *salt);
 |#
(define-encrypt get-salt (_fun [data : _bytes]
                               [salt : _bytes] -> _int)
  #:c-id tox_get_salt)

#|
 # Now come the functions that are analogous to the part 2 functions. */
 # Encrypt arbitrary with a key produced by tox_derive_key_. The output
 # array must be at least data_len + tox_pass_encryption_extra_length() bytes long.
 # key must be tox_pass_key_length() bytes.
 # If you already have a symmetric key from somewhere besides this module, simply
 # call encrypt_data_symmetric in toxcore/crypto_core directly.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_pass_key_encrypt(const uint8_t *data, uint32_t data_len, const uint8_t *key,
 #                          uint8_t *out);
 |#
(define-encrypt pass-key-encrypt
  (_fun [data : _bytes]
        [data-len : _uint32_t]
        [key : _bytes]
        [out : _bytes] -> _int)
  #:c-id tox_pass_key_encrypt)

#|
 # Save the messenger data encrypted with the given key from tox_derive_key.
 # data must be at least tox_encrypted_size().
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_encrypted_key_save(const Tox *tox, uint8_t *data, uint8_t *key);
 |#
(define-encrypt encrypted-key-save
  (_fun [tox : _Tox-pointer]
        [data : _bytes]
        [key : _bytes] -> _int)
  #:c-id tox_encrypted_key_save)

#|
 # This is the inverse of tox_pass_key_encrypt, also using only keys produced by
 # tox_derive_key_from_pass.
 #
 # returns the length of the output data (== data_len - tox_pass_encryption_extra_length())
 # on success
 # returns -1 on failure
 #
 # int tox_pass_key_decrypt(const uint8_t *data, uint32_t length, const uint8_t *key,
 #                          uint8_t *out);
 |#
(define-encrypt pass-key-decrypt
  (_fun [data : _bytes]
        [len : _uint32_t]
        [key : _bytes]
        [out : _bytes] -> _int)
  #:c-id tox_pass_key_decrypt)

#|
 # Load the messenger from encrypted data of size length, with key from tox_derive_key.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_encrypted_key_load(Tox *tox, const uint8_t *data, uint32_t length, uint8_t *key);
 |#
(define-encrypt encrypted-key-load
  (_fun [tox : _Tox-pointer]
        [data : _bytes]
        [len : _uint32_t]
        [key : _bytes] -> _int)
  #:c-id tox_encrypted_key_load)

#|
 # Determines whether or not the given data is encrypted (by checking the magic number)
 #
 # returns 1 if it is encrypted
 # returns 0 otherwise
 #
 # int tox_is_data_encrypted(const uint8_t *data);
 # int tox_is_save_encrypted(const uint8_t *data);
 # poorly-named alias for backwards compat (oh irony...)
 |#
(define-encrypt is-data-encrypted? (_fun [data : _bytes] -> _bool)
  #:c-id tox_is_data_encrypted)

(define-encrypt is-save-encrypted? (_fun [data : _bytes] -> _bool)
  #:c-id tox_is_save_encrypted)
)
