#lang scribble/doc
@; constants.scrbl
@(require "common.rkt")

@title[#:tag "constants-enums"]{Constants and Enums}

Tox uses several enums and many different constants. It is important to be familiar
with the enums, especially.

@section[#:tag "constants"]{Constants}

@defthing[TOX_MAX_NAME_LENGTH 128]

@defthing[TOX_MAX_MESSAGE_LENGTH 1368]{
  Maximum length a message can be before it must be split.
}

@defthing[TOX_MAX_STATUSMESSAGE_LENGTH 1007]

@defthing[TOX_CLIENT_ID_SIZE 32]

@defthing[TOX_FRIEND_ADDRESS_SIZE (+ TOX_CLIENT_ID_SIZE
                                     (ctype-sizeof _uint32_t) (ctype-sizeof _uint16_t))]

@defthing[TOX_ENABLE_IPV6_DEFAULT #t]

@defthing[RTP_PAYLOAD_SIZE 65535]

@section[#:tag "enums"]{Enums}

The enums that Tox uses should be accessed through the following procedures.

@defproc[(_TOX_FAERR-index [sym (or/c 'TOOLONG
                                      'NOMESSAGE
                                      'OWNKEY
                                      'ALREADYSENT
                                      'UNKNOWN
                                      'BADCHECKSUM
                                      'SETNEWNOSPAM
                                      'NOMEM)]) integer?]

@defproc[(_TOX_USERSTATUS-index [sym (or/c 'NONE
                                           'AWAY
                                           'BUSY
                                           'INVALID)]) integer?]
