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
                                      'NOMEM)]) integer?]{
  FAERR - friend add errors.
}

@defproc[(_TOX_USERSTATUS-index [sym (or/c 'NONE
                                           'AWAY
                                           'BUSY
                                           'INVALID)]) integer?]{
  Represents the types of statuses a user can have.
}

@defproc[(_TOX_CHAT_CHANGE_PEER-index [sym (or/c 'ADD
                                                 'DEL
                                                 'NAME)]) integer?]

@defproc[(_TOX_FILECONTROL-index [sym (or/c 'ACCEPT
                                            'PAUSE
                                            'KILL
                                            'FINISHED
                                            'RESUME_BROKEN)]) integer?]{
  Types allowed in filecontrols.
}

@defproc[(_ToxAvCallbackID-index [sym (or/c 'av_OnInvite
                                            'av_OnStart
                                            'av_OnCancel
                                            'av_OnReject
                                            'av_OnEnd
                                            'av_OnRinging
                                            'av_OnStarting
                                            'av_OnEnding
                                            'av_OnError
                                            'av_OnRequestTimeout
                                            'av_OnPeerTimeout)]) integer?]{
  @racket['av_OnInvite], @racket['av_OnStart], @racket['av_OnCancel], @racket['av_OnReject],
  and @racket['av_OnEnd] are all for A/V requests.
  
  @racket['av_OnRinging], @racket['av_OnStarting], and @racket['av_OnEnding] are for
  A/V responses.
  
  @racket['av_OnError], @racket['av_OnRequestTimeout], and @racket['av_OnPeerTimeout] are
  protocol errors.
}

@defproc[(_ToxAvCallType [sym (or/c 'Audio 'Video)]) integer?]{
  Represents the type of A/V call.
}

@defproc[(_ToxAvError [sym (or/c 'None
                                 'Internal
                                 'AlreadyInCall
                                 'NoCall
                                 'InvalidState
                                 'NoRtpSession
                                 'AudioPacketLost
                                 'StartingAudioRtp
                                 'StartingVideoRtp
                                 'TerminatingAudioRtp
                                 'TerminatingVideoRtp
                                 'PacketTooLarge)]) integer?]{
  @racket['Internal] represents an internal error.
  
  @racket['AlreadyInCall] means we already have a call in progress.
  
  @racket['NoCall] means we are trying to perform a call action while not in a call.
  
  @racket['InvalidState] means we are trying to perform a call action while in an invalid state.
  
  @racket['NoRtpSession] means we are trying to perform an rtp action on an invalid session.
  
  @racket['AudioPacketLost] represents packet loss.
  
  @racket['StartingAudioRtp] represents an error in @tt{prepare-transmission}.
  
  @racket['StartingVideoRtp] represents an error in @tt{prepare-transmission}.
  
  @racket['TerminatingAudioRtp] represents an error in @tt{kill-transmission}.
  
  @racket['TerminatingVideoRtp] represents an error in @tt{kill-transmission}.
  
  @racket['PacketTooLarge] represents buffer exceeds size while encoding.
}

@defproc[(_ToxAvCapabilities-index [sym (or/c 'AudioEncoding
                                              'AudioDecoding
                                              'VideoEncoding
                                              'VideoDecoding)]) integer?]{
  @racket['AudioEncoding] is equivalent to 1 << 0 or @racket[(expt 2 0)]
  
  @racket['AudioDecoding] is equivalent to 1 << 1 or @racket[(expt 2 1)]
  
  @racket['VideoEncoding] is equivalent to 1 << 2 or @racket[(expt 2 2)]
  
  @racket['VideoDecoding] is equivalent to 1 << 3 or @racket[(expt 2 3)]
}
