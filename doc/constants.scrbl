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

@defthing[_TOX-ERR-FRIEND-SEND-MESSAGE '(ok
                                         null
                                         friend-not-found
                                         friend-not-connected
                                         sendq
                                         too-long
                                         empty)]{
  @racket['sendq] is returned when an allocation error occurred while increasing the send
  queue size
}

@defthing[_TOX-FILE-KIND '(data avatar)]{
  @racket['data] is used when sending arbitrary file data. Clients can choose to handle it
  based on the file name or magic or any other way.
  
  @racket['avatar] is used when sending avatar data. Avatars can be sent at any time the
  client wishes. Generally, a client will send the avatar to a friend when that friend
  comes online, and to all friends when the avatar changed. A client can save some traffic
  by remembering which friend received the updated avatar already and only send it if the
  friend has an out of date avatar. Clients who receive avatar send requests can reject it
  (by sending TOX_FILE_CONTROL_CANCEL before any other controls), or accept it (by sending
  TOX_FILE_CONTROL_RESUME). The file_id of length TOX_HASH_LENGTH bytes (same length as
  TOX_FILE_ID_LENGTH) will contain the hash. A client can compare this hash with a saved
  hash and send TOX_FILE_CONTROL_CANCEL to terminate the avatar transfer if it matches.
  When file_size is set to 0 in the transfer request it means that the client has no avatar.
}

@defthing[_TOX-FILE-CONTROL '(resume pause cancel)]{
  @racket['resume] is used when accepting a file transfer or when resuming a paused transfer.
   
  @racket['pause] is sent by clients to pause the file transfer. The initial state of a file
  transfer is always paused on the receiving side and running on the sending side. If both
  the sending and receiving side pause the transfer, then both need to send
  TOX_FILE_CONTROL_RESUME for the transfer to resume.
  
  @racket['cancel] is sent by the receiving client to reject a file send request before
  any other commands are sent. Also sent by either side to terminate a file transfer.
}

@defthing[_TOX-ERR-FILE-CONTROL '(ok
                                  friend-not-found
                                  friend-not-connected
                                  not-found
                                  not-paused
                                  denied
                                  already-paused
                                  sendq)]{
  @racket['not-found] is returned when ; no file transfer with the given file number was
  found for the given friend.
  
  @racket['denied] is returned when a @racket['resume] control was sent, but the file
  transfer was paused by the other party. Only the party that paused the transfar can
  resume it.
  
  @racket['senq] is returned when the packet queue is full.
}

@defthing[_TOX-ERR-FILE-SEEK '(ok
                               friend-not-found
                               friend-not-connected
                               transfer-not-found
                               seek-denied
                               invalid-position
                               sendq)]{
  @racket['transfer-not-found] is returned when no transfer with the given file number was
  found for the given friend.
  
  @racket['seek-denied] is returned when the file was not in a state where it could be seeked.
  
  @racket['invalid-position] is returned when the seek position was invalid.
  
  @racket['senq] is returned when the packet queue is full.
}

@defthing[_TOX-ERR-FILE-GET '(ok friend-not-found transfer-not-found)]

@defthing[_TOX-ERR-FILE-SEND '(ok
                               null
                               friend-not-found
                               friend-not-connected
                               name-too-long
                               too-many)]

@defthing[_TOX-ERR-FILE-SEND-CHUNK '(ok
                                     null
                                     friend-not-found
                                     friend-not-connected
                                     not-found
                                     not-transferring
                                     invalid-length
                                     senq
                                     wrong-position)]

@defthing[_TOX-ERR-FRIEND-CUSTOM-PACKET '(ok
                                          null
                                          friend-not-found
                                          friend-not-connected
                                          invalid
                                          empty
                                          too-long
                                          sendq)]

@defthing[_TOX-ERR-KEY-DERIVATION '(ok null failed)]

@defthing[_TOX-ERR-ENCRYPTION '(ok
                                null
                                key-derivation-failed
                                encryption-failed)]{
  @racket['null] is returned when some input data, or maybe the output pointer, was null.
  
  @racket['key-derivation-failed] is returned when the crypto lib was unable to derive a
  key from the given passphrase, which is usually a lack of memory issue. The functions
  accepting keys do not produce this error.
  
  @racket['encryption-failed] is returned when the encryption itself failed.
}

@defthing[_TOX-ERR-DECRYPTION '(ok
                                null
                                invalid-length
                                bad-format
                                key-derivation-failed
                                decryption-failed)]

@defthing[_TOX-GROUPCHAT-TYPE '(text av)]

@defthing[_TOX-CHAT-CHANGE-PEER '(add del name)]{
  @racket['add] is for when a new peer has joined the groupchat.
  
  @racket['del] is for when a peer has left the groupchat.
  
  @racket['name] is for when a peer has changed her nickname.
}

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
