(module libtoxcore-racket/enums
  r6rs
; enums.rkt
; implements the TOX enums so that we can access
; and manipulate them. using the _enum from ffi/unsafe
; wasn't working out

(library (libtoxcore-racket enums)
         (export _TOX_USER_STATUS
                 _TOX_MESSAGE_TYPE
                 _TOX_PROXY_TYPE
                 _TOX_ERR_OPTIONS_NEW
                 _TOX_ERR_NEW
                 _TOX_ERR_BOOTSTRAP
                 _TOX_CONNECTION
                 _TOX_ERR_SET_INFO
                 _TOX_ERR_FRIEND_ADD
                 _TOX_ERR_FRIEND_DELETE
                 _TOX_ERR_FRIEND_BY_PUBLIC_KEY
                 _TOX_ERR_FRIEND_GET_PUBLIC_KEY
                 _TOX_ERR_FRIEND_GET_LAST_ONLINE
                 _TOX_ERR_FRIEND_QUERY
                 _TOX_ERR_SET_TYPING
                 _TOX_ERR_FRIEND_SEND_MESSAGE
                 _TOX_FILE_KIND
                 _TOX_FILE_CONTROL
                 _TOX_ERR_FILE_CONTROL
                 _TOX_ERR_FILE_SEEK
                 _TOX_ERR_FILE_GET
                 _TOX_ERR_FILE_SEND
                 _TOX_ERR_FILE_SEND_CHUNK
                 _TOX_ERR_FRIEND_CUSTOM_PACKET
                 _TOX_ERR_GET_PORT
                 _TOX_ERR_ENCRYPTED_NEW
                 _ToxAvCallbackID
                 _ToxAvCallType
                 _ToxAvCallState
                 _ToxAvError
                 _ToxAvCapabilities)
         (import (rnrs))
         
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
         
         (define (_TOX_ERR_OPTIONS_NEW sym)
           (define enum (make-enumeration '(OK MALLOC)))
             (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_NEW sym)
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
                           ; proxy_type was valid but the proxy_host passed had an invalid format
                           ; or was NULL.
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
                           LOAD_BAD_FORMAT)))
           (if (enum-set-member? sym enum)
               ((enum-set-indexer enum) sym)
               #f))
         
         (define (_TOX_ERR_BOOTSTRAP sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            BAD_HOST
                                            BAD_PORT)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_CONNECTION sym)
           (define enum (make-enumeration '(NONE TCP UDP)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_SET_INFO sym)
           (define enum (make-enumeration '(OK NULL TOO_LONG)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_ADD sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            ; the length of the friend request exceeded
                                            ; TOX_MAX_FRIEND_REQUEST_LENGTH
                                            TOO_LONG
                                            ; the friend request message was empty. this, and the TOO_LONG code
                                            ; will never be returned from tox_friend_add_norequest
                                            NO_MESSAGE
                                            ; the friend address belongs to the sending client
                                            OWN_KEY
                                            ; a friend request has already been sent, or the address belongs to
                                            ; a friend that is already in the list
                                            ALREADY_SENT
                                            ; the friend address checksum failed
                                            BAD_CHECKSUM
                                            ; the friend was already there, but the nospam value was different
                                            SET_NEW_NOSPAM
                                            ; a memory allocation failed when trying to increase the friend list size
                                            MALLOC)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_DELETE sym)
           (define enum (make-enumeration '(OK FRIEND_NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_BY_PUBLIC_KEY sym)
           (define enum (make-enumeration '(OK NULL NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_GET_PUBLIC_KEY sym)
           (define enum (make-enumeration '(OK FRIEND_NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_GET_LAST_ONLINE sym)
           (define enum (make-enumeration '(OK FRIEND_NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_QUERY sym)
           (define enum (make-enumeration '(OK NULL FRIEND_NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_SET_TYPING sym)
           (define enum (make-enumeration '(OK FRIEND_NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_SEND_MESSAGE sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            FRIEND_NOT_FOUND
                                            FRIEND_NOT_CONNECTED
                                            ; an allocation error occurred while increasing the send queue size
                                            SENDQ
                                            TOO_LONG
                                            EMPTY)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_FILE_KIND sym)
           (define enum (make-enumeration
                         ; arbitrary file data. clients can choose to handle it based on the file name
                         ; or magic or any other way
                         '(DATA
                           #|
                           # avatar filename. this consists of tox_hash(image).
                           # avatar data. this consists of avatar image data.
                           #
                           # Avatars can be sent at any time the client wishes. Generally, a client will
                           # send the avatar to a friend when that friend comes online, and to all
                           # friends when the avatar changed. A client can save some traffic by
                           # remembering which friend received the updated avatar already and only send
                           # it if the friend has an out of date avatar.
                           #
                           # Clients who receive avatar send requests can reject it (by sending
                           # TOX_FILE_CONTROL_CANCEL before any other controls), or accept it (by
                           # sending TOX_FILE_CONTROL_RESUME). The file_id of length TOX_HASH_LENGTH bytes
                           # (same length as TOX_FILE_ID_LENGTH) will contain the hash. A client can compare
                           # this hash with a saved hash and send TOX_FILE_CONTROL_CANCEL to terminate the avatar
                           # transfer if it matches.
                           #
                           # When file_size is set to 0 in the transfer request it means that the client has no
                           # avatar.
                           |#
                           AVATAR)))
         (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_FILE_CONTROL sym)
           (define enum (make-enumeration
                         ; sent by the receiving side to accept a file send request. also sent after a
                         ; TOX_FILE_CONTROL_PAUSE command to continue sending or receiving
                         '(RESUME
                           #|
                           # Sent by clients to pause the file transfer. The initial state of a file
                           # transfer is always paused on the receiving side and running on the sending
                           # side. If both the sending and receiving side pause the transfer, then both
                           # need to send TOX_FILE_CONTROL_RESUME for the transfer to resume.
                           |#
                           PAUSE
                           ; sent by receiving side to reject a file send request before any other
                           ; commands are sent. also by either side to terminate a file transfer.
                           CANCEL)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FILE_CONTROL sym)
           (define enum (make-enumeration
                         '(OK
                           FRIEND_NOT_FOUND
                           FRIEND_NOT_CONNECTED
                           ; no file transfer with the given file number was found for the given friend
                           NOT_FOUND
                           NOT_PAUSED
                           ; a RESUME control was sent, but the file transfer was paused by the other
                           ; party. only the party that paused the transfer can resume it.
                           DENIED
                           ALREADY_PAUSED
                           ; packet queue is full
                           SENDQ)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FILE_SEEK sym)
           (define enum (make-enumeration
                         '(OK
                           FRIEND_NOT_FOUND
                           FRIEND_NOT_CONNECTED
                           ; no file transfer with the given file number was found for the given friend
                           NOT_FOUND
                           ; file was not in a state where it could be seeked
                           SEEK_DENIED
                           ; seek position was invalid
                           INVALID_POSITION
                           ; packet queue is full
                           SENDQ)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FILE_GET sym)
           (define enum (make-enumeration '(OK
                                            FRIEND_NOT_FOUND
                                            NOT_FOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FILE_SEND sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            FRIEND_NOT_FOUND
                                            FRIEND_NOT_CONNECTED
                                            NAME_TOO_LONG
                                            TOO_MANY)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FILE_SEND_CHUNK sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            FRIEND_NOT_FOUND
                                            FRIEND_NOT_CONNECTED
                                            NOT_FOUND
                                            NOT_TRANSFERRING
                                            INVALID_LENGTH
                                            SENDQ
                                            WRONG_POSITION)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_FRIEND_CUSTOM_PACKET sym)
           (define enum (make-enumeration '(OK
                                            NULL
                                            FRIEND_NOT_FOUND
                                            FRIEND_NOT_CONNECTED
                                            INVALID
                                            EMPTY
                                            TOO_LONG
                                            SENQ)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         (define (_TOX_ERR_GET_PORT sym)
           (define enum (make-enumeration '(OK NOT_BOUND)))
           (if (enum-set-member? sym enum)
                 ((enum-set-indexer enum) sym)
                 #f))
         
         #| ############### libtoxencrypt ################### |#
         
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
                           LOAD_DECRYPTION_FAILED)))
           (if (enum-set-member? sym enum)
               ((enum-set-indexer enum) sym)
               #f))
         
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
