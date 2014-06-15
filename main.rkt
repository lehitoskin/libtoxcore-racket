; libtoxcore/main.rkt
(module libtoxcore-racket
  racket/base
  (require "functions.rkt"
           "av.rkt")
  (provide (all-from-out "functions.rkt"
                         "av.rkt")))
