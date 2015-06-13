(module libtoxcore-racket/enums
  racket/base
  (require ffi/unsafe)
  (provide (all-defined-out))
  ; enums.rkt
  
  (define _TOX-USER-STATUS (_enum '(available away busy)))
  (define _TOX-MESSAGE-TYPE (_enum '(normal action)))
  (define _TOX-PROXY-TYPE (_enum '(none http socks5)))
  (define _TOX-SAVEDATA-TYPE (_enum '(none tox-save secret-key)))
  (define _TOX-ERR-OPTIONS-NEW (_enum '(ok malloc)))
  
  (define _TOX-ERR-NEW
    (_enum '(ok
             null
             ; The function was unable to allocate enough memory to store the internal
             ; structures for the Tox object.
             malloc
             ; The function was unable to bind to a port. This may mean that all ports
             ; have already been bound, e.g. by other Tox instances, or it may mean
             ; a permission error. You may be able to gather more information from errno.
             port-alloc
             ; proxy_type was invalid.
             proxy-bad-type
             ; proxy_type was valid but the proxy_host passed had an invalid format
             ; or was NULL.
             proxy-bad-host
             ; proxy_type was valid, but the proxy_port was invalid.
             proxy-bad-port
             ; The proxy host passed could not be resolved.
             proxy-not-found
             ; The byte array to be loaded contained an encrypted save.
             load-encrypted
             ; The data format was invalid. This can happen when loading data that was
             ; saved by an older version of Tox, or when the data has been corrupted.
             ; When loading from badly formatted data, some data may have been loaded,
             ; and the rest is discarded. Passing an invalid length parameter also
             ; causes this error.
             load-bad-format)))
  
  (define _TOX-ERR-BOOTSTRAP (_enum '(ok null bad-host bad-port)))
  (define _TOX-CONNECTION (_enum '(none tcp udp)))
  (define _TOX-ERR-SET-INFO (_enum '(ok null too-long)))
  
  (define _TOX-ERR-FRIEND-ADD
    (_enum '(ok
             null
             ; the length of the friend request exceeded
             ; TOX_MAX_FRIEND_REQUEST_LENGTH
             too-long
             ; the friend request message was empty. this, and the TOO_LONG code
             ; will never be returned from tox_friend_add_norequest
             no-message
             ; the friend address belongs to the sending client
             own-key
             ; a friend request has already been sent, or the address belongs to
             ; a friend that is already in the list
             already-sent
             ; the friend address checksum failed
             bad-checksum
             ; the friend was already there, but the nospam value was different
             set-new-nospam
             ; a memory allocation failed when trying to increase the friend list size
             malloc)))
  (define _TOX-ERR-FRIEND-DELETE (_enum '(ok friend-not-found)))
  (define _TOX-ERR-FRIEND-BY-PUBLIC-KEY (_enum '(ok null not-found)))
  (define _TOX-ERR-FRIEND-GET-PUBLIC-KEY (_enum '(ok friend-not-found)))
  (define _TOX-ERR-FRIEND-GET-LAST-ONLINE (_enum '(ok friend-not-found)))
  (define _TOX-ERR-FRIEND-QUERY (_enum '(ok null friend-not-found)))
  (define _TOX-ERR-SET-TYPING (_enum '(ok friend-not-found)))
         
  (define _TOX-ERR-FRIEND-SEND-MESSAGE
    (_enum '(ok
             null
             friend-not-found
             friend-not-connected
             sendq ; an allocation error occurred while increasing the send queue size
             too-long
             empty)))
         
  (define _TOX-FILE-KIND
    (_enum
     ; arbitrary file data. clients can choose to handle it based on the file name
     ; or magic or any other way
     '(data
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
       avatar)))
  
  (define _TOX-FILE-CONTROL
    (_enum
     ; sent by the receiving side to accept a file send request. also sent after a
     ; TOX_FILE_CONTROL_PAUSE command to continue sending or receiving
     '(resume
       #|
       # Sent by clients to pause the file transfer. The initial state of a file
       # transfer is always paused on the receiving side and running on the sending
       # side. If both the sending and receiving side pause the transfer, then both
       # need to send TOX_FILE_CONTROL_RESUME for the transfer to resume.
       |#
       pause
       ; sent by receiving side to reject a file send request before any other
       ; commands are sent. also by either side to terminate a file transfer.
       cancel)))
  
  (define _TOX-ERR-FILE-CONTROL
    (_enum '(ok
             friend-not-found
             friend-not-connected
             ; no file transfer with the given file number was found for the given friend
             not-found
             not-paused
             ; a RESUME control was sent, but the file transfer was paused by the other
             ; party. only the party that paused the transfer can resume it.
             denied
             already-paused
             ; packet queue is full
             sendq)))
  
  (define _TOX-ERR-FILE-SEEK
    (_enum '(ok
             friend-not-found
             friend-not-connected
             ; no file transfer with the given file number was found for the given friend
             transfer-not-found
             ; file was not in a state where it could be seeked
             seek-denied
             ; seek position was invalid
             invalid-position
             ; packet queue is full
             sendq)))
  
  (define _TOX-ERR-FILE-GET
    (_enum '(ok null friend-not-found transfer-not-found)))
  
  (define _TOX-ERR-FILE-SEND
    (_enum '(ok null friend-not-found friend-not-connected name-too-long too-many)))
  
  (define _TOX-ERR-FILE-SEND-CHUNK
    (_enum '(ok null friend-not-found friend-not-connected not-found
                not-transferring invalid-length senq wrong-position)))
  
  (define _TOX-ERR-FRIEND-CUSTOM-PACKET
    (_enum '(ok null friend-not-found friend-not-connected invalid
                empty too-long sendq)))
  
  (define _TOX-ERR-GET-PORT (_enum '(ok not-bound)))
  
  #| ############### libtoxencrypt ################### |#
  
  (define _TOX-ERR-KEY-DERIVATION (_enum '(ok null failed)))
  
  (define _TOX-ERR-ENCRYPTION
    (_enum '(ok
             ; some input data, or maybe the output pointer, was null
             null
             ; the crypto lib was unable to derive a key from the given passphrase,
             ; which is usually a lack of memory issue. the functions accepting keys
             ; do not produce this error
             key-derivation-failed
             ; the encryption itself failed
             encryption-failed)))
  
  (define _TOX-ERR-DECRYPTION
    (_enum '(ok null invalid-length bad-format key-derivation-failed decryption-failed)))
  
  #| ############### tox_old.h groupchat stuff ######### |#
  
  (define _TOX-GROUPCHAT-TYPE (_enum '(text av)))
  (define _TOX-CHAT-CHANGE-PEER (_enum '(add del name)))
  
  #| ############### BEGIN AV ENUMERATIONS ############# |#
  (define _ToxAvCallbackID
    (_enum  ; incoming call
     '(invite
       ; when peer is ready to accept/reject call
       ringing
       ; call (rtp transmission) started
       start
       ; the side that initiated the call canceled invite
       cancel
       ; the side that was invited rejected the call
       reject
       ; the call that was active has ended
       end
       ; when the request didn't get a response in time
       request-timeout
       ; peer timed out; stop the call
       peer-timeout
       ; peer changed csettings. prepare for changed av
       peer-cs-change
       ; csettings change confirmation. once triggered peer
       ; is ready to receive changed av
       self-cs-change)))
         
  (define _ToxAvCallType (_enum '(audio = 192
                                   video)))
         
  (define _ToxAvCallState
    (_enum '(call-nonexistant = -1
             ; when sending call invite
             call-inviting
             ; when getting call invite
             call-starting
             call-active
             call-hold
             call-hanged-up)))
         
  (define _ToxAvError
    (_enum '(none
             ; Unknown error
             unknown = -1
             ; Trying to perform call action while not in a call
             no-call = -20
             ; Trying to perform call action while in an invalid state
             invalid-state = -21
             ; Trying to call peer when already in a call with peer
             already-in-call-with-peer = -22
             ; Cannot handle more calls
             reached-call-limit = -23
             ; Failed creating CSSession
             initializing-codecs = -30
             ; Error setting resolution
             setting-video-resolution = -31
             ; Error setting bitrate
             setting-video-bitrate = -32
             ; Error splitting video payload
             splitting-video-payload = -33
             ; vpx_codec_encode failed
             encoding-video = -34
             ; opus_encode failed
             encoding-audio = -35
             ; Sending lossy packet failed
             sending-payload = -40
             ; One of the rtp sessions failed to initialize
             creating-rtp-sessions = -41
             ; Trying to perform rtp action on invalid session
             no-rtp-session = -50
             ; Codec state not initialized
             invalid-codec-state = -51
             ; Split packet exceeds its limit
             packet-too-large = -52)))
         
  (define _ToxAvCapabilities
    (_enum ; 1 << 0
     '(audio-encoding
       ; 1 << 1
       audio-decoding
       ; 1 << 2
       video-encoding
       ; 1 << 3
       video-decoding)))
)
