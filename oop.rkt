#lang racket
; libtoxcore-racket/oop.rkt
(require ffi/unsafe
         "functions.rkt")

; super-duper Tox class
(define Tox-class%
  (class object%
    (init-field name status ipv6 dht-address dht-port dht-public-key)
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
    ; instantiate tox session
    (define tox
      (tox_new ipv6))
    ; return the name of the user
    (define/public (get-name)
      name)
    ; return the status of the user
    (define/public (get-status)
      status)
    ; obtain tox id of the user
    (define id
      (let ((my-id-bytes (malloc (* TOX_FRIEND_ADDRESS_SIZE
                                    (ctype-sizeof _uint8_t))))
            (my-id-hex ""))
        ; place address inside my-id-bytes
        (tox_get_address tox my-id-bytes)
        ; loop through my-id-bytes, turn into hex
        ; then append to my-id-hex
        (do ((i 0 (+ i 1)))
          ((= i TOX_FRIEND_ADDRESS_SIZE))
          (set! my-id-hex
                (string-upcase
                 (string-append my-id-hex
                                (dec->hex (ptr-ref my-id-bytes _uint8_t i))))))
        ; return my-id-hex as tox id
        my-id-hex))
    ; return tox id
    (define/public (get-id)
      id)
    ; return the dht ip address
    (define/public (get-dht-address)
      dht-address)
    ; return the port to connect to the dht node
    (define/public (get-dht-port)
      dht-port)
    ; return public key of the dht node
    (define/public (get-dht-public-key)
      dht-public-key)
    ; set tox name
    (define/public (set-name str)
      (set! name str)
      (tox_set_name tox str (string-length str)))
    ; set tox status
    (define/public (set-status str)
      (set! status str)
      (tox_set_status_message tox str (string-length str)))
    ; set new dht address
    (define/public (set-dht-address address)
      (set! dht-address address))
    ; set new dht port
    (define/public (set-dht-port port)
      (set! dht-port port))
    ; set new dht public key
    (define/public (set-dht-public-key public-key)
      (set! dht-public-key public-key))
    ; connect to the boostrap node
    (define/public (connect)
      (tox_bootstrap_from_address tox dht-address ipv6 dht-port
                                  dht-public-key))
    ; save tox information inside data-ptr
    ; data-ptr must be of size (tox_size tox)
    (define/public (save-tox data)
      (tox_save tox data))
    ; load tox information from data
    (define/public (load-tox data)
      (tox_load tox data))
    ; kill the tox instance
    (define/public (kill-tox)
      (tox_kill tox))
    (super-new)))

(define my-tox (new Tox-class%
                    [name "Tox User"]
                    [status "Using Tox"]
                    [ipv6 TOX_ENABLE_IPV6_DEFAULT]
                    [dht-address "192.254.75.98"]
                    [dht-port 33445]
                    [dht-public-key
                     "A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074"]))

(send my-tox get-name)
(send my-tox get-status)
(send my-tox set-name "User Tox")
(send my-tox set-status "Tox Using")
(send my-tox get-name)
(send my-tox get-status)
(send my-tox connect)

(send my-tox get-id)

(send my-tox kill-tox)
