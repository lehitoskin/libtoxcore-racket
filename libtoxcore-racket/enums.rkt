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
                 _TOX_FAERR-index
                 _TOX_USERSTATUS-index
                 _TOX_CHAT_CHANGE_PEER-index
                 _TOX_FILECONTROL-index
                 enum-set-member?)
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
                                   BUSY)))
         (define _TOX_USERSTATUS-index
           (lambda (x)
             (if (enum-set-member? x _TOX_FAERR)
                 (let ((i (enum-set-indexer _TOX_FAERR)))
                   (- (+ (i x) 1)))
                 #f)))
         (define _TOX_CHAT_CHANGE_PEER (make-enumeration
                                       '(ADD
                                         DEL
                                         NAME)))
         (define _TOX_CHAT_CHANGE_PEER-index
           (lambda (x)
             (if (enum-set-member? x _TOX_FAERR)
                 (let ((i (enum-set-indexer _TOX_FAERR)))
                   (- (+ (i x) 1)))
                 #f)))
         ; improvised from line 521-ish of tox.h
         (define _TOX_FILECONTROL (make-enumeration
                                  '(TOX_FILECONTROL_ACCEPT
                                    TOX_FILECONTROL_PAUSE
                                    TOXFILECONTROL_KILL
                                    TOXFILECONTROL_FINISHED
                                    TOX_FILECONTROL_RESUME_BROKEN)))
         (define _TOX_FILECONTROL-index
           (lambda (x)
             (if (enum-set-member? x _TOX_FILECONTROL)
                 (let ((i (enum-set-indexer _TOX_FILECONTROL)))
                   (- (+ (i x) 1)))
                 #f))))