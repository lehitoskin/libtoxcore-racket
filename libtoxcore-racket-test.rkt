#!/usr/bin/env racket
#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

; initialize a new Tox and grab the _Tox-pointer
(define my-tox (tox_new TOX_ENABLE_IPV6_DEFAULT))

; THIS KILLS THE TOX
(tox_kill my-tox)