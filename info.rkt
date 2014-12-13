#lang setup/infotab

(define name "libtoxcore-racket")
(define scribblings '(("manual.scrbl" ())))

(define blurb '("Racket wrapper for libtoxcore."))
(define primary-file "main.rkt")
(define homepage "https://github.com/lehitoskin/libtoxcore-racket/")

(define version "0.0.1")
(define release-notes '("Initial release."))

(define required-core-version "5.3")

(define deps '("base"
	       "scribble-lib"
	       "r6rs-lib"))
