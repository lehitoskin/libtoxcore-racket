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

@defthing[TOX_AVATAR_MAX_DATA_LENGTH 16384]

@defthing[TOX_AVATAR_HASH_LENGTH 32]

@defthing[TOX_HASH_LENGTH TOX_AVATAR_HASH_LENGTH]

@section[#:tag "enums"]{Enums}

The enums that Tox uses should be accessed through the following procedures.

@defproc[(_TOX_FAERR [sym (or/c 'TOOLONG
                                      'NOMESSAGE
                                      'OWNKEY
                                      'ALREADYSENT
                                      'UNKNOWN
                                      'BADCHECKSUM
                                      'SETNEWNOSPAM
                                      'NOMEM)]) integer?]{
  FAERR - friend add errors.
}

@defproc[(_TOX_USERSTATUS [sym (or/c 'NONE
                                           'AWAY
                                           'BUSY
                                           'INVALID)]) integer?]{
  Represents the types of statuses a user can have.
}

@defproc[(_TOX_CHAT_CHANGE_PEER [sym (or/c 'ADD
                                                 'DEL
                                                 'NAME)]) integer?]

@defproc[(_TOX_FILECONTROL [sym (or/c 'ACCEPT
                                            'PAUSE
                                            'KILL
                                            'FINISHED
                                            'RESUME_BROKEN)]) integer?]{
  Types allowed in filecontrols.
}

@defproc[(_ToxAvCallbackID [sym (or/c 'av_OnInvite
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

@defproc[(_ToxAvCapabilities [sym (or/c 'AudioEncoding
                                              'AudioDecoding
                                              'VideoEncoding
                                              'VideoDecoding)]) integer?]{
  @racket['AudioEncoding] is equivalent to 1 << 0 or @racket[(expt 2 0)]
  
  @racket['AudioDecoding] is equivalent to 1 << 1 or @racket[(expt 2 1)]
  
  @racket['VideoEncoding] is equivalent to 1 << 2 or @racket[(expt 2 2)]
  
  @racket['VideoDecoding] is equivalent to 1 << 3 or @racket[(expt 2 3)]
}

@defproc[(_TOX_AVATAR_FORMAT [sym (or/c 'None 'PNG)]) integer?]{
  Represents the format of the avatar.
}

@defproc[(_TOX_GROUPCHAT_FORMAT [sym (or/c 'TEXT 'AV)]) integer?]{
  Represents the format of the groupchat.
  
  @racket[TOX_GROUPCHAT_TYPE_TEXT] groupchats must be accepted with the @racket[join-groupchat] function.
  
  The function to accept @racket[TOX_GROUPCHAT_TYPE_AV] is in toxav.
}
