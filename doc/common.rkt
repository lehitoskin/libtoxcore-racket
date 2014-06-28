#lang racket/base

(require scribble/manual
         scribble/bnf
         (for-label racket/base
                    racket/contract
                    racket/gui/base
                    "../main.rkt"))
(provide (all-from-out scribble/manual)
         (for-label (all-from-out "../main.rkt"
                                  racket/base
                                  racket/contract
                                  racket/gui/base)))
