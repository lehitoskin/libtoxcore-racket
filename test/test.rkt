#!/usr/bin/env racket
#lang racket
; libtoxcore-racket-test.rkt
; not exactly supposed to be exhaustive,
; just testing out the wrapper
(require "../main.rkt" "../functions.rkt"
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

; initialize and set to default the options
(define my-opts (car (tox-options-new)))
(tox-options-default my-opts)

; initialize a new Tox with the default settings
(define my-tox (car (tox-new my-opts #"")))
(define my-name #"Wrapper Tester")
(define my-status-message #"Testing the Racket wrapper")
;(tox_isconnected my-tox)
; set nick name
(display "Setting my name\n")
(set-self-name! my-tox my-name)

; set status message
(display "Setting my status\n")
(set-self-status-message! my-tox my-status-message)

(display "How long is my name?\n")
; returns length of my-name
(define name-length (self-name-size my-tox))
name-length

(displayln "Obtaining name")
(self-name my-tox)

(display "How long is my status message?\n")
(self-status-message-size my-tox)

(displayln "How many friends do I have?")
(self-friend-list-size my-tox)

; connect to DHT
(displayln "Connection to DHT...")
(define dht-address "192.254.75.98")
(define dht-port 33445)
; does dht-public-key need to be bytes? a string?
(define dht-public-key "A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074")
(tox-bootstrap my-tox dht-address dht-port dht-public-key)

(define on-connection-change
  (λ (mtox pub-key data length userdata)
    (displayln "There's been a change in connection")))

(displayln "my tox id")
(string-upcase (bytes->hex-string (self-address my-tox)))

(displayln "This kills the Tox...")
(tox-options-free my-opts)
(tox-kill! my-tox)
