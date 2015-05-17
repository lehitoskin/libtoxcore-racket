(module libtoxcore-racket/dns
  racket/base
; dns.rkt
(require ffi/unsafe
         ffi/unsafe/define)

(provide (except-out (all-defined-out)
                     define-dns
                     TOX_PUBLIC_KEY_SIZE
                     libtoxdns-path))

(define libtoxdns-path
  (if (eq? (system-type) 'windows)
      "libtox"
      "libtoxdns"))

(define-ffi-definer define-dns (ffi-lib libtoxdns-path))

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

; Clients are encouraged to set this as the maximum length names can have.
(define TOXDNS_MAX_RECOMMENDED_NAME_LENGTH 32)

(define TOX_PUBLIC_KEY_SIZE 32)

#|
 # How to use this api to make secure tox dns3 requests:
 #
 # 1. Get the public key of a server that supports tox dns3.
 # 2. use tox_dns3_new() to create a new object to create DNS requests
 # and handle responses for that server.
 # 3. Use tox_generate_dns3_string() to generate a string based on the name we want to query and a request_id
 # that must be stored somewhere for when we want to decrypt the response.
 # 4. take the string and use it for your DNS request like this:
 # _4haaaaipr1o3mz0bxweox541airydbovqlbju51mb4p0ebxq.rlqdj4kkisbep2ks3fj2nvtmk4daduqiueabmexqva1jc._tox.utox.org
 # 5. The TXT in the DNS you receive should look like this:
 # v=tox3;id=2vgcxuycbuctvauik3plsv3d3aadv4zfjfhi3thaizwxinelrvigchv0ah3qjcsx5qhmaksb2lv2hm5cwbtx0yp
 # 6. Take the id string and use it with tox_decrypt_dns3_TXT() and the request_id corresponding to the
 # request we stored earlier to get the Tox id returned by the DNS server.
 |#

#|
 # Create a new tox_dns3 object for server with server_public_key of size TOX_CLIENT_ID_SIZE.
 #
 # return Null on failure.
 # return pointer object on success.
 # void *tox_dns3_new(uint8_t *server_public_key);
 |#
(define-dns dns3-new (_fun [server-public-key : _string] -> _pointer)
  #:c-id tox_dns3_new)

; Destroy the tox dns3 object.
(define-dns dns3-kill! (_fun _pointer -> _void)
  #:c-id tox_dns3_kill)

#|
 # Generate a dns3 string of string_max_len used to query the dns server referred to by to
 # dns3_object for a tox id registered to user with name of name_len.
 #
 # the uint32_t pointed by request_id will be set to the request id which must be passed to
 # tox_decrypt_dns3_TXT() to correctly decode the response.
 #
 # This is what the string returned looks like:
 # 4haaaaipr1o3mz0bxweox541airydbovqlbju51mb4p0ebxq.rlqdj4kkisbep2ks3fj2nvtmk4daduqiueabmexqva1jc
 #
 # returns length of string on sucess.
 # returns -1 on failure.
 #
 # int tox_generate_dns3_string(void *dns3_object, uint8_t *string, uint16_t string_max_len, uint32_t *request_id, 
 #                             uint8_t *name, uint8_t name_len)
 |#
; good to go!
(define-dns dns3-encrypt
  (_fun (dns3-obj nick) ::
        [dns3-obj : _pointer]
        [bstr : (_bytes o 256)]
        [bstr-max-len : _uint16 = 256]
        [request-id : (_bytes o 4)]
        [nick : _string]
        [nick-len : _uint8 = (string-length nick)]
        -> (copied : _int)
        -> (if (= -1 copied)
               (values request-id #f)
               (values request-id (subbytes bstr 0 copied))))
  #:c-id tox_generate_dns3_string)

; older, but proven to work
#;(define-dns dns3-generate-string
  (_fun [dns3-obj : _pointer]
        [bstr : _bytes]
        [bstr-max-len : _uint16 = (bytes-length bstr)]
        [request-id : _bytes]
        [nick : _string]
        [nick-len : _uint8 = (string-length nick)]
        -> _int)
  #:c-id tox_generate_dns3_string)

#|
 # Decode and decrypt the id_record returned of length id_record_len into
 # tox_id (needs to be at least TOX_FRIEND_ADDRESS_SIZE).
 #
 # request_id is the request id given by tox_generate_dns3_string() when creating the request.
 #
 # the id_record passed to this function should look somewhat like this:
 # 2vgcxuycbuctvauik3plsv3d3aadv4zfjfhi3thaizwxinelrvigchv0ah3qjcsx5qhmaksb2lv2hm5cwbtx0yp
 #
 # returns -1 on failure.
 # returns 0 on success.
 #
 #
 # int tox_decrypt_dns3_TXT(void *dns3_object, uint8_t *tox_id, uint8_t *id_record, uint32_t id_record_len,
 #                         uint32_t request_id)
 |#
; the original
; doesn't work because of the way the toxdns code is written
(define-dns dns3-decrypt-TXT
  (_fun (dns3-obj id-record request-id) ::
        [dns3-obj : _pointer]
        [tox-id : (_bytes o TOX_PUBLIC_KEY_SIZE)]
        [id-record : _bytes]
        [id-record-len : _uint32 = (bytes-length id-record)]
        [request-id : _uint32]
        -> (success : _int)
        -> (if (zero? success)
               tox-id
               #f))
  #:c-id tox_decrypt_dns3_TXT)
)
