#lang r6rs
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
                        '(None
                          ; internal error
                          Internal
                          ; already has an active call
                          AlreadyInCall
                          ; trying to perform call action while not in a call
                          NoCall
                          ; trying to perform call action while in invalid state
                          InvalidState
                          ; trying to perform rtp action on invalid session
                          NoRtpSession
                          ; indicating packet loss
                          AudioPacketLost
                          ; error in toxav_prepare_transmission()
                          StartingAudioRtp
                          ; error in toxav_prepare_transmission()
                          StartingVideoRtp
                          ; returned in toxav_kill_transmission()
                          TerminatingAudioRtp
                          ; returned in toxav_kill_transmission()
                          TerminatingVideoRtp
                          ; buffer exceeds size while encoding
                          PacketTooLarge))])
             (if (enum-set-member? sym enum)
                 (let ([i (enum-set-indexer enum)])
                   (- (+ (i sym) 1)))
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
