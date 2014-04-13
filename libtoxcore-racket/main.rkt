; libtoxcore/main.rkt
(module libtoxcore-racket
  racket/base
  (require "functions.rkt")
  (provide (all-from-out "functions.rkt")))
