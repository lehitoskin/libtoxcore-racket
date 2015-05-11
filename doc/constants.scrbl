#lang scribble/doc
@; constants.scrbl
@(require "common.rkt")

@title[#:tag "constants-enums"]{Constants and Enums}

Tox uses several enums and many different constants. It is important to be familiar
with the enums, especially.

@section[#:tag "constants"]{Constants}

@defthing[TOX_PUBLIC_KEY_SIZE 32]

@defthing[TOX_SECRET_KEY_SIZE 32]

@defthing[TOX_ADDRESS_SIZE (+ TOX_PUBLIC_KEY_SIZE
                                     (ctype-sizeof _uint32_t) (ctype-sizeof _uint16_t))]

@defthing[TOX_MAX_NAME_LENGTH 128]

@defthing[TOX_MAX_STATUS_MESSAGE_LENGTH 1007]

@defthing[TOX_MAX_FRIEND_REQUEST_LENGTH 1016]

@defthing[TOX_MAX_MESSAGE_LENGTH 1372]{
  Maximum length a message can be before it must be split.
}

@defthing[TOX_MAX_CUSTOM_PACKET_SIZE 1373]

@defthing[TOX_HASH_LENGTH 32]

@defthing[TOX_FILE_ID_LENGTH 32]

@defthing[TOX_MAX_FILENAME_LENGTH 255]

@defthing[TOXDNS_MAX_RECOMMENDED_NAME_LENGTH 32]

@section[#:tag "enums"]{Enums}

Tox uses various enumerations in many of its functions and they are
explained below.

@defthing[_TOX-USER-STATUS '(available away busy)]

@defthing[_TOX-MESSAGE-TYPE '(normal action)]

@defthing[_TOX-PROXY-TYPE '(none http socks5)]

@defthing[_TOX-ERR-OPTIONS-NEW '(ok malloc)]

@defthing[_TOX-ERR-NEW '(ok
                         null
                         malloc
                         port-alloc
                         proxy-bad-type
                         proxy-bad-host
                         proxy-bad-port
                         proxy-not-found
                         load-encrypted
                         load-bad-format)]{
  @racket['malloc] is returned when the function was unable to allocate enough memory to
  store the internal structures for the Tox object.
  
  @racket['port-alloc] is returned when the function was unable to bind to a port. This may
  mean that all ports have already been bound, e.g. by other Tox instances, or it may mean
  a permission error.
  
  @racket['proxy-bad-type] is returned when the proxy-type variable was invalid.
  
  @racket['proxy-bad-host] is returned when the proxy-type variable was valid, but the
  proxy-host had an invalid format or was NULL.
  
  @racket['proxy-bad-port] is returned when the proxy-type was valid, but the proxy-port was
  invalid.
  
  @racket['proxy-not-found] is returned when the proxy host passed could not be resolved.
  
  @racket['load-encrypted] is returned when the bytes loaded into the function contained an
  encrypted save.
  
  @racket['load-bad-format] is returned when the data format was invalid. This can happen when
  loading data that was saved by an older version of Tox, or when the data has been corrupted.
  When loading from badly formatted data, some data may have been loaded, and the rest is
  discarded.
}

@defthing[_TOX-ERR-BOOTSTRAP '(ok null bad-host bad-port)]

@defthing[_TOX-CONNECTION '(none tcp udp)]

@defthing[_TOX-ERR-SET-INFO '(ok null too-long)]

@defproc[(_ToxAvCallbackID [sym (or/c 'Invite
                                      'Ringing
                                      'Start
                                      'Cancel
                                      'Reject
                                      'End
                                      'RequestTimeout
                                      'PeerTimeout
                                      'PeerCSChange
                                      'SelfCSChange)]) (or/c false? integer?)]{
  @racket['Invite] is when there has been a call invitation.
  
  @racket['Ringing] is when the peer is ready to accept/reject the call.
  
  @racket['Start] is when the call (rtp transmission) has started.
  
  @racket['Cancel] is when the side that initiated the call has canceled the invite.
  
  @racket['Reject] is when the side that was invited rejected the call.
  
  @racket['End] is when the call that was active has ended.
  
  @racket['RequestTimeout] is when the request didn't get a response in time.
  
  @racket['PeerTimeout] peer timed out; stop the call.
  
  @racket['PeerCSChange] is when the peer changed csettings. Prepare for changed AV.
  
  @racket['SelfCSChange] is for csettings change confirmation. Once triggered, the
  peer is ready to receive changed AV.
}

@defproc[(_ToxAvCallType [sym (or/c 'Audio 'Video)]) (or/c false? integer?)]{
  Represents the type of A/V call.
}

@defproc[(_ToxAvCallState [sym (or/c 'CallNonExistant
                                     'CallInviting
                                     'CallStarting
                                     'CallActive
                                     'CallHold
                                     'CallHangedUp)]) (or/c false? integer?)]{
  Represents the state of the current call.
  
  @racket['CallInviting] is for when we're sending a call invite.
  
  @racket['CallStarting] is for when we're getting a call invite.
}

@defproc[(_ToxAvError [sym (or/c 'None = 0
                                 'Unknown = -1
                                 'NoCall = -20
                                 'InvalidState = -21
                                 'AlreadyInCallWithPeer = -22
                                 'ReachedCallLimit = -23
                                 'InitializingCodecs = -30
                                 'SettingVideoResolution = -31
                                 'SettingVideoBitrate = -32
                                 'SplittingVideoPayload = -33
                                 'EncodingVideo = -34
                                 'EncodingAudio = -35
                                 'SendingPayload = -40
                                 'CreatingRtpSessions = -41
                                 'NoRtpSession = -50
                                 'InvalidCodecState = -51
                                 'PacketTooLarge = -52)]) (or/c false? integer?)]{
  @racket['NoCall] means we are trying to perform a call action while not in a call.
  
  @racket['InvalidState] means we are trying to perform a call action while in an invalid state.
  
  @racket['AlreadyInCallWithPeer] means we are trying to call peer when already in a call with
  peer.
  
  @racket['ReachedCallLimit] means we cannot handle more calls.
  
  @racket['InitializingCodecs] means we failed to create a CSSession.
  
  @racket['SplittingVideoPayload] means there was an error splitting the video payload
  
  @racket['EncodingVideo] means @racket[vpx_codec_encode] failed.
  
  @racket['EncodingAudio] means @racket[opus_encode] failed.
  
  @racket['SendingPayload] means sending lossy packet failed.
  
  @racket['CreatingRtpSessions] means one of the rtp sessions failed to initialize.
  
  @racket['NoRtpSession] means we tried to perform an rtp action on an invalid session.
  
  @racket['InvalidCodecState] means the codec state was not initialized.
  
  @racket['PacketTooLarge] means the buffer exceeds size while encoding.
  
  Those not listed above are self-explanatory.
}

@defproc[(_ToxAvCapabilities [sym (or/c 'AudioEncoding
                                        'AudioDecoding
                                        'VideoEncoding
                                        'VideoDecoding)]) (or/c false? integer?)]{
  @racket['AudioEncoding] is equivalent to 1 << 0 or @racket[(expt 2 0)]
  
  @racket['AudioDecoding] is equivalent to 1 << 1 or @racket[(expt 2 1)]
  
  @racket['VideoEncoding] is equivalent to 1 << 2 or @racket[(expt 2 2)]
  
  @racket['VideoDecoding] is equivalent to 1 << 3 or @racket[(expt 2 3)]
}
