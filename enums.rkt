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
                 _ToxAvError
                 _ToxAvCapabilities
                 _TOX_FAERR-index
                 _TOX_USERSTATUS-index
                 _TOX_CHAT_CHANGE_PEER-index
                 _TOX_FILECONTROL-index
                 _ToxAvCallbackID-index
                 _ToxAvCallType-index
                 _ToxAvError-index
                 _ToxAvCapabilities-index)
         (import (rnrs))
         ; enum definitions
         ; Errors for m_addfriend
         ; FAERR - Friend Add Error
         (define _TOX_FAERR (make-enumeration
                             '(TOOLONG
                               NOMESSAGE
                               OWNKEY
                               ALREADYSENT
                               UNKNOWN
                               BADCHECKSUM
                               SETNEWNOSPAM
                               NOMEM)))
         ; enum starts at -1 and decrements from that point
         (define _TOX_FAERR-index
           (lambda (x)
             (if (enum-set-member? x _TOX_FAERR)
                 (let ((i (enum-set-indexer _TOX_FAERR)))
                   (- (+ (i x) 1)))
                 #f)))
         ; USERSTATUS -
         ; Represents userstatuses someone can have.
         (define _TOX_USERSTATUS (make-enumeration
                                  '(NONE
                                    AWAY
                                    BUSY
                                    INVALID)))
         (define _TOX_USERSTATUS-index
           (lambda (x)
             (if (enum-set-member? x _TOX_USERSTATUS)
                 (let ((i (enum-set-indexer _TOX_USERSTATUS)))
                   (i x))
                 #f)))
         (define _TOX_CHAT_CHANGE_PEER (make-enumeration
                                        '(ADD
                                          DEL
                                          NAME)))
         (define _TOX_CHAT_CHANGE_PEER-index
           (lambda (x)
             (if (enum-set-member? x _TOX_CHAT_CHANGE_PEER)
                 (let ((i (enum-set-indexer _TOX_CHAT_CHANGE_PEER)))
                   (i x))
                 #f)))
         ; improvised from line 521-ish of tox.h
         (define _TOX_FILECONTROL (make-enumeration
                                   '(ACCEPT
                                     PAUSE
                                     KILL
                                     FINISHED
                                     RESUME_BROKEN)))
         (define _TOX_FILECONTROL-index
           (lambda (x)
             (if (enum-set-member? x _TOX_FILECONTROL)
                 (let ((i (enum-set-indexer _TOX_FILECONTROL)))
                   (i x))
                 #f)))
         
         #| ############### BEGIN AV ENUMERATIONS ############# |#
         (define _ToxAvCallbackID (make-enumeration
                                   ; requests
                                   '(av_OnInvite
                                     av_OnStart
                                     av_OnCancel
                                     av_OnReject
                                     av_OnEnd
                                     ; responses
                                     av_OnRinging
                                     av_OnStarting
                                     av_OnEnding
                                     ; protocol
                                     av_OnError
                                     av_OnRequestTimeout
                                     av_OnPeerTimeout)))
         (define _ToxAvCallbackID-index
           (lambda (x)
             (if (enum-set-member? x _ToxAvCallbackID)
                 (let ((i (enum-set-indexer _ToxAvCallbackID)))
                   (i x))
                 #f)))
         (define _ToxAvCallType (make-enumeration
                                 '(Audio
                                   Video)))
         (define _ToxAvCallType-index
           (lambda (x)
             (if (enum-set-member? x _ToxAvCallType)
                 (let ((i (enum-set-indexer _ToxAvCallType)))
                   (+ (i x) 192))
                 #f)))
         (define _ToxAvError (make-enumeration
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
                                PacketTooLarge)))
         (define _ToxAvError-index
           (lambda (x)
             (if (enum-set-member? x _ToxAvError)
                 (let ((i (enum-set-indexer _ToxAvError)))
                   (- (+ (i x) 1)))
                 #f)))
         (define _ToxAvCapabilities (make-enumeration
                                     ; 1 << 0
                                     '(AudioEncoding
                                       ; 1 << 1
                                       AudioDecoding
                                       ; 1 << 2
                                       VideoEncoding
                                       ; 1 << 3
                                       VideoDecoding)))
         (define _ToxAvCapabilities-index
           (lambda (x)
             (if (enum-set-member? x _ToxAvCapabilities)
                 (let ((i (enum-set-indexer _ToxAvCapabilities)))
                   (expt 2 (i x)))
                 #f))))