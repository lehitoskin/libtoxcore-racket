(module libtoxcore-racket/dns
  racket/base
; dns.rkt
(require ffi/unsafe
         ffi/unsafe/define)

(provide (except-out (all-defined-out)
                     define-dns
                     define-blight
                     _uint8_t
                     _uint16_t
                     _uint32_t))

(define-ffi-definer define-dns (ffi-lib "libtoxdns"))
(define-ffi-definer define-blight (ffi-lib "libblight"))

(define _uint8_t _uint8)
(define _uint16_t _uint16)
(define _uint32_t _uint32)

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

; Clients are encouraged to set this as the maximum length names can have.
(define TOXDNS_MAX_RECOMMENDED_NAME_LENGTH 32)

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

#| Create a new tox_dns3 object for server with server_public_key of size TOX_CLIENT_ID_SIZE.
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

#| Generate a dns3 string of string_max_len used to query the dns server referred to by to
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
(define-dns dns3-generate-string
  (_fun [dns3-obj : _pointer]
        [str : _bytes]
        [str-max-len : _uint16_t]
        [request-id : _bytes]
        [name : _string]
        [name-len : _uint8_t] -> _int)
  #:c-id tox_generate_dns3_string)

#| Decode and decrypt the id_record returned of length id_record_len into
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
(define-blight dns3-decrypt-TXT
  (_fun [dns3-obj : _pointer]
        [tox-id : _bytes]
        [id-record : _bytes]
        [id-record-len : _uint32_t]
        [request-id : _bytes] -> _int)
  #:c-id blight_decrypt_dns3)
)
