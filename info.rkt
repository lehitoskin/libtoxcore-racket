#lang setup/infotab

(define name "libtoxcore-racket")
(define scribblings '(("doc/libtoxcore-racket.scrbl" ())))

(define blurb '("Racket wrapper for libtoxcore."))
(define primary-file "main.rkt")
(define homepage "https://github.com/lehitoskin/libtoxcore-racket/")

(define version "0.1")
(define release-notes '("Initial release."))

(define required-core-version "6.0.1")

(define deps '("base"
               "scribble-lib"))
(define build-deps '("racket-doc"))
