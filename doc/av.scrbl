#lang scribble/doc
@(require "common.rkt")

@title[#:tag "av"]{Audio/Video}

@defmodule[libtoxcore-racket/av]

The functions in @racketmodname[libtoxcore-racket/av] pertain to Audio/Video interaction.

@section[#:tag "structs"]{Structs}

@defstruct[_ToxAvCallback ([num integer?] [arg cpointer?])]{
  A cstruct for the callback functions.
}

@defstruct[_ToxAvCodecSettings ([video_bitrate integer?]
                                [video_width integer?]
                                [video_height integer?]
                                [audio_bitrate integer?]
                                [audio_frame_duration integer?]
                                [audio_sample_rate integer?]
                                [audio_channels integer?]
                                [audio_VAD_tolerance integer?]
                                [jbuf_capacity integer?])]{
  @racket[video_bitrate] is in kbit/s
  
  @racket[video_width] is in px
  
  @racket[video_height] is in px
  
  @racket[audio_bitrate] is in bits/s
  
  @racket[audio_frame_duration] is in ms
  
  @racket[audio_sample_rate] is in Hz
  
  @racket[audio_VAD_tolerance] is in ms
}

@section[#:tag "procedures"]{Procedures}

@defproc[(av-new [messenger _Tox-pointer] [max_calls integer?]) _ToxAv-pointer]{
  Start new A/V session. There can only be one session at the time.
  If you register more it will result in undefined behaviour.
  
  return _ToxAv-pointer
  
  return NULL On error.
}

@defproc[(av-kill! [av _ToxAv-pointer]) void?]{
  Remove A/V session.
  
  return void
}

@defproc[(register-callstate-callback [callback _ToxAVCallback-pointer]
                                      [id integer?] [userdata pointer?]) void?]{
  Register callback for call state.
 
  @tt{callback} is the callback
  
  @tt{id} is one of the ToxAvCallbackID values
  
  return void
}

@defproc[(av-call [av _ToxAv-pointer]
                  [call-index cpointer?]
                  [user integer?]
                  [call-type integer?]
                  [ringing-seconds integer?]) integer?]{
  Call user. Use its friend_id.
 
  @tt{user} is the user.
  
  @tt{call-type} is the call type, an enum value
  
  @tt{ringing-seconds} is the ringing timeout.
  
  return 0 on success.
  
  return @tt{ToxAvError} on error.
}

@defproc[(av-hangup [av  _ToxAv-pointer]
                    [call-index integer?]) integer?]{
  Hangup active call.
 
  return 0 on success.
  
  return @tt{ToxAvError} on error.
}

@defproc[(av-answer [av _ToxAv-pointer]
                    [call-index integer?]
                    [call-type integer?]) integer?]

@defproc[(av-reject [av _ToxAv-pointer]
                 [call-index integer?]
                 [reason string?]) integer?]

@defproc[(av-cancel [av _ToxAv-pointer]
                    [call-index integer?]
                           [peer-id integer?]
                           [reason string?]) integer?]

@defproc[(av-stop-call [av _ToxAv-pointer]
                       [call-index integer?]) integer?]

@defproc[(prepare-transmission [av _ToxAv-pointer]
                               [call-index integer?]
                               [codec-settings cpointer?]
                               [support-video integer?]) integer?]

@defproc[(kill-transmission [av _ToxAv-pointer]
                            [call-index integer?]) integer?]

@defproc[(recv-video [av _ToxAv-pointer]
                     [call-index integer?]
                     [output cpointer?]) integer?]

@defproc[(recv-audio [av _ToxAv-pointer]
                     [call-index integer?]
                            [frame-size integer?]
                            [dest cpointer?]) integer?]

@defproc[(send-video [av _ToxAv-pointer]
                     [call-index integer?]
                     [frame cpointer?]
                     [frame-size integer?]) integer?]

@defproc[(prepare-video-frame [av _ToxAv-pointer]
                              [call-index integer?]
                              [dest cpointer?]
                              [dest-max integer?]
                              [input cpointer?]) integer?]

@defproc[(prepare-audio-frame [av _ToxAv-pointer]
                              [call-index integer?]
                              [dest cpointer?]
                              [dest-max integer?]
                              [frame cpointer?]
                              [frame-size integer?]) integer?]

@defproc[(get-peer-transmission-type [av _ToxAv-pointer]
                                     [call-index integer?]
                                     [peer integer?]) integer?]

@defproc[(get-peer-id [av _ToxAv-pointer]
                      [call-index integer?]
                      [peer integer?]) integer?]

@defproc[(capability-supported? [av _ToxAv-pointer]
                                [call-index integer?]
                                [capability integer?]) boolean?]

@defproc[(set-audio-queue-limit [av _ToxAv-pointer]
                                [call-index integer?]
                                [limit integer?]) integer?]

@defproc[(set-video-queue-limit [av _ToxAv-pointer]
                                [call-index integer?]
                                [limit integer?]) integer?]

@defproc[(av-get-tox [av _ToxAv-pointer]) _Tox-pointer]

@defproc[(av-has-activity? [av _ToxAv-pointer]
                           [call-index integer?]
                           [pcm cpointer?]
                           [frame-size integer]
                           [ref-energy inexact?]) boolean?]
