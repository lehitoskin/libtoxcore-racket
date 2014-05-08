#lang racket
; libtoxcore-racket/oop.rkt
(require ffi/unsafe
         "functions.rkt"
         file/sha1)

; super-duper Tox class
(define Tox-class%
  (class object%
    (init-field name status ipv6)
    ; takes a number, returns a number
    (define/private dec->bin
      (λ (x)
        (if (not (integer? x))
            (raise-argument-error 'dec->bin "integer?" x)
            (string->number (number->string x 2)))))
    
    ; takes a number, returns a string
    (define/private dec->hex
      (λ (x)
        (if (not (integer? x))
            (raise-argument-error 'dec->hex "integer?" x)
            (if (< x 16)
                (string-append "0" (number->string x 16))
                (number->string x 16)))))
    
    ; takes a number, returns a number
    (define/private bin->dec
      (λ (x)
        (if (not (integer? x))
            (raise-argument-error 'bin->dec "integer?" x)
            (string->number (number->string x) 2))))
    
    ; takes a number, returns a string
    (define/private bin->hex
      (λ (x)
        (if (integer? x)
            (dec->hex (bin->dec x))
            (raise-argument-error 'bin->hex "integer?" x))))
    
    ; takes a string, returns a number
    (define/private hex->dec
      (λ (x)
        (if (string? x)
            (string->number x 16)
            (raise-argument-error 'hex->dec "string?" x))))
    
    ; takes a string, returns a number
    (define/private hex->bin
      (λ (x)
        (if (string? x)
            (dec->bin (hex->dec x))
            (raise-argument-error 'hex->bin "string?" x))))
    
    (define tox
      (tox_new ipv6))
    
    (define/public (get-name)
      name)
    
    (define/public (get-status)
      status)
    
    (define id
      ; obtain tox id
      (let ((my-id-bytes (malloc (* TOX_FRIEND_ADDRESS_SIZE
                                    (ctype-sizeof _uint8_t))))
            (my-id-hex ""))
        (tox_get_address tox my-id-bytes)
        (do ((i 0 (+ i 1)))
          ((= i TOX_FRIEND_ADDRESS_SIZE))
          (set! my-id-hex
                (string-upcase
                 (string-append my-id-hex
                                (dec->hex (ptr-ref my-id-bytes _uint8_t i))))))
        my-id-hex))
    
    (define/public (get-id)
      id)
    
    (define/public (set-name str)
      (set! name str)
      (tox_set_name tox str (string-length str)))
    
    (define/public (set-status str)
      (set! status str)
      (tox_set_status_message tox str (string-length str)))
    
    (define/public (kill-tox)
      (tox_kill tox))
    
    (super-new)))

(define my-tox (new Tox-class%
                    [name "Tox User"]
                    [status "Using Tox"]
                    [ipv6 TOX_ENABLE_IPV6_DEFAULT]
                    ;[bootstrap-server "some.address.here"]
                    ))

(send my-tox get-name)
(send my-tox get-status)
(send my-tox set-name "herp derp")
(send my-tox set-status "herping on tawcks")
(send my-tox get-name)
(send my-tox get-status)

(send my-tox get-id)

(send my-tox kill-tox)
