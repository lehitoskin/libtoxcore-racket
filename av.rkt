#lang racket
; libtoxcore-racket/av.rkt
; ffi implementation of libtoxav
(require ffi/unsafe
         ffi/unsafe/define
         "enums.rkt")

(provide (all-from-out "enums.rkt")
         _ToxAv-pointer)

(define-ffi-definer define-av (ffi-lib "libtoxav"))
(define-ffi-definer define-al (ffi-lib "libopenal"))

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

; Tox stuff
; define ToxAv struct
(define _ToxAv-pointer (_cpointer 'ToxAv))
; define Tox struct
(define _Tox-pointer (_cpointer 'Tox))

; OpenAL stuff
; handle of device selected/opened
(define _ALCdevice-pointer (_cpointer 'ALCdevice))
; device context
(define _ALCcontext (_cpointer 'ALCcontext))
(struct _DeviceIX (dhndl ctx devices dix index) #:transparent)
(define DeviceIX (_DeviceIX _ALCdevice-pointer _ALCcontext 1 2 3))

(define RTP_PAYLOAD_SIZE 65535)
