#lang scribble/doc
@(require "common.rkt")

@title[#:tag "examples"]{Examples}

@codeblock{
; simple 1-to-1 function wrapper
(require libtoxcore-racket)

(define-values (my-tox new-err) (tox-new TOX_ENABLE_IPV6_DEFAULT))
(define my-name "Toxizen5k")
(define my-status-message "Testing Tox with the Racket wrapper!")

(set-self-name! my-tox my-name)
(set-self-status-message! my-status-message)

(tox-kill! my-tox)
}
