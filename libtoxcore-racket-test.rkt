#!/usr/bin/env racket
#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

; initialize a new Tox and grab the _Tox-pointer
(define my-tox (tox_new TOX_ENABLE_IPV6_DEFAULT))
(define my-name "Leah Twoskin")

(tox_set_name my-tox my-name (string-length my-name))
(tox_get_self_name_size my-tox)

; THIS KILLS THE TOX
(tox_kill my-tox)