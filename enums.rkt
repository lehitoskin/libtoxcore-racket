(module libtoxcore-racket/enums
  r6rs
; enums.rkt
; implements the TOX enums so that we can access
; and manipulate them. using the _enum from ffi/unsafe
; wasn't working out

(library (examples hello)
         (export _TOX_FAERR
                 _TOX_USERSTATUS
                 _TOX_CHAT_CHANGE_PEER
                 _TOX_FILECONTROL
                 _ToxAvCallbackID
                 _ToxAvCallType
                 _ToxAvCallState
                 _ToxAvError
                 _ToxAvCapabilities
                 _TOX_AVATAR_FORMAT
                 _TOX_GROUPCHAT_TYPE)
         (import (rnrs))
         ; enum definitions
         ; Errors for m_addfriend
         ; FAERR - Friend Add Error
         ; enum starts at -1 and decrements from that point
         (define (_TOX_FAERR sym)
           (let ([enum (make-enumeration
                        '(TOOLONG
                          NOMESSAGE
                          OWNKEY
                          ALREADYSENT
                          UNKNOWN
                          BADCHECKSUM
                          SETNEWNOSPAM
                          NOMEM))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (- (+ (i sym) 1)))
                 #f)))
         
         ; USERSTATUS -
         ; Represents userstatuses someone can have.
         (define (_TOX_USERSTATUS sym)
           (let ([enum (make-enumeration
                        '(NONE
                          AWAY
                          BUSY
                          INVALID))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
         (define (_TOX_CHAT_CHANGE_PEER sym)
           (let ([enum (make-enumeration
                        '(ADD
                          DEL
                          NAME))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (i sym))
                 #f)))
         
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
         
         #| ############### BEGIN AV ENUMERATIONS ############# |#
         (define (_ToxAvCallbackID sym)
           (let ([enum (make-enumeration
                        ; requests
                        '(Invite
                          Start
                          Cancel
                          Reject
                          End
                          ; responses
                          Ringing
                          Starting
                          Ending
                          ; protocol
                          RequestTimeout
                          PeerTimeout
                          MediaChange))])
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
                          CallHanged_up))])
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
                          ; = -21, /* Trying to perform call action while in invalid state*/
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
                          ; = -52, /* Split packet exceeds it's limit */
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
