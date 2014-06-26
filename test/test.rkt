#!/usr/bin/env racket
#lang racket
; libtoxcore-racket-test.rkt
; not exactly supposed to be exhaustive,
; just testing out the wrapper
(require "../main.rkt"
         file/sha1)

; takes a number, returns a number
(define dec->bin
  (λ (x)
    (if (not (integer? x))
        (raise-argument-error 'dec->bin "integer?" x)
        (string->number (number->string x 2)))))

; takes a number, returns a string
(define dec->hex
  (λ (x)
    (if (not (integer? x))
        (raise-argument-error 'dec->hex "integer?" x)
        (if (< x 16)
            (string-append "0" (number->string x 16))
            (number->string x 16)))))

; takes a number, returns a number
(define bin->dec
  (λ (x)
    (if (not (integer? x))
        (raise-argument-error 'bin->dec "integer?" x)
        (string->number (number->string x) 2))))

; takes a number, returns a string
(define bin->hex
  (λ (x)
    (if (integer? x)
        (dec->hex (bin->dec x))
        (raise-argument-error 'bin->hex "integer?" x))))

; takes a string, returns a number
(define hex->dec
  (λ (x)
    (if (string? x)
        (string->number x 16)
        (raise-argument-error 'hex->dec "string?" x))))

; takes a string, returns a number
(define hex->bin
  (λ (x)
    (if (string? x)
        (dec->bin (hex->dec x))
        (raise-argument-error 'hex->bin "string?" x))))

; initialize a new Tox and grab the _Tox-pointer
(define my-tox (tox-new TOX_ENABLE_IPV6_DEFAULT))
(define my-name "Leah Twoskin Redux")
(define my-status-message "Testing the Racket wrapper")
;(tox_isconnected my-tox)
; set nick name
(display "Setting my name\n")
(set-name my-tox my-name)

; set status message
(display "Setting my status\n")
(set-status-message my-tox my-status-message)

(display "How long is my name?\n")
; returns length of my-name
(define name-length (get-self-name-size my-tox))
name-length

(displayln "Obtaining name in buffer")
(define name-buf (make-bytes name-length))
(get-self-name my-tox name-buf)
name-buf

(display "How long is my status message?\n")
(define status-message-buf (make-bytes (string-length my-status-message)))
(get-self-status-message my-tox status-message-buf)
status-message-buf

(displayln "How many friends do I have?")
(friendlist-length my-tox)

; connect to DHT
(displayln "Connection to DHT...")
(define dht-address "192.254.75.98")
(define dht-port 33445)
; does dht-public-key need to be bytes? a string?
(define dht-public-key #"A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074")
(bootstrap-from-address my-tox dht-address TOX_ENABLE_IPV6_DEFAULT dht-port dht-public-key)

(define on-connection-change
  (λ (mtox pub-key data length userdata)
    (displayln "There's been a change in connection")))

(displayln "my-id stuff")
(define size (tox-size my-tox))
(define data (make-bytes size))
; obtain tox id
(define my-id-bytes (make-bytes (* TOX_FRIEND_ADDRESS_SIZE)))
(get-address my-tox my-id-bytes)
(printf "Before hex: ~a\n" my-id-bytes)
(define my-id-hex "")
(define b2hs (string-upcase (bytes->hex-string my-id-bytes)))
(do ((i 0 (+ i 1)))
  ((= i TOX_FRIEND_ADDRESS_SIZE))
  (set! my-id-hex (string-append
                   my-id-hex
                   (string-upcase
                    (dec->hex (bytes-ref my-id-bytes i))))))
(printf "After hex: ~a\nbytes->hex-string: ~a\n" my-id-hex b2hs)
(printf "string=? ~a\n" (string=? my-id-hex b2hs))

(displayln "This kills the Tox...")
(tox-kill! my-tox)
