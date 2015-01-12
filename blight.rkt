(module libtoxcore-racket/blight
  racket/base
; libtoxcore-racket/blight.rkt
; contains wrappers for the libblight library
; specifically written for blight
(require ffi/unsafe
         ffi/unsafe/define
         (only-in "functions.rkt"
                  TOX_FRIEND_ADDRESS_SIZE))

(provide (except-out (all-defined-out)
                     define-blight
                     _uint8_t
                     _uint32_t))

(define-ffi-definer define-blight (ffi-lib "libblight"))

(define _uint8_t _uint8)
(define _uint32_t _uint32)

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
 # int tox_decrypt_dns3_TXT(void *dns3_object, uint8_t *tox_id, uint8_t *id_record,
 #                          uint32_t id_record_len, uint32_t request_id)
 |#
; proven to work
(define-blight dns3-decrypt
  (_fun [dns3-obj : _pointer]
        [tox-id : _bytes = (make-bytes TOX_FRIEND_ADDRESS_SIZE)]
        [enc-response : _bytes]
        [enc-response-len : _uint32_t = (bytes-length enc-response)]
        [request-id : _bytes]
        -> (success : _int)
        -> (if (= -1 success)
               #f
               tox-id))
  #:c-id blight_decrypt_dns3)

; void blight_play_audio_buffer(ALuint alSource, const int16_t *data, int samples,
;                               unsigned channels, int sampleRate)
(define-blight play-audio-buffer
  (_fun [source : _int]
        [data : _bytes]
        [samples : _int]
        [channels : _int]
        [sample-rate : _int] -> _void)
  #:c-id blight_play_audio_buffer)
)
