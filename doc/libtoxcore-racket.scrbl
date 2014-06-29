#lang scribble/manual
@; libtoxcore-racket.scrbl
@(require "common.rkt")
@title["libtoxcore-racket"]

@author["Lehi Toskin"]

@defmodule[libtoxcore-racket]{
This library provides a Racket-like interface to the libtoxcore, libtoxav, and
libtoxdns libraries. Be aware that Tox is currently thread-unsafe, so please
take all proper precautions while using the library.
}

@table-of-contents[]

@include-section["functions.scrbl"]
@include-section["av.scrbl"]
@include-section["examples.scrbl"]
@include-section["license.scrbl"]

@index-section[]
