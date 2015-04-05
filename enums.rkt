(module libtoxcore-racket/enums
  r6rs
; enums.rkt
; implements the TOX enums so that we can access
; and manipulate them. using the _enum from ffi/unsafe
; wasn't working out

(library (libtoxcore-racket enums)
         (export _TOX_ERR_FRIEND_ADD
                 _TOX_USER_STATUS
                 _TOX_CHAT_CHANGE_PEER
                 _TOX_FILECONTROL
                 _ToxAvCallbackID
                 _ToxAvCallType
                 _ToxAvCallState
                 _ToxAvError
                 _ToxAvCapabilities
                 _TOX_AVATAR_FORMAT
                 _TOX_GROUPCHAT_TYPE
                 _TOX_PROXY_TYPE)
         (import (rnrs))
         ; enum definitions
         ; Errors for m_addfriend
         ; FAERR - Friend Add Error
         ; enum starts at -1 and decrements from that point
         (define (_TOX_ERR_FRIEND_ADD sym)
           (define enum (make-enumeration
                         '(OK
                           NULL
                           TOO_LONG
                           NO_MESSAGE
                           OWN_KEY
                           ALREADY_SENT
                           BAD_CHECKSUM
                           SET_NEW_NOSPAM
                           MALLOC)))
             (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         ; USER_STATUS
         ; Represents user statuses someone can have.
         (define (_TOX_USER_STATUS sym)
           (define enum (make-enumeration
                         '(NONE
                           AWAY
                           BUSY)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_MESSAGE_TYPE sym)
           (define enum (make-enumeration '(NORMAL ACTION)))
           (if (enum-set-member? sym enum)
               ((enum-set-indexer enum) sym)
               #f))
         
         (define (_TOX_PROXY_TYPE sym)
           (define enum (make-enumeration '(NONE HTTP SOCKS5)))
           (if (enum-set-member? sym enum)
               ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_CHAT_CHANGE_PEER sym)
           (define enum (make-enumeration '(ADD
                                            DEL
                                            NAME)))
           (if (enum-set-member? sym enum)
               ((enum-set-indexer enum) sym)
               #f))
         
         ; improvised from line 521-ish of tox.h
         (define (_TOX_FILECONTROL sym)
           (let ([enum (make-enumeration
                        '(ACCEPT
                          PAUSE
                          KILL
                          FINISHED
                          RESUME_BROKEN))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         (define (_TOX_AVATAR_FORMAT sym)
           (let ([enum (make-enumeration '(NONE PNG))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         ; TOX_GROUPCHAT_TYPE_TEXT groupchats must be accepted with the join-groupchat function.
         ; The function to accept TOX_GROUPCHAT_TYPE_AV is in toxav.
         (define (_TOX_GROUPCHAT_TYPE sym)
           (let ([enum (make-enumeration '(TEXT AV))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         (define (_TOX_ERR_OPTIONS_NEW sym)
           (define enum (make-enumeration '(OK MALLOC)))
             (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_ENCRYPTED_NEW sym)
           (define enum (make-enumeration
                        '(OK
                          NULL
                          #|
                           # The function was unable to allocate enough memory to store the internal
                           # structures for the Tox object.
                           |#
                          MALLOC
                          #|
                           # The function was unable to bind to a port. This may mean that all ports
                           # have already been bound, e.g. by other Tox instances, or it may mean
                           # a permission error. You may be able to gather more information from errno.
                           |#
                          PORT_ALLOC
                          ; proxy_type was invalid.
                          PROXY_BAD_TYPE
                          #|
                           # proxy_type was valid but the proxy_host passed had an invalid format
                           # or was NULL.
                           |#
                          PROXY_BAD_HOST
                          ; proxy_type was valid, but the proxy_port was invalid.
                          PROXY_BAD_PORT
                          ; The proxy host passed could not be resolved.
                          PROXY_NOT_FOUND
                          ; The byte array to be loaded contained an encrypted save.
                          LOAD_ENCRYPTED
                          #|
                           # The data format was invalid. This can happen when loading data that was
                           # saved by an older version of Tox, or when the data has been corrupted.
                           # When loading from badly formatted data, some data may have been loaded,
                           # and the rest is discarded. Passing an invalid length parameter also
                           # causes this error.
                           |#
                          LOAD_BAD_FORMAT
                          #|
                           # The encrypted byte array could not be decrypted. Either the data was
                           # corrupt or the password/key was incorrect.
                           #
                           # NOTE: This error code is only set by tox_encrypted_new() and
                           # tox_encrypted_key_new(), in the toxencryptsave module.
                           |#
                          LOAD_DECRYPTION_FAILED))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         #| ############### BEGIN AV ENUMERATIONS ############# |#
         (define (_ToxAvCallbackID sym)
           (let ([enum (make-enumeration
                        ; incoming call
                        '(Invite
                          ; when peer is ready to accept/reject call
                          Ringing
                          ; call (rtp transmission) started
                          Start
                          ; the side that initiated the call canceled invite
                          Cancel
                          ; the side that was invited rejected the call
                          Reject
                          ; the call that was active has ended
                          End
                          ; when the request didn't get a response in time
                          RequestTimeout
                          ; peer timed out; stop the call
                          PeerTimeout
                          ; peer changed csettings. prepare for changed av
                          PeerCSChange
                          ; csettings change confirmation. once triggered peer
                          ; is ready to receive changed av
                          SelfCSChange))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         (define (_ToxAvCallType sym)
           (let ([enum (make-enumeration
                        '(Audio
                          Video))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (+ (i sym) 192))
                 #f)))
         
         (define (_ToxAvCallState sym)
           (let ([enum (make-enumeration
                        ; = -1
                        '(CallNonExistant
                          ; when sending call invite
                          CallInviting
                          ; when getting call invite
                          CallStarting
                          CallActive
                          CallHold
                          CallHangedUp))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (- (i sym) 1))
                 #f)))
         
         (define (_ToxAvError sym)
           (let ([enum (make-enumeration
                        ; = 0
                        '(None
                          ; = -1, /* Unknown error */
                          Unknown
                          ; = -20, /* Trying to perform call action while not in a call */
                          NoCall
                          ; = -21, /* Trying to perform call action while in an invalid state */
                          InvalidState
                          ; = -22, /* Trying to call peer when already in a call with peer */
                          AlreadyInCallWithPeer
                          ; = -23, /* Cannot handle more calls */
                          ReachedCallLimit
                          ; = -30, /* Failed creating CSSession */
                          InitializingCodecs
                          ; = -31, /* Error setting resolution */
                          SettingVideoResolution
                          ; = -32, /* Error setting bitrate */
                          SettingVideoBitrate
                          ; = -33, /* Error splitting video payload */
                          SplittingVideoPayload
                          ; = -34, /* vpx_codec_encode failed */
                          EncodingVideo
                          ; = -35, /* opus_encode failed */
                          EncodingAudio
                          ; = -40, /* Sending lossy packet failed */
                          SendingPayload
                          ; = -41, /* One of the rtp sessions failed to initialize */
                          CreatingRtpSessions
                          ; = -50, /* Trying to perform rtp action on invalid session */
                          NoRtpSession
                          ; = -51, /* Codec state not initialized */
                          InvalidCodecState
                          ; = -52, /* Split packet exceeds its limit */
                          PacketTooLarge))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (cond [(or (eq? sym 'None)
                              (eq? sym 'Unknown))
                          (- (i sym))]
                         [(or (eq? sym 'NoCall)
                              (eq? sym 'InvalidState)
                              (eq? sym 'AlreadyInCallWithPeer)
                              (eq? sym 'ReachedCallLimit))
                          (- (+ (i sym) 18))]
                         [(or (eq? sym 'InitializingCodecs)
                              (eq? sym 'SettingVideoResolution)
                              (eq? sym 'SettingVideoBitrate)
                              (eq? sym 'SplittingVideoPayload)
                              (eq? sym 'EncodingVideo)
                              (eq? sym 'EncodingAudio))
                          (- (+ (i sym) 24))]
                         [(or (eq? sym 'SendingPayload)
                              (eq? sym 'CreatingRtpSessions))
                          (- (+ (i sym) 28))]
                         [(or (eq? sym 'NoRtpSession)
                              (eq? sym 'InvalidCodecState)
                              (eq? sym 'PacketTooLarge))
                          (- (+ (i sym) 36))]))
                 #f)))
         
         (define (_ToxAvCapabilities sym)
           (let ([enum (make-enumeration
                        ; 1 << 0
                        '(AudioEncoding
                          ; 1 << 1
                          AudioDecoding
                          ; 1 << 2
                          VideoEncoding
                          ; 1 << 3
                          VideoDecoding))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (expt 2 (i sym)))
                 #f))))
)
