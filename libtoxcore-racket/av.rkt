#lang racket
; libtoxcore-racket/av.rkt
; ffi implementation of libtoxav
(require ffi/unsafe
         ffi/unsafe/define)

(provide (except-out (all-defined-out)
                     define-av
                     _Tox-pointer
                     _int32_t
                     _uint16_t
                     _uint32_t
                     _uint64_t))

(define-ffi-definer define-av (ffi-lib "libtoxav"))

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

(define _int32_t _int32)
(define _uint16_t _uint16)
(define _uint32_t _uint32)
(define _uint64_t _uint64)

; Tox stuff
(define-cstruct _ToxAVCallback ([num _int32_t] [arg _pointer]))
; define ToxAv struct
(define _ToxAv-pointer (_cpointer 'ToxAv))
; define Tox struct
(define _Tox-pointer (_cpointer 'Tox))

(define RTP_PAYLOAD_SIZE 65535)

(define-cstruct _ToxAvCodecSettings
  ([video_bitrate _uint32_t] ; In kbits/s
   [video_width _uint16_t] ; In px
   [video_height _uint16_t] ; In px
   [audio_bitrate _uint32_t] ; In bits/s
   [audio_frame_duration _uint16_t] ; In ms
   [audio_sample_rate _uint32_t] ; In Hz
   [audio_channels _uint32_t]
   [audio_VAD_tolerance _uint32_t] ; In ms
   [jbuf_capacity _uint32_t]))

#|
 # @brief Start new A/V session. There can only be one session at the time. If you register more
 # it will result in undefined behaviour.
 #
 # @param messenger The messenger handle.
 # @param userdata The agent handling A/V session (i.e. phone).
 # @param video_width Width of video frame.
 # @param video_height Height of video frame.
 # @return ToxAv*
 # @retval NULL On error.
 #
 # ToxAv *toxav_new(Tox *messenger, int32_t max_calls);
 |#
(define-av av-new (_fun [messenger : _Tox-pointer]
                        [max_calls : _int32_t] -> _ToxAv-pointer)
  #:c-id toxav_new)

#|
 # @brief Remove A/V session.
 #
 # @param av Handler.
 # @return void
 #
 # void toxav_kill(ToxAv *av)
 |#
(define-av av-kill (_fun [av : _ToxAv-pointer] -> _void)
  #:c-id toxav_kill)

#|
 # @brief Register callback for call state.
 #
 # @param callback The callback
 # @param id One of the ToxAvCallbackID values
 # @return void
 #
 # void toxav_register_callstate_callback (ToxAVCallback callback, ToxAvCallbackID id,
 #                                         void *userdata);
 |#
(define-av register-callstate-callback (_fun [callback : _ToxAVCallback-pointer]
                                             [id : _int]
                                             [userdata : _pointer] -> _void)
  #:c-id toxav_register_callstate_callback)

#|
 # @brief Call user. Use its friend_id.
 #
 # @param av Handler.
 # @param user The user.
 # @param call_type Call type.
 # @param ringing_seconds Ringing timeout.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_call(ToxAv *av, int32_t *call_index, int user, ToxAvCallType call_type
 #                           int ringing_seconds);
 |#
(define-av av-call (_fun [av : _ToxAv-pointer]
                         [call-index : _pointer]
                         [user : _int]
                         [call-type : _int] ; enum value
                         [ringing-seconds : _int] -> _int)
  #:c-id toxav_call)

#|
 # @brief Hangup active call.
 #
 # @param av Handler.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_hangup(ToxAv *av, int32_t call_index);
 |#
(define-av av-hangup (_fun [av : _ToxAv-pointer]
                           [call-index : _int32_t] -> _int)
  #:c-id toxav_hangup)

#|
 # @brief Answer incoming call.
 #
 # @param av Handler.
 # @param call_type Answer with...
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_answer(ToxAv *av, int32_t call_index, ToxAvCallType call_type );
 |#
(define-av av-answer (_fun [av : _ToxAv-pointer]
                           [call-index : _int32_t]
                           [call-type : _int] -> _int)
  #:c-id toxav_answer)

#|
 # @brief Reject incoming call.
 #
 # @param av Handler.
 # @param reason Optional reason. Set NULL if none.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_reject(ToxAv *av, int32_t call_index, const char *reason);
 |#
(define-av av-reject (_fun [av : _ToxAv-pointer]
                           [call-index : _int32_t]
                           [reason : _string] -> _int)
  #:c-id toxav_reject)

#|
 # @brief Cancel outgoing request.
 #
 # @param av Handler.
 # @param reason Optional reason.
 # @param peer_id peer friend_id
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_cancel(ToxAv *av, int32_t call_index, int peer_id, const char *reason);
 |#
(define-av av-cancel (_fun [av : _ToxAv-pointer]
                           [call-index : _int32_t]
                           [peer-id : _int]
                           [reason : _string] -> _int)
  #:c-id toxav_cancel)

#|
 # @brief Terminate transmission. Note that transmission will be terminated without
 # informing remote peer.
 #
 # @param av Handler.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_stop_call(ToxAv *av, int32_t call_index);
 |#
(define-av av-stop-call (_fun [av : _ToxAv-pointer]
                              [call-index : _int32_t] -> _int)
  #:c-id toxav_stop_call)

#|
 # @brief Must be call before any RTP transmission occurs.
 #
 # @param av Handler.
 # @param support_video Is video supported ? 1 : 0
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_prepare_transmission(ToxAv *av, int32_t call_index,
 #                                ToxAvCodecSettings *codec_settings, int support_video);
 |#
(define-av prepare-transmission (_fun [av : _ToxAv-pointer]
                                      [call-index : _int32_t]
                                      [codec-settings : _pointer]
                                      [support-video : _int] -> _int)
  #:c-id toxav_prepare_transmission)

#|
 # @brief Call this at the end of the transmission.
 #
 # @param av Handler.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_kill_transmission(ToxAv *av, int32_t call_index);
 |#
(define-av kill-transmission (_fun [av : _ToxAv-pointer]
                                   [call-index : _int32_t] -> _int)
  #:c-id toxav_kill_transmission)

#|
 # @brief Receive decoded video packet.
 #
 # @param av Handler.
 # @param output Storage.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On Error.
 #
 # int toxav_recv_video ( ToxAv *av, int32_t call_index, vpx_image_t **output);
 |#
(define-av recv-video (_fun [av : _ToxAv-pointer]
                            [call-index : _int32_t]
                            [output : _pointer] -> _int)
  #:c-id toxav_recv_video)

#|
 # @brief Receive decoded audio frame.
 #
 # @param av Handler.
 # @param frame_size The size of dest in frames/samples (one frame/sample is 16 bits or 2 bytes
 # and corresponds to one sample of audio.)
 # @param dest Destination of the raw audio (16 bit signed pcm with AUDIO_CHANNELS channels).
 # Make sure it has enough space for frame_size frames/samples.
 # @return int
 # @retval >=0 Size of received data in frames/samples.
 # @retval ToxAvError On error.
 #
 # int toxav_recv_audio( ToxAv *av, int32_t call_index, int frame_size, int16_t *dest );
 |#
(define-av recv-audio (_fun [av : _ToxAv-pointer]
                            [call-index : _int32_t]
                            [frame-size : _int]
                            [dest : _pointer] -> _int)
  #:c-id toxav_recv_audio)

#|
 # @brief Encode and send video packet.
 #
 # @param av Handler.
 # @param frame The encoded frame.
 # @param frame_size The size of the encoded frame.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_send_video ( ToxAv *av, int32_t call_index, const uint8_t *frame, int frame_size);
 |#
(define-av send-video (_fun [av : _ToxAv-pointer]
                            [call-index : _int32_t]
                            [frame : _pointer]
                            [frame-size : _int] -> _int)
  #:c-id toxav_send_video)

#|
 # @brief Send audio frame.
 #
 # @param av Handler.
 # @param frame The frame (raw 16 bit signed pcm with AUDIO_CHANNELS channels audio.)
 # @param frame_size Its size in number of frames/samples
 #        (one frame/sample is 16 bits or 2 bytes)
 # frame size should be AUDIO_FRAME_SIZE.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_send_audio ( ToxAv *av, int32_t call_index, const uint8_t *frame, int frame_size);
 |#
(define-av send-audio (_fun [av : _ToxAv-pointer]
                            [call-index : _int32_t]
                            [frame : _pointer]
                            [frame-size : _int] -> _int)
  #:c-id toxav_send_audio)

#|
 # @brief Encode video frame
 #
 # @param av Handler
 # @param dest Where to
 # @param dest_max Max size
 # @param input What to encode
 # @return int
 # @retval ToxAvError On error.
 # @retval >0 On success
 #
 # int toxav_prepare_video_frame ( ToxAv *av, int32_t call_index, uint8_t *dest, int dest_max,
 #                                            vpx_image_t *input );
 |#
(define-av prepare-video-frame (_fun [av : _ToxAv-pointer]
                                     [call-index : _int32_t]
                                     [dest : _pointer]
                                     [dest-max : _int]
                                     [input : _pointer] -> _int)
  #:c-id toxav_prepare_video_frame)

#|
 # @brief Encode audio frame
 #
 # @param av Handler
 # @param dest dest
 # @param dest_max Max dest size
 # @param frame The frame
 # @param frame_size The frame size
 # @return int
 # @retval ToxAvError On error.
 # @retval >0 On success
 #
 # int toxav_prepare_audio_frame ( ToxAv *av, int32_t call_index, uint8_t *dest, int dest_max,
 #                                            const int16_t *frame, int frame_size);
 |#
(define-av prepare-audio-frame (_fun [av : _ToxAv-pointer]
                                     [call-index : _int32_t]
                                     [dest : _pointer]
                                     [dest-max : _int]
                                     [frame : _pointer]
                                     [frame-size : _int] -> _int)
  #:c-id toxav_prepare_audio_frame)

#|
 # @brief Get peer transmission type. It can either be audio or video.
 #
 # @param av Handler.
 # @param peer The peer
 # @return int
 # @retval ToxAvCallType On success.
 # @retval ToxAvError On error.
 #
 # int toxav_get_peer_transmission_type ( ToxAv *av, int32_t call_index, int peer );
 |#
(define-av get-peer-transmission-type (_fun [av : _ToxAv-pointer]
                                            [call-index : _int32_t]
                                            [peer : _int] -> _int)
  #:c-id toxav_get_peer_transmission_type)

#|
 # @brief Get id of peer participating in conversation
 #
 # @param av Handler
 # @param peer peer index
 # @return int
 # @retval ToxAvError No peer id
 #
 # int toxav_get_peer_id ( ToxAv *av, int32_t call_index, int peer );
 |#
(define-av get-peer-id (_fun [av : _ToxAv-pointer]
                             [call-index : _int32_t]
                             [peer : _int] -> _int)
  #:c-id toxav_get_peer_id)

#|
 # @brief Is certain capability supported
 #
 # @param av Handler
 # @return int
 # @retval 1 Yes.
 # @retval 0 No.
 #
 # int toxav_capability_supported ( ToxAv *av, int32_t call_index, ToxAvCapabilities capability);
 |#
(define-av capability-supported? (_fun [av : _ToxAv-pointer]
                                       [call-index : _int32_t]
                                       [capability : _int] -> _bool) ; enum value
  #:c-id toxav_capability_supported)

#|
 # @brief Set queue limit
 #
 # @param av Handler
 # @param call_index index
 # @param limit the limit
 # @return void
 #
 # int toxav_set_audio_queue_limit ( ToxAv *av, int32_t call_index, uint64_t limit);
|#
(define-av set-audio-queue-limit (_fun [av : _ToxAv-pointer]
                                       [call-index : _int32_t]
                                       [limit : _uint64_t] -> _int)
  #:c-id toxav_set_audio_queue_limit)

#|
 # @brief Set queue limit
 #
 # @param av Handler
 # @param call_index index
 # @param limit the limit
 # @return void
 #
 # int toxav_set_video_queue_limit ( ToxAv *av, int32_t call_index, uint64_t limit );
 |#
(define-av set-video-queue-limit (_fun [av : _ToxAv-pointer]
                                       [call-index : _int32_t]
                                       [limit : _uint64_t] -> _int)
  #:c-id toxav_set_video_queue_limit)

; Tox *toxav_get_tox(ToxAv *av);
(define-av av-get-tox (_fun [av : _ToxAv-pointer] -> _Tox-pointer)
  #:c-id toxav_get_tox)

#|
 # int toxav_has_activity (ToxAv *av, int32_t call_index, int16_t *PCM, uint16_t frame_size,
 #                                    float ref_energy);
|#
(define-av av-has-activity? (_fun [av : _ToxAv-pointer]
                                  [call-index : _int32_t]
                                  [pcm : _pointer]
                                  [frame-size : _uint16_t]
                                  [ref-energy : _float] -> _bool)
  #:c-id toxav_has_activity)
