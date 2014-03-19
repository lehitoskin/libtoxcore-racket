#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

(tox_get_client_id _Tox-pointer "someaddress")