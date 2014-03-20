#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

; initialize a new Tox and grab the _Tox-pointer
(define my-tox (tox_new 0))

; THIS KILLS THE TOX
(tox_kill my-tox)