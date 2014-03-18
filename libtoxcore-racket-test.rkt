#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

(define Tox _pointer)

(tox_get_self_user_status Tox)
