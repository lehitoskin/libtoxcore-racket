(module libtoxcore-racket/av
  racket/base
; libtoxcore-racket/av.rkt
; ffi implementation of libtoxav
(require ffi/unsafe
         ffi/unsafe/define)

(provide (except-out (all-defined-out)
                     define-av
                     _Tox-pointer
                     _int16_t
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

(define _uint8_t _uint8)
(define _int16_t _int16)
(define _int32_t _int32)
(define _uint16_t _uint16)
(define _uint32_t _uint32)
(define _uint64_t _uint64)

; Tox stuff
; define ToxAv struct
(define _ToxAv-pointer (_cpointer 'ToxAv))
; define Tox struct
(define _Tox-pointer (_cpointer 'Tox))

(define RTP_PAYLOAD_SIZE 65535)

(define-cstruct _ToxAvCodecSettings
  ([call_type _int] ; _ToxAvCallType enum value
   
   [video_bitrate _uint32_t] ; In kbits/s
   [video_width _uint16_t] ; In px
   [video_height _uint16_t] ; In px
   
   [audio_bitrate _uint32_t] ; In bits/s
   [audio_frame_duration _uint16_t] ; In ms
   [audio_sample_rate _uint32_t] ; In Hz
   [audio_channels _uint32_t]))

(define av_DefaultSettings _ToxAvCodecSettings)

#|
 # These are the callbacks' prototypes that will be used throughout the wrapper
 # typedef void ( *ToxAVCallback ) ( void *agent, int32_t call_idx, void *arg );
 # typedef void ( *ToxAvAudioCallback ) (void *agent, int32_t call_idx,
 #                const int16_t *PCM, uint16_t size, void *data);
 # typedef void ( *ToxAvVideoCallback ) (void *agent, int32_t call_idx,
 #                const vpx_image_t *img, void *data);
 |#
(define ToxAVCallback
  (_fun [agent : _pointer]
        [call-idx : _int32_t]
        [arg : _pointer] -> _void))
(define ToxAvAudioCallback
  (_fun [agent : _pointer]
        [call-idx : _int32_t]
        [pcm : _pointer]
        [size : _uint16_t]
        [data : _pointer] -> _void))
(define ToxAvVideoCallback
  (_fun [agent : _pointer]
        [call-idx : _int32_t]
        [img : _bytes]
        [data : _pointer] -> _void))

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
(define-av av-kill! (_fun [av : _ToxAv-pointer] -> _void)
  #:c-id toxav_kill)


#|
 * Returns the interval in milliseconds when the next toxav_do() should be called.
 * If no call is active at the moment returns 200.
 #
 # uint32_t toxav_do_interval(ToxAv *av);
 |#
(define-av toxav-do-interval (_fun [av : _ToxAv-pointer] -> _uint32_t)
  #:c-id toxav_do_interval)
  
#|
 # Main loop for the session. Best called right after tox_do();
 #
 # void toxav_do(ToxAv *av);
 |#
(define-av toxav-do (_fun [av : _ToxAv-pointer] -> _void)
  #:c-id toxav_do)

#|
 # @brief Register callback for call state.
 #
 # @param av Handler.
 # @param callback The callback
 # @param id One of the ToxAvCallbackID values
 # @return void
 #
 # void toxav_register_callstate_callback (ToxAv *av, ToxAVCallback callback,
 #                                         ToxAvCallbackID id, void *userdata);
 |#
(define-av callback-callstate (_fun [av : _ToxAv-pointer]
                                    [callback : ToxAVCallback]
                                    [cb-id : _int] ; _ToxAVCallbackID enum value
                                    [userdata : _pointer = #f] -> _void)
  #:c-id toxav_register_callstate_callback)

#|
 #  Register callback for audio data.
 #
 # void toxav_register_audio_callback (ToxAv *av, ToxAvAudioCallback cb, void *userdata);
 |#
(define-av callback-audio-recv (_fun [av : _ToxAv-pointer]
                                     [callback : ToxAvAudioCallback]
                                     [userdata : _pointer = #f] -> _void)
  #:c-id toxav_register_audio_callback)

#|
 # Register callback for video data.
 #
 # void toxav_register_video_callback (ToxAv *av, ToxAvVideoCallback cb, void *userdata);
 |#
(define-av callback-video-recv (_fun [av : _ToxAv-pointer]
                                     [callback : ToxAvVideoCallback]
                                     [userdata : _pointer = #f] -> _void)
  #:c-id toxav_register_video_callback)

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
 # int toxav_call(ToxAv *av, int32_t *call_index, int user,
 #                const ToxAvCSettings *csettings, int ringing_seconds);
 |#
(define-av av-call (_fun [av : _ToxAv-pointer]
                         [call-index : _pointer]
                         [user : _int]
                         [callsettings : _pointer] ; enum value
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
 # int toxav_answer(ToxAv *av, int32_t call_index, const ToxAvCSettings *csettings );
 |#
(define-av av-answer (_fun [av : _ToxAv-pointer]
                           [call-index : _int32_t]
                           [csettings : _pointer] -> _int)
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
 # @brief Notify peer that we are changing call settings
 #
 # @param av Handler.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_change_settings(ToxAv *av, int32_t call_index, const ToxAvCSettings *csettings);
 |#
(define-av av-change-settings (_fun [av : _ToxAv-pointer]
                                    [call-index : _int32_t]
                                    [csettings : _pointer] -> _int)
  #:c-id toxav_change_settings)

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
 # int toxav_prepare_transmission(ToxAv *av, int32_t call_index, uint32_t jbuf_size,
 #                                uint32_t VAD_treshold, int support_video);
 |#
(define-av prepare-transmission (_fun [av : _ToxAv-pointer]
                                      [call-index : _int32_t]
                                      [jbuf-size : _uint32_t]
                                      [VAD-threshold : _uint32_t]
                                      [support-video? : _bool] -> _int)
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
 # @brief Encode and send video packet.
 #
 # @param av Handler.
 # @param frame The encoded frame.
 # @param frame_size The size of the encoded frame.
 # @return int
 # @retval 0 Success.
 # @retval ToxAvError On error.
 #
 # int toxav_send_video ( ToxAv *av, int32_t call_index, const uint8_t *frame,
 #                        unsigned int frame_size);
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
 # int toxav_get_peer_csettings ( ToxAv *av, int32_t call_index, int peer,
 #                                ToxAvCodecSettings* dest );
 |#
(define-av get-peer-csettings (_fun [av : _ToxAv-pointer]
                                    [call-index : _int32_t]
                                    [peer : _int]
                                    [dest : _bytes] -> _int)
  #:c-id toxav_get_peer_csettings)

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
 # @brief Get current call state
 #
 # @param av Handler
 # @param call_index What call
 # @return int
 # @retval ToxAvCallState State id
 #
 # ToxAvCallState toxav_get_call_state ( ToxAv *av, int32_t call_index );
 |#
(define-av get-call-state (_fun [av : _ToxAv-pointer] [call-index : _int32_t] -> _int)
  #:c-id toxav_get_call_state)

#|
 # @brief Is certain capability supported
 #
 # @param av Handler
 # @return int
 # @retval 1 Yes.
 # @retval 0 No.
 #
 # int toxav_capability_supported ( ToxAv *av, int32_t call_index,
 #                                  ToxAvCapabilities capability);
 |#
(define-av capability-supported? (_fun [av : _ToxAv-pointer]
                                       [call-index : _int32_t]
                                       [capability : _int] -> _bool) ; enum value
  #:c-id toxav_capability_supported)

; Tox *toxav_get_tox(ToxAv *av);
(define-av av-get-tox (_fun [av : _ToxAv-pointer] -> _Tox-pointer)
  #:c-id toxav_get_tox)

#|
 # Returns number of active calls or -1 on error.
 # int toxav_get_active_count (ToxAv *av);
 |#
(define-av get-active-calls (_fun [av : _ToxAv-pointer] -> _int)
  #:c-id toxav_get_active_count)

#|
 # Create a new toxav group.
 #
 # return group number on success.
 # return -1 on failure.
 #
 # Audio data callback format:
 # audio_callback(Tox *tox, int groupnumber, int peernumber, const int16_t *pcm,
 #                unsigned int samples, uint8_t channels, unsigned int sample_rate,
 #                void *userdata)
 #
 # Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
 #
 # int toxav_add_av_groupchat(Tox *tox, void (*audio_callback)(Tox *, int, int,
 #                                                             const int16_t *,
 #                                                             unsigned int, uint8_t,
 #                                                             unsigned int, void *),
 #                            void *userdata);
 |#
(define-av add-av-groupchat
  (_fun [tox : _Tox-pointer]
        [audio-callback : (_fun [tox : _Tox-pointer]
                                [groupnumber : _int]
                                [peernumber : _int]
                                [pcm : _bytes]
                                [samples : _int]
                                [channels : _uint8_t]
                                [sample-rate : _int]
                                [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _int)
  #:c-id toxav_add_av_groupchat)

#|
 # Join a AV group (you need to have been invited first.)
 #
 # returns group number on success
 # returns -1 on failure.
 #
 # Audio data callback format (same as the one for toxav_add_av_groupchat()):
 # audio_callback(Tox *tox, int groupnumber, int peernumber, const int16_t *pcm,
 #                unsigned int samples, uint8_t channels, unsigned int sample_rate,
 #                void *userdata)
 #
 # Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
 #
 # int toxav_join_av_groupchat(Tox *tox, int32_t friendnumber, const uint8_t *data,
 #                             uint16_t length,
 #                             void (*audio_callback)(Tox *, int, int, const int16_t *,
 #                                                    unsigned int, uint8_t, unsigned int,
 #                                                    void *),
 #                             void *userdata);
 |#
(define-av join-av-groupchat
  (_fun [tox : _Tox-pointer]
        [friendnumber : _int32_t]
        [data : _bytes]
        [data-len : _uint16_t]
        [audio-callback : (_fun [tox : _Tox-pointer]
                                [groupnumber : _int]
                                [peernumber : _int]
                                [pcm : _bytes]
                                [samples : _int]
                                [channels : _uint8_t]
                                [sample-rate : _int]
                                [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _int)
  #:c-id toxav_join_av_groupchat)

#|
 # Send audio to the group chat.
 #
 # return 0 on success.
 # return -1 on failure.
 #
 # Note that total size of pcm in bytes is equal to (samples * channels * sizeof(int16_t)).
 #
 # Valid number of samples are ((sample rate) * (audio length
 #                              (Valid ones are: 2.5, 5, 10, 20, 40 or 60 ms)) / 1000)
 # Valid number of channels are 1 or 2.
 # Valid sample rates are 8000, 12000, 16000, 24000, or 48000.
 #
 # Recommended values are: samples = 960, channels = 1, sample_rate = 48000
 #
 # TODO: currently the only supported sample rate is 48000.
 #
 # int toxav_group_send_audio(Tox *tox, int groupnumber, const int16_t *pcm,
 #                            unsigned int samples, uint8_t channels, unsigned int sample_rate);
 |#
(define-av group-send-audio (_fun [tox : _Tox-pointer]
                                  [groupnumber : _int]
                                  [pcm : _bytes]
                                  [samples : _int]
                                  [channels : _uint8_t]
                                  [sample-rate : _int] -> _int)
  #:c-id toxav_group_send_audio)
)
