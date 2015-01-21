(module libtoxcore-racket/functions
  racket/base
; libtoxcore-racket/functions.rkt
; FFI implementation of libtoxcore
(require ffi/unsafe
         ffi/unsafe/define)
(provide (except-out (all-defined-out)
                     define-tox
                     _int32_t
                     _uint8_t
                     _uint16_t
                     _uint32_t
                     _uint64_t))

(define-ffi-definer define-tox (ffi-lib "libtoxcore"))

#|###################
 # type definitions #
 ################## |#

; *_t definitions
(define _int32_t _int32)
(define _uint8_t _uint8)
(define _uint16_t _uint16)
(define _uint32_t _uint32)
(define _uint64_t _uint64)

; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)

; define Tox struct
(define _Tox-pointer (_cpointer 'Tox))

(define TOX_MAX_NAME_LENGTH 128)
; Maximum length of single messages after which they should be split.
(define TOX_MAX_MESSAGE_LENGTH 1368)
(define TOX_MAX_STATUSMESSAGE_LENGTH 1007)
(define TOX_MAX_FRIENDREQUEST_LENGTH 1016)
(define TOX_CLIENT_ID_SIZE 32)

(define TOX_FRIEND_ADDRESS_SIZE (+ TOX_CLIENT_ID_SIZE
                                   (ctype-sizeof _uint32_t) (ctype-sizeof _uint16_t)))
(define TOX_ENABLE_IPV6_DEFAULT #t)
(define TOX_AVATAR_MAX_DATA_LENGTH 16384)
(define TOX_AVATAR_HASH_LENGTH 32)
(define TOX_HASH_LENGTH TOX_AVATAR_HASH_LENGTH)

(define-cstruct _Tox-Options
 #|
  # The type of UDP socket created depends on ipv6enabled:
  # If set to 0 (zero), creates an IPv4 socket which subsequently only allows
  # IPv4 communication
  # If set to anything else (default), creates an IPv6 socket which allows both IPv4 AND
  # IPv6 communication
  |#
 ([ipv6-enabled? _bool]

 #|
  # Set to 1 to disable udp support. (default: 0)
  # This will force Tox to use TCP only which may slow things down.
  # Disabling udp support is necessary when using proxies or Tor.
  |#
 [udp-disabled? _bool]
 [proxy-type _uint8_t] ; a value from TOX_PROXY_TYPE
 [proxy-address _string] ; proxy IP or domain
 [proxy-port _uint16_t])) ; proxy port in host byte order

#| ############# enum definitions have moved to enums.rkt which uses r6rs ################# |#


#|#######################
 # function definitions #
 ###################### |#

#|
 # NOTE: Strings in Tox are all UTF-8, (This means that there is no terminating NULL character.)
 #
 # The exact buffer you send will be received at the other end without modification.
 #
 # Do not treat Tox strings as C strings.
 |#

#|
 # return TOX_FRIEND_ADDRESS_SIZE byte address to give to others.
 # format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
 #
 # void tox_get_address(Tox *tox, uint8_t *address);
 |#
(define-tox get-self-address
  (_fun [tox : _Tox-pointer]
        [address : _bytes = (make-bytes TOX_FRIEND_ADDRESS_SIZE)]
        -> _void
        -> address)
  #:c-id tox_get_address)

#|
 # Add a friend.
 # Set the data that will be sent along with friend request.
 # address is the address of the friend (returned by getaddress of the friend you wish to add)
 # it must be TOX_FRIEND_ADDRESS_SIZE bytes. TODO: add checksum.
 # data is the data and length is the length.
 #
 #  return the friend number if success.
 #  return TOX_FA_TOOLONG if message length is too long.
 #  return TOX_FAERR_NOMESSAGE if no message (message length must be >= 1 byte).
 #  return TOX_FAERR_OWNKEY if user's own key.
 #  return TOX_FAERR_ALREADYSENT if friend request already sent or already a friend.
 #  return TOX_FAERR_UNKNOWN for unknown error.
 #  return TOX_FAERR_BADCHECKSUM if bad checksum in address.
 #  return TOX_FAERR_SETNEWNOSPAM if the friend was already there but the nospam was different.
 #  (the nospam for that friend was set to the new one).
 #  return TOX_FAERR_NOMEM if increasing the friend list size fails.
 #
 # int32_t tox_add_friend(Tox *tox, uint8_t *address, uint8_t *data, uint16_t length);
 |#
(define-tox add-friend (_fun [tox : _Tox-pointer]
                             [address : _bytes]
                             [message : _string]
                             [message-length : _uint16_t = (bytes-length
                                                            (string->bytes/utf-8 message))]
                             -> _int32_t)
  #:c-id tox_add_friend)

#|
 # Add a friend without sending a friendrequest.
 #  return the friend number if success.
 #  return -1 if failure.
 #
 # int32_t tox_add_friend_norequest(Tox *tox, uint8_t *client_id);
 |#
; client_id is the bytes form of the Tox ID
(define-tox add-friend-norequest (_fun [tox : _Tox-pointer]
                                       [client-id : _gcpointer]
                                       -> (success : _int32_t)
                                       -> (if (= -1 success)
                                              #f
                                              success))
  #:c-id tox_add_friend_norequest)

#|
 #  return the friend number associated to that client id.
 #  return -1 if no such friend
 # int32_t tox_get_friend_number(Tox *tox, uint8_t *client_id);
 |#
; client_id is the bytes form of the Tox ID
(define-tox get-friend-number (_fun [tox : _Tox-pointer]
                                    [client-id : _bytes]
                                    -> (success : _int32_t)
                                    -> (if (= -1 success)
                                           #f
                                           success))
  #:c-id tox_get_friend_number)

#|
 # Copies the public key associated to that friend id into client_id buffer.
 # Make sure that client_id is of size CLIENT_ID_SIZE.
 #  return 0 if success.
 #  return -1 if failure.
 #
 # int tox_get_client_id(Tox *tox, int32_t friend_id, uint8_t *client_id);
 |#
(define-tox get-client-id (_fun [tox : _Tox-pointer]
                                [friendnumber : _int32_t]
                                [client-id : _bytes = (make-bytes TOX_CLIENT_ID_SIZE)]
                                -> (copied : _int)
                                -> (if (= -1 copied)
                                       #f
                                       client-id))
  #:c-id tox_get_client_id)

#|
 # Remove a friend.
 # 
 # return 0 if success.
 # return -1 if failure.
 #
 # int tox_del_friend(Tox *tox, int32_t friendnumber);
 |#
(define-tox del-friend! (_fun [tox : _Tox-pointer]
                             [friendnumber : _int32_t]
                             -> (success : _int)
                             -> (if (= -1 success)
                                    #f
                                    #t))
  #:c-id tox_del_friend)

#|
 # Checks friend's connecting status.
 #
 #  return 1 if friend is connected to us (Online).
 #  return 0 if friend is not connected to us (Offline).
 #  return -1 on failure.
 #
 # int tox_get_friend_connection_status(Tox *tox, int32_t friendnumber);
 |#
(define-tox get-friend-connection-status (_fun [tox : _Tox-pointer]
                                               [friendnumber : _int32_t] -> _int)
  #:c-id tox_get_friend_connection_status)

#|
 # Checks if there exists a friend with given friendnumber.
 #
 #  return 1 if friend exists.
 #  return 0 if friend doesn't exist.
 #
 # int tox_friend_exists(Tox *tox, int32_t friendnumber);
 |#
(define-tox friend-exists? (_fun [tox : _Tox-pointer]
                                 [friendnumber : _int32_t] -> _bool)
  #:c-id tox_friend_exists)

#|
 # Send a text chat message to an online friend.
 #
 #  return the message id if packet was successfully put into the send queue.
 #  return 0 if it was not.
 #
 #  maximum length of messages is TOX_MAX_MESSAGE_LENGTH, your client must split larger messages
 #  or else sending them will not work. No the core will not split messages for you because that
 #  requires me to parse UTF-8.
 #
 # You will want to retain the return value, it will be passed to your read_receipt callback
 # if one is received.
 #
 # uint32_t tox_send_message(Tox *tox, int32_t friendnumber, uint8_t *message, uint32_t length);
 # uint32_t tox_send_message_withid(Tox *tox, int32_t friendnumber, uint32_t theid,
 #                                  uint8_t *message, uint32_t length);
 |#
(define-tox send-message (_fun [tox : _Tox-pointer]
                               [friendnumber : _int32_t]
                               [message : _bytes]
                               [len : _uint32_t = (bytes-length message)] -> _uint32_t)
  #:c-id tox_send_message)

#|
 # Send an action to an online friend.
 #
 #  return the message id if packet was successfully put into the send queue.
 #  return 0 if it was not.
 #
 #  maximum length of messages is TOX_MAX_MESSAGE_LENGTH, your client must split larger messages
 #  or else sending them will not work. No the core will not split messages for you because that
 #  requires me to parse UTF-8.
 #
 #  You will want to retain the return value, it will be passed to your read_receipt callback
 #  if one is received.
 #
 # uint32_t tox_send_action(Tox *tox, int32_t friendnumber, uint8_t *action, uint32_t length);
 # uint32_t tox_send_action_withid(Tox *tox, int32_t friendnumber, uint32_t theid,
 #                                 uint8_t *action, uint32_t length);
 |#
(define-tox send-action (_fun [tox : _Tox-pointer]
                              [friendnumber : _int32_t]
                              [action : _bytes]
                              [len : _uint32_t = (bytes-length action)] -> _uint32_t)
  #:c-id tox_send_action)

#|
 # Set our nickname.
 # name must be a string of maximum MAX_NAME_LENGTH length.
 # length must be at least 1 byte.
 # length is the length of name with the NULL terminator.
 #
 #  return 0 if success.
 #  return -1 if failure.
 #
 # int tox_set_name(Tox *tox, uint8_t *name, uint16_t length);
 |#
(define-tox set-name! (_fun [tox : _Tox-pointer]
                            [name : _string]
                            [len : _uint16_t = (bytes-length
                                                (string->bytes/utf-8 name))]
                            -> (success : _int)
                            -> (cond [(zero? success)]
                                     [else #f]))
  #:c-id tox_set_name)

#|
 # Get your nickname.
 # m - The messenger context to use.
 # name - needs to be a valid memory location with a size of
 # at least MAX_NAME_LENGTH (128) bytes.
 #
 #  return length of name.
 #  return 0 on error.
 #
 # uint16_t tox_get_self_name(Tox *tox, uint8_t *name);
 |#
(define-tox get-self-name (_fun [tox : _Tox-pointer]
                                [name : _bytes = (make-bytes TOX_MAX_NAME_LENGTH)]
                                -> (len : _uint16_t)
                                -> (if (zero? len)
                                       len
                                       (subbytes name 0 len)))
  #:c-id tox_get_self_name)

#|
 # Get name of friendnumber and put it in name.
 # name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
 #
 #  return length of name if success.
 #  return -1 if failure.
 #
 # int tox_get_name(Tox *tox, int32_t friendnumber, uint8_t *name);
 |#
(define-tox get-name (_fun [tox : _Tox-pointer]
                           [friendnumber : _int32_t]
                           [name : _bytes = (make-bytes TOX_MAX_NAME_LENGTH)]
                           -> (len : _int)
                           -> (if (= -1 len)
                                  #f
                                  (subbytes name 0 len)))
  #:c-id tox_get_name)

#|
 #  returns the length of name on success.
 #  returns -1 on failure.
 #
 # int tox_get_name_size(Tox *tox, int32_t friendnumber);
 # int tox_get_self_name_size(Tox *tox);
 |#
(define-tox get-name-size (_fun [tox : _Tox-pointer]
                                [friendnumber : _int32_t]
                                -> (success : _int)
                                -> (if (= -1 success)
                                       #f
                                       success))
  #:c-id tox_get_name_size)
(define-tox get-self-name-size (_fun [tox : _Tox-pointer]
                                     -> (success : _int)
                                     -> (if (= -1 success)
                                            #f
                                            success))
  #:c-id tox_get_self_name_size)

#|
 # Set our user status.
 #
 # userstatus must be one of TOX_USERSTATUS values.
 # max length of the status is TOX_MAX_STATUSMESSAGE_LENGTH.
 #
 #  returns 0 on success.
 #  returns -1 on failure.
 #
 # int tox_set_status_message(Tox *tox, uint8_t *status, uint16_t length);
 # int tox_set_user_status(Tox *tox, uint8_t userstatus);
 |#
(define-tox set-status-message! (_fun [tox : _Tox-pointer]
                                     [status : _string]
                                     [len : _uint16_t = (bytes-length
                                                         (string->bytes/utf-8
                                                          status))]
                                     -> (success : _int)
                                     -> (cond [(zero? success)]
                                              [else #f]))
  #:c-id tox_set_status_message)
(define-tox set-user-status! (_fun [tox : _Tox-pointer]
                                  [userstatus : _uint8_t]
                                  -> (success : _int) ; enum value
                                  -> (cond [(zero? success)]
                                           [else #f]))
  #:c-id tox_set_user_status)

#|
 #  returns the length of status message on success.
 #  returns -1 on failure.
 #
 # int tox_get_status_message_size(Tox *tox, int32_t friendnumber);
 # int tox_get_self_status_message_size(Tox *tox);
 |#
(define-tox get-status-message-size (_fun [tox : _Tox-pointer]
                                          [friendnumber : _int32_t]
                                          -> (success : _int)
                                          -> (if (= -1 success)
                                                 #f
                                                 success))
  #:c-id tox_get_status_message_size)
(define-tox get-self-status-message-size (_fun [tox : _Tox-pointer]
                                               -> (success : _int)
                                               -> (if (= -1 success)
                                                      #f
                                                      success))
  #:c-id tox_get_self_status_message_size)

#|
 # Copy friendnumber's status message into buf, truncating if size is over maxlen.
 # Get the size you need to allocate from m_get_statusmessage_size.
 # The self variant will copy our own status message.
 #
 # returns the length of the copied data on success.
 # returns -1 on failure.
 #
 # int tox_get_status_message(Tox *tox, int32_t friendnumber, uint8_t *buf, uint32_t maxlen);
 # int tox_get_self_status_message(Tox *tox, uint8_t *buf, uint32_t maxlen);
 |#
(define-tox get-status-message (_fun [tox : _Tox-pointer]
                                     [friendnumber : _int32_t]
                                     [buf : _bytes = (make-bytes TOX_MAX_STATUSMESSAGE_LENGTH)]
                                     [maxlen : _uint32_t = (bytes-length buf)]
                                     -> (success : _int)
                                     -> (if (= -1 success)
                                            #f
                                            (subbytes buf 0 success)))
  #:c-id tox_get_status_message)
(define-tox get-self-status-message (_fun [tox : _Tox-pointer]
                                          [buf : _bytes = (make-bytes TOX_MAX_STATUSMESSAGE_LENGTH)]
                                          [maxlen : _uint32_t = (bytes-length buf)]
                                          -> (success : _int)
                                          -> (if (= -1 success)
                                                 #f
                                                 (subbytes buf 0 success)))
  #:c-id tox_get_self_status_message)

#|
 #  return one of TOX_USERSTATUS values.
 #  Values unknown to your application should be represented as TOX_USERSTATUS_NONE.
 #  As above, the self variant will return our own TOX_USERSTATUS.
 #  If friendnumber is invalid, this shall return TOX_USERSTATUS_INVALID.
 #
 # uint8_t tox_get_user_status(Tox *tox, int32_t friendnumber);
 # uint8_t tox_get_self_user_status(Tox *tox);
 |#
(define-tox get-user-status (_fun [tox : _Tox-pointer]
                                  [friendnumber : _int32_t] -> _uint8_t)
  #:c-id tox_get_user_status)
(define-tox get-self-user-status (_fun [tox : _Tox-pointer] -> _uint8_t)
  #:c-id tox_get_self_user_status)

#|
 # returns timestamp of last time friendnumber was seen online, or 0 if never seen.
 # returns -1 on error.
 #
 # uint64_t tox_get_last_online(Tox *tox, int32_t friendnumber);
 |#
(define-tox get-last-online (_fun [tox : _Tox-pointer]
                                  [friendnumber : _int32_t]
                                  -> (success : _uint64_t)
                                  -> (if (= -1 success)
                                         #f
                                         success))
  #:c-id tox_get_last_online)

#|
 # Set our typing status for a friend.
 # You are responsible for turning it on or off.
 #
 # returns 0 on success.
 # returns -1 on failure.
 #
 # int tox_set_user_is_typing(Tox *tox, int32_t friendnumber, uint8_t is_typing);
 |#
(define-tox set-user-is-typing! (_fun [tox : _Tox-pointer]
                                     [friendnumber : _int32_t]
                                     [is-typing? : _bool]
                                     -> (success : _int)
                                     -> (cond [(zero? success)]
                                              [else #f]))
  #:c-id tox_set_user_is_typing)

#|
 # Get the typing status of a friend.
 #
 # returns 0 if friend is not typing.
 # returns 1 if friend is typing.
 #
 # uint8_t tox_get_is_typing(Tox *tox, int32_t friendnumber);
 |#
(define-tox is-typing? (_fun [tox : _Tox-pointer]
                             [friendnumber : _int32_t] -> _bool)
  #:c-id tox_get_is_typing)

#|
 # Return the number of friends in the instance m.
 # You should use this to determine how much memory to allocate
 # for copy_friendlist.
 # uint32_t tox_count_friendlist(Tox *tox);
 |#
(define-tox friendlist-length (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_count_friendlist)

#|
 # Return the number of online friends in the instance m.
 # uint32_t tox_get_num_online_friends(Tox *tox);
 |#
(define-tox get-num-online-friends (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_get_num_online_friends)

#|
 # Copy a list of valid friend IDs into the array out_list.
 # If out_list is NULL, returns 0.
 # Otherwise, returns the number of elements copied.
 # If the array was too small, the contents
 # of out_list will be truncated to list_size.
 # uint32_t tox_get_friendlist(Tox *tox, int32_t *out_list, uint32_t list_size);
 |#
(define-tox get-friendlist
  (_fun (tox list-size) ::
        [tox : _Tox-pointer]
        [out-list : _bytes = (make-bytes list-size)]
        [list-size : _uint32_t]
        -> (success : _uint32_t)
        -> (if (zero? success)
               success
               (subbytes out-list 0 success)))
  #:c-id tox_get_friendlist)

#|
 # Set the function that will be executed when a friend request is received.
 # Function format is function(Tox *tox, uint8_t * public_key, uint8_t * data,
 #                             uint16_t length, void *userdata)
 #
 #
 # void tox_callback_friend_request(Tox *tox, void (*function)(Tox *tox, uint8_t *, uint8_t *,
 #                                  uint16_t, void *), void *userdata);
 |#
(define-tox callback-friend-request (_fun [tox : _Tox-pointer]
                                          [anonproc : (_fun [tox : _Tox-pointer]
                                                            [public-key : _gcpointer]
                                                            [message : _string]
                                                            [len : _uint16_t]
                                                            [userdata : _pointer] -> _void)]
                                          [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_friend_request)

#|
 # Set the function that will be executed when a message from a friend is received.
 #  Function format is: function(Tox *tox, int32_t friendnumber, uint8_t * message,
 #                               uint32_t length, void *userdata)
 #
 # void tox_callback_friend_message(Tox *tox, void (*function)(Tox *tox, int, uint8_t *,
 #                                  uint16_t, void *), void *userdata);
 |#
(define-tox callback-friend-message (_fun [tox : _Tox-pointer]
                                          [anonproc : (_fun [tox : _Tox-pointer]
                                                            [friendnumber : _int32_t]
                                                            [message : _string]
                                                            [len : _uint32_t]
                                                            [userdata : _pointer] -> _void)]
                                          [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_friend_message)

#|
 # Set the function that will be executed when an action from a friend is received.
 #  Function format is: function(Tox *tox, int32_t friendnumber, uint8_t * action,
 #                               uint32_t length, void *userdata)
 #
 # I wonder if this is done correctly...
 #
 # void tox_callback_friend_action(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *,
 #                                 uint16_t, void *), void *userdata);
 |#
(define-tox callback-friend-action (_fun [tox : _Tox-pointer]
                                         [anonproc : (_fun [tox : _Tox-pointer]
                                                           [friendnumber : _int32_t]
                                                           [action : _string]
                                                           [len : _uint32_t]
                                                           [userdata : _pointer] -> _void)]
                                         [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_friend_action)

#|
 # Set the callback for name changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t *newname, uint16_t length, void *userdata)
 #  You are not responsible for freeing newname
 #
 # Jesus Christ, this never ends.
 #
 # void tox_callback_name_change(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *,
 #                               uint16_t, void *), void *userdata);
 |#
(define-tox callback-name-change (_fun [tox : _Tox-pointer]
                                       [anonproc : (_fun [tox : _Tox-pointer]
                                                         [friendnumber : _int32_t]
                                                         [newname : _string]
                                                         [len : _uint16_t]
                                                         [userdata : _pointer] -> _void)]
                                       [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_name_change)

#|
 # Set the callback for status message changes.
 # function(Tox *tox, int32_t friendnumber, uint8_t *newstatus, uint16_t length, void *userdata)
 #  You are not responsible for freeing newstatus.
 #
 # void tox_callback_status_message(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *,
 #                                  uint16_t, void *), void *userdata);
 |#
(define-tox callback-status-message (_fun [tox : _Tox-pointer]
                                          [anonproc : (_fun [tox : _Tox-pointer]
                                                            [friendnumber : _int32_t]
                                                            [newstatus : _string]
                                                            [len : _uint16_t]
                                                            [userdata : _pointer] -> _void)]
                                          [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_status_message)

#|
 # Set the callback for status type changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t TOX_USERSTATUS, void *userdata)
 #
 # void tox_callback_user_status(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t,
 #                                                          void *), void *userdata);
 |#
(define-tox callback-user-status (_fun [tox : _Tox-pointer]
                                       [anonproc : (_fun [tox : _Tox-pointer]
                                                         [friendnumber : _int32_t]
                                                         [userstatus : _uint8_t]
                                                         [userdata : _pointer] -> _void)]
                                       [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_user_status)

#|
 # Set the callback for typing changes.
 #  function (Tox *tox, int32_t friendnumber, int is_typing, void *userdata)
 #
 # void tox_callback_typing_change(Tox *tox, void (*function)(Tox *tox, int32_t, int, void *),
 #                                                            void *userdata);
 |#
(define-tox callback-typing-change (_fun [tox : _Tox-pointer]
                                         [anonproc : (_fun [tox : _Tox-pointer]
                                                           [friendnumber : _int32_t]
                                                           [typing? : _bool]
                                                           [userdata : _pointer] -> _void)]
                                         [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_typing_change)

#|
 # Set the callback for read receipts.
 #  function(Tox *tox, int32_t friendnumber, uint32_t status, void *userdata)
 #
 #  If you are keeping a record of returns from m_sendmessage;
 #  receipt might be one of those values, meaning the message
 #  has been received on the other side.
 #  Since core doesn't track ids for you, receipt may not correspond to any message.
 #  In that case, you should discard it.
 #
 # void tox_callback_read_receipt(Tox *tox, void (*function)(Tox *tox, int32_t, uint32_t,
 #                                                           void *), void *userdata);
 |#
(define-tox callback-read-receipt (_fun [tox : _Tox-pointer]
                                        [anonproc : (_fun [tox : _Tox-pointer]
                                                          [friendnumber : _int32_t]
                                                          [status : _uint32_t]
                                                          [userdata : _pointer] -> _void)]
                                        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_read_receipt)

#|
 # Set the callback for connection status changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
 #
 #  Status:
 #    0 -- friend went offline after being previously online
 #    1 -- friend went online
 #
 #  NOTE: This callback is not called when adding friends, thus the "after
 #  being previously online" part. it's assumed that when adding friends,
 #  their connection status is offline.
 #
 # void tox_callback_connection_status(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t,
 #                                                                void *), void *userdata);
 |#
(define-tox callback-connection-status (_fun [tox : _Tox-pointer]
                                             [anonproc : (_fun [tox : _Tox-pointer]
                                                               [friendnumber : _int32_t]
                                                               [status : _uint8_t]
                                                               [userdata : _pointer] -> _void)]
                                             [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_connection_status)

#|
 # ADVANCED FUNCTIONS (If you don't know what they do you can safely ignore them.)
 |#

#|
 # Functions to get/set the nospam part of the id.
 #
 # uint32_t tox_get_nospam(Tox *tox);
 # void tox_set_nospam(Tox *tox, uint32_t nospam);
|#
(define-tox get-nospam (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_get_nospam)
(define-tox set-nospam! (_fun [tox : _Tox-pointer]
                              [nospam : _uint32_t] -> _void)
  #:c-id tox_set_nospam)

#|
 # Copy the public and secret key from the Tox object.
 # public_key and secret_key must be 32 bytes big.
 # if the pointer is NULL, no data will be copied to it.
 |#
(define-tox get-keys (_fun [tox : _Tox-pointer]
                           [public-key : _bytes]
                           [secret-key : _bytes] -> _void)
  #:c-id tox_get_keys)

#|
 ########## GROUP CHAT FUNCTIONS: WARNING Group chats will be rewritten so these might change
 |#

#|
 # Set the callback for group invites.
 #
 # Function(Tox *tox, int32_t friendnumber, uint8_t type, uint8_t *data, uint16_t length, void *userdata)
 #
 # data of length is what needs to be passed to join_groupchat().
 #
 # void tox_callback_group_invite(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t, const uint8_t *,
 #                                                           uint16_t, void *), void *userdata);
 |#
(define-tox callback-group-invite (_fun [tox : _Tox-pointer]
                                        [anonproc : (_fun [tox : _Tox-pointer]
                                                          [friendnumber : _int32_t]
                                                          [type : _uint8_t]
                                                          [data : _bytes]
                                                          [len : _uint16_t]
                                                          [userdata : _pointer] -> _void)]
                                        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_group_invite)

#|
 # Set the callback for group messages.
 #
 #  Function(Tox *tox, int groupnumber, int peernumber, uint8_t * message,
 #                                      uint16_t length, void *userdata)
 #
 # void tox_callback_group_message(Tox *tox, void (*function)(Tox *tox, int, int, uint8_t *,
 #                                 uint16_t, void *), void *userdata);
 |#
(define-tox callback-group-message (_fun [tox : _Tox-pointer]
                                         [anonproc : (_fun [tox : _Tox-pointer]
                                                           [groupnumber : _int]
                                                           [peernumber : _int]
                                                           [message : _string]
                                                           [len : _uint16_t]
                                                           [userdata : _pointer] -> _void)]
                                         [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_group_message)

#|
 # Set the callback for group actions.
 #
 #  Function(Tox *tox, int groupnumber, int peernumber, uint8_t * action,
 #                     uint16_t length, void *userdata)
 #
 # void tox_callback_group_action(Tox *tox, void (*function)(Tox *tox, int, int, uint8_t *,
 #                                uint16_t, void *), void *userdata);
 |#
(define-tox callback-group-action (_fun [tox : _Tox-pointer]
                                        [anonproc : (_fun [tox : _Tox-pointer]
                                                          [groupnumber : _int]
                                                          [peernumber : _int]
                                                          [action : _string]
                                                          [len : _uint16_t]
                                                          [userdata : _pointer] -> _void)]
                                        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_group_action)

#|
 # Set callback function for title changes.
 #
 # Function(Tox *tox, int groupnumber, int peernumber, uint8_t * title, uint8_t length, void *userdata)
 # if peernumber == -1, then author is unknown (e.g. initial joining the group)
 #
 # void tox_callback_group_title(Tox *tox, void (*function)(Tox *tox, int, int, const uint8_t *, uint8_t,
 #                                                          void *), void *userdata);
 |#
(define-tox callback-group-title
  (_fun [tox : _Tox-pointer]
        [anonproc : (_fun [tox : _Tox-pointer]
                          [groupnumber : _int]
                          [peernumber : _int]
                          [title : _bytes]
                          [len : _uint8_t]
                          [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_group_title)

#|
 # Set callback function for peer name list changes.
 #
 # It gets called every time the name list changes(new peer/name, deleted peer)
 #  Function(Tox *tox, int groupnumber, int peernumber, TOX_CHAT_CHANGE change, void *userdata)
 #
 # void tox_callback_group_namelist_change(Tox *tox, void (*function)(Tox *tox, int, int,
 #                                         uint8_t, void *), void *userdata);
 |#
(define-tox callback-group-namelist-change
  (_fun [tox : _Tox-pointer]
        [anonproc : (_fun [tox : _Tox-pointer]
                          [groupnumber : _int]
                          [peernumber : _int]
                          [change : _uint8_t]
                          [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_group_namelist_change)

#|
 # Creates a new groupchat and puts it in the chats array.
 #
 # return group number on success.
 # return -1 on failure.
 #
 # int tox_add_groupchat(Tox *tox);
 |#
(define-tox add-groupchat (_fun [tox : _Tox-pointer]
                                -> (success : _int)
                                -> (if (= -1 success)
                                       #f
                                       success))
  #:c-id tox_add_groupchat)

#|
 # Delete a groupchat from the chats array.
 #
 # return 0 on success.
 # return -1 if failure.
 #
 # int tox_del_groupchat(Tox *tox, int groupnumber);
 |#
(define-tox del-groupchat! (_fun [tox : _Tox-pointer]
                                 [groupnumber : _int]
                                 -> (success : _int)
                                 -> (cond [(zero? success)]
                                          [else #f]))
  #:c-id tox_del_groupchat)

#|
 # Copy the name of peernumber who is in groupnumber to name.
 # name must be at least TOX_MAX_NAME_LENGTH long.
 #
 # return length of name if success
 # return -1 if failure
 #
 # int tox_group_peername(Tox *tox, int groupnumber, int peernumber, uint8_t *name);
 |#
(define-tox get-group-peername (_fun [tox : _Tox-pointer]
                                     [groupnumber : _int]
                                     [peernumber : _int]
                                     [name : _bytes = (make-bytes TOX_MAX_NAME_LENGTH)]
                                     -> (success : _int)
                                     -> (if (= -1 success)
                                            #f
                                            (subbytes name 0 success)))
  #:c-id tox_group_peername)

#|
 # Copy the public key of peernumber who is in groupnumber to pk.
 # pk must be TOX_CLIENT_ID_SIZE long.
 #
 # returns 0 on success
 # returns -1 on failure
 #
 # int tox_group_peer_pubkey(const Tox *tox, int groupnumber, int peernumber, uint8_t *pk);
 |#
(define-tox get-group-peer-pubkey (_fun [tox : _Tox-pointer]
                                         [groupnumber : _int]
                                         [peernumber : _int]
                                         [pubkey : _bytes = (make-bytes TOX_CLIENT_ID_SIZE)]
                                         -> (success : _int)
                                         -> (when (zero? success)
                                              pubkey))
  #:c-id tox_group_peer_pubkey)

#|
 # invite friendnumber to groupnumber
 # return 0 on success
 # return -1 on failure
 #
 # int tox_invite_friend(Tox *tox, int32_t friendnumber, int groupnumber);
 |#
(define-tox invite-friend (_fun [tox : _Tox-pointer]
                                [friendnumber : _int32_t]
                                [groupnumber : _int]
                                -> (success : _int)
                                -> (cond [(zero? success)]
                                         [else #f]))
  #:c-id tox_invite_friend)

#|
 # Join a group (you need to have been invited first.) using data of length obtained
 # in the group invite callback.
 #
 # returns group number on success
 # returns -1 on failure.
 #
 # int tox_join_groupchat(Tox *tox, int32_t friendnumber, const uint8_t *data, uint16_t length);
 |#
(define-tox join-groupchat (_fun [tox : _Tox-pointer]
                                 [friendnumber : _int32_t]
                                 [data : _bytes]
                                 [len : _int]
                                 -> (success : _int)
                                 -> (if (= -1 success)
                                        #f
                                        success))
  #:c-id tox_join_groupchat)

#|
 # send a group message
 # return 0 on success
 # return -1 on failure
 #
 # int tox_group_message_send(Tox *tox, int groupnumber, uint8_t *message, uint32_t length);
 |#
(define-tox group-message-send (_fun [tox : _Tox-pointer]
                                     [groupnumber : _int]
                                     [message : _bytes]
                                     [len : _uint16_t = (bytes-length message)]
                                     -> (success : _int)
                                     -> (cond [(zero? success)]
                                              [else #f]))
  #:c-id tox_group_message_send)

#|
 # send a group action
 # return 0 on success
 # return -1 on failure
 #
 # int tox_group_action_send(Tox *tox, int groupnumber, uint8_t *action, uint32_t length);
 |#
(define-tox group-action-send (_fun [tox : _Tox-pointer]
                                    [groupnumber : _int]
                                    [action : _bytes]
                                    [len : _uint16_t = (bytes-length action)]
                                    -> (success : _int)
                                    -> (cond [(zero? success)]
                                             [else #f]))
  #:c-id tox_group_action_send)

#|
 # set the group's title, limited to MAX_NAME_LENGTH
 # return 0 on success
 # return -1 on failure
 #
 # int tox_group_set_title(Tox *tox, int groupnumber, const uint8_t *title, uint8_t length);
 |#
(define-tox group-set-title! (_fun [tox : _Tox-pointer]
                                  [groupnumber : _int]
                                  [title : _bytes]
                                  [len : _uint8_t = (bytes-length title)]
                                  -> (success : _int)
                                  -> (cond [(zero? success)]
                                           [else #f]))
  #:c-id tox_group_set_title)

#|
 # Get group title from groupnumber and put it in title.
 # title needs to be a valid memory location with a max_length
 # size of at least MAX_NAME_LENGTH (128) bytes.
 #
 # return length of copied title if success.
 # return -1 if failure.
 #
 # int tox_group_get_title(Tox *tox, int groupnumber, uint8_t *title, uint32_t max_length);
 |#
(define-tox group-get-title (_fun [tox : _Tox-pointer]
                                  [groupnumber : _int]
                                  [title : _bytes = (make-bytes TOX_MAX_NAME_LENGTH)]
                                  [max-len : _uint32_t = (bytes-length title)]
                                  -> (success : _int)
                                  -> (if (= -1 success)
                                         #f
                                         (subbytes title 0 success)))
  #:c-id tox_group_get_title)

#|
 # Check if the current peernumber corresponds to ours.
 #
 # return 1 if the peernumber corresponds to ours.
 # return 0 on failure.
 #
 # unsigned int tox_group_peernumber_is_ours(const Tox *tox, int groupnumber, int peernumber);
 |#
(define-tox group-peernumber-is-ours? (_fun [tox : _Tox-pointer]
                                            [groupnumber : _int]
                                            [peernumber : _int] -> _bool)
  #:c-id tox_group_peernumber_is_ours)

#|
 # Return the number of peers in the group chat on success.
 # return -1 on failure
 #
 # int tox_group_number_peers(Tox *tox, int groupnumber);
 |#
(define-tox get-group-number-peers (_fun [tox : _Tox-pointer]
                                         [groupnumber : _int]
                                         -> (success : _int)
                                         -> (if (= -1 success)
                                                #f
                                                success))
  #:c-id tox_group_number_peers)

#|
 # List all the peers in the group chat.
 #
 # Copies the names of the peers to the name[length][TOX_MAX_NAME_LENGTH] array.
 #
 # Copies the lengths of the names to lengths[length]
 #
 # returns the number of peers on success.
 #
 # return -1 on failure.
 #
 # int tox_group_get_names(Tox *tox, int groupnumber, uint8_t names[][TOX_MAX_NAME_LENGTH],
 #                         uint16_t lengths[], uint16_t length);
 |#
(define-tox get-group-names
  (_fun (tox groupnumber len) ::
        [tox : _Tox-pointer]
        [groupnumber : _int]
        [names : (_list o _bytes len)]
        [lengths : (_list o _uint16_t len)]
        [len : _uint16_t]
        -> (success : _int)
        -> (if (= -1 success)
               #f
               (list lengths names)))
  #:c-id tox_group_get_names)

#|
 # Return the number of chats in the instance m.
 #
 # You should use this to determine how much memory to allocate
 # for copy_chatlist.
 #
 # uint32_t tox_count_chatlist(Tox *tox);
 |#
(define-tox count-chatlist (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_count_chatlist)

#|
 # Copy a list of valid chat IDs into the array out_list.
 # If out_list is NULL, returns 0.
 # Otherwise, returns the number of elements copied.
 # If the array was too small, the contents of out_list will be truncated to list_size.
 #
 # uint32_t tox_get_chatlist(Tox *tox, int *out_list, uint32_t list_size);
 |#
(define-tox get-chatlist
  (_fun (tox list-size) ::
        [tox : _Tox-pointer]
        [out-list : (_list o _bytes list-size)]
        [list-size : _uint32_t]
        -> (success : _uint32_t)
        -> (if (zero? success)
               success
               out-list))
  #:c-id tox_get_chatlist)

#| ############### AVATAR FUNCTIONS ################ |#

#|
 # Set the callback function for avatar information.
 # This callback will be called when avatar information are received from friends. These events
 # can arrive at anytime, but are usually received upon connection and in reply of avatar
 # information requests.
 #
 # Function format is:
 # function(Tox *tox, int32_t friendnumber, uint8_t format, uint8_t *hash, void *userdata)
 #
 # where 'format' is the avatar image format (see TOX_AVATAR_FORMAT) and 'hash' is the hash of
 # the avatar data for caching purposes and it is exactly TOX_HASH_LENGTH long. If the
 # image format is NONE, the hash is zeroed.
 #
 # void tox_callback_avatar_info(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t, uint8_t *, void *),
 #                               void *userdata);
 |#
(define-tox callback-avatar-info
  (_fun [tox : _Tox-pointer]
        [anonproc : (_fun [tox : _Tox-pointer]
                          [friendnumber : _int]
                          [format : _int]
                          [hash : _bytes]
                          [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_avatar_info)

#|
 # Set the callback function for avatar data.
 # This callback will be called when the complete avatar data was correctly received from a
 # friend. This only happens in reply of an avatar data request (see tox_request_avatar_data);
 #
 # Function format is:
 # function(Tox *tox, int32_t friendnumber, uint8_t format, uint8_t *hash, uint8_t *data, uint32_t datalen, void *userdata)
 #
 # where 'format' is the avatar image format (see TOX_AVATARFORMAT); 'hash' is the
 # locally-calculated cryptographic hash of the avatar data and it is exactly
 # TOX_HASH_LENGTH long; 'data' is the avatar image data and 'datalen' is the length
 # of such data.
 #
 # If format is NONE, 'data' is NULL, 'datalen' is zero, and the hash is zeroed. The hash is
 # always validated locally with the function tox_avatar_hash and ensured to match the image
 # data, so this value can be safely used to compare with cached avatars.
 #
 # WARNING: users MUST treat all avatar image data received from another peer as untrusted and
 # potentially malicious. The library only ensures that the data which arrived is the same the
 # other user sent, and does not interpret or validate any image data.
 #
 # void tox_callback_avatar_data(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t, uint8_t *, uint8_t *, uint32_t,
 #                               void *), void *userdata);
 |#
(define-tox callback-avatar-data
  (_fun [tox : _Tox-pointer]
        [anonproc : (_fun [tox : _Tox-pointer]
                          [friendnumber : _int]
                          [format : _int]
                          [hash : _bytes]
                          [data : _pointer]
                          [datalen : _int]
                          [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_avatar_data)

#|
 # Set the user avatar image data.
 # This should be made before connecting, so we will not announce that the user have no avatar
 # before setting and announcing a new one, forcing the peers to re-download it.
 #
 # Notice that the library treats the image as raw data and does not interpret it by any way.
 #
 # Arguments:
 # format - Avatar image format or NONE for user with no avatar (see TOX_AVATARFORMAT);
 # data - pointer to the avatar data (may be NULL it the format is NONE);
 # length - length of image data. Must be <= TOX_MAX_AVATAR_DATA_LENGTH.
 #
 # returns 0 on success
 # returns -1 on failure.
 #
 # int tox_set_avatar(Tox *tox, uint8_t format, const uint8_t *data, uint32_t length);
 |#
(define-tox set-avatar! (_fun [tox : _Tox-pointer]
                             [format : _int]
                             [data : _bytes]
                             [len : _int = (bytes-length data)]
                             -> (success : _int)
                             -> (cond [(zero? success)]
                                      [else #f]))
  #:c-id tox_set_avatar)

#|
 # Unsets the user avatar.
 #
 # returns 0 on success (currently always returns 0)
 # int tox_unset_avatar(Tox *tox);
 |#
(define-tox unset-avatar! (_fun [tox : _Tox-pointer] -> _int)
  #:c-id tox_unset_avatar)

#|
 # Get avatar data from the current user.
 # Copies the current user avatar data to the destination buffer and sets the image format
 # accordingly.
 #
 # If the avatar format is NONE, the buffer 'buf' is left uninitialized, 'hash' is zeroed, and
 # 'length' is set to zero.
 #
 # If any of the pointers format, buf, length, and hash are NULL, that particular field will be ignored.
 #
 # Arguments:
 # format - destination pointer to the avatar image format (see TOX_AVATARFORMAT);
 # buf - destination buffer to the image data. Must have at least 'maxlen' bytes;
 # length - destination pointer to the image data length;
 # maxlen - length of the destination buffer 'buf';
 # hash - destination pointer to the avatar hash (it must be exactly TOX_HASH_LENGTH bytes long).
 #
 # returns 0 on success;
 # returns -1 on failure.
 #
 #
 # int tox_get_self_avatar(const Tox *tox, uint8_t *format, uint8_t *buf, uint32_t *length, uint32_t maxlen,
 #                         uint8_t *hash);
 |#
(define-tox get-self-avatar
  (_fun (tox format imglen) ::
        [tox : _Tox-pointer]
        [format : _int]
        [buf : _bytes = (make-bytes TOX_AVATAR_MAX_DATA_LENGTH)]
        [imglen : _int] ; _bytes
        [bufmaxlen : _int = TOX_AVATAR_MAX_DATA_LENGTH]
        [hash : _bytes = (make-bytes TOX_HASH_LENGTH)]
        -> (success : _int)
        -> (if (= -1 success)
               #f
               (list hash (subbytes buf 0 imglen))))
  #:c-id tox_get_self_avatar)

#|
 # Generates a cryptographic hash of the given data.
 # This function may be used by clients for any purpose, but is provided primarily for
 # validating cached avatars.
 # This function is a wrapper to internal message-digest functions.
 #
 # Arguments:
 # hash - destination buffer for the hash data, it must be exactly TOX_HASH_LENGTH bytes long.
 # data - data to be hashed;
 # datalen - length of the data; for avatars, should be TOX_AVATAR_MAX_DATA_LENGTH
 #
 #
 # returns 0 on success
 # returns -1 on failure.
 #
 # int tox_hash(uint8_t *hash, const uint8_t *data, const uint32_t datalen);
 |#
(define-tox tox-hash
  (_fun (data) ::
        [hash : _bytes = (make-bytes TOX_HASH_LENGTH)]
        [data : _bytes]
        [datalen : _int = (bytes-length data)]
        -> (success : _int)
        -> (cond [(zero? success) hash]
                 [else #f]))
  #:c-id tox_hash)

#|
 # Request avatar information from a friend.
 # Asks a friend to provide their avatar information (image format and hash). The friend may
 # or may not answer this request and, if answered, the information will be provided through
 # the callback 'avatar_info'.
 #
 # returns 0 on success
 # returns -1 on failure.
 #
 # int tox_request_avatar_info(const Tox *tox, const int32_t friendnumber);
 |#
(define-tox request-avatar-info (_fun [tox : _Tox-pointer] [friendnumber : _int]
                                      -> (success : _int)
                                      -> (cond [(zero? success)]
                                               [else #f]))
  #:c-id tox_request_avatar_info)

#|
 # Send an unrequested avatar information to a friend.
 # Sends our avatar format and hash to a friend; he/she can use this information to validate
 # an avatar from the cache and may (or not) reply with an avatar data request.
 #
 # Notice: it is NOT necessary to send these notification after changing the avatar or
 # connecting. The library already does this.
 #
 # returns 0 on success
 # returns -1 on failure.
 #
 # int tox_send_avatar_info(Tox *tox, const int32_t friendnumber);
 |#
(define-tox send-avatar-info (_fun [tox : _Tox-pointer] [friendnumber : _int]
                                   -> (success : _int)
                                   -> (cond [(zero? success)]
                                            [else #f]))
  #:c-id tox_send_avatar_info)

#|
 # Request the avatar data from a friend.
 # Ask a friend to send their avatar data. The friend may or may not answer this request and,
 # if answered, the information will be provided in callback 'avatar_data'.
 #
 # returns 0 on sucess
 # returns -1 on failure.
 #
 # int tox_request_avatar_data(const Tox *tox, const int32_t friendnumber);
 |#
(define-tox request-avatar-data (_fun [tox : _Tox-pointer] [friendnumber : _int]
                                      -> (success : _int)
                                      -> (cond [(zero? success)]
                                               [else #f]))
  #:c-id tox_request_avatar_data)

#|
 #################FILE SENDING FUNCTIONS#####################
 # If you wish to see the long-ass comments at this point,  #
 # check the real header file. Hell, check the actual docs. #
 # Why the fuck are you relying on this for information on  #
 # how the library operates? Or at all. Really.             #
 ############################################################
 |#

#|
 # Set the callback for file send requests.
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint64_t filesize,
 #           uint8_t *filename, uint16_t filename_length, void *userdata)
 #
 # void tox_callback_file_send_request(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t,
 #                                    uint64_t, uint8_t *, uint16_t, void *), void *userdata);
 |#
(define-tox callback-file-send-request
  (_fun [tox : _Tox-pointer]
        [anonproc : (_fun [tox : _Tox-pointer]
                          [friendnumber : _int32_t]
                          [filenumber : _uint8_t]
                          [filesize : _uint64_t]
                          [filename : _string]
                          [filename-length : _uint16_t]
                          [userdata : _pointer] -> _void)]
        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_file_send_request)

#|
 # Set the callback for file control requests.
 #
 #  receive_send is 1 if the message is for a slot on which we are currently sending a file
 #  and 0 if the message is for a slot on which we are receiving the file
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t receive_send, uint8_t filenumber,
 #           uint8_t control_type, uint8_t *data, uint16_t length, void *userdata)
 #
 #
 # void tox_callback_file_control(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t,
 #                                uint8_t, uint8_t, uint8_t *, uint16_t, void *),
 #                                void *userdata);
 |#
(define-tox callback-file-control (_fun [tox : _Tox-pointer]
                                        [anonproc : (_fun [tox : _Tox-pointer]
                                                          [friendnumber : _int32_t]
                                                          [sending? : _bool]
                                                          [filenumber : _uint8_t]
                                                          [control-type : _uint8_t]
                                                          [data : _pointer]
                                                          [len : _uint16_t]
                                                          [userdata : _pointer] -> _void)]
                                        [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_file_control)

#|
 # Set the callback for file data.
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint8_t *data,
 #           uint16_t length, void *userdata)
 #
 #
 # void tox_callback_file_data(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t,
 #                             uint8_t *, uint16_t length, void *), void *userdata);
 |#
(define-tox callback-file-data (_fun [tox : _Tox-pointer]
                                     [anonproc : (_fun [tox : _Tox-pointer]
                                                       [friendnumber : _int32_t]
                                                       [filenumber : _uint8_t]
                                                       [data : _pointer]
                                                       [len : _uint16_t]
                                                       [userdata : _pointer] -> _void)]
                                     [userdata : _pointer = #f] -> _void)
  #:c-id tox_callback_file_data)

#|
 # Send a file send request.
 # Maximum filename length is 255 bytes.
 #  return file number on success
 #  return -1 on failure
 #
 # int tox_new_file_sender(Tox *tox, int32_t friendnumber, uint64_t filesize,
 #                         uint8_t *filename, uint16_t filename_length);
 |#
(define-tox new-file-sender (_fun [tox : _Tox-pointer]
                                  [friendnumber : _int32_t]
                                  [filesize : _uint64_t]
                                  [filename : _string]
                                  [filename-length : _uint16_t = (bytes-length
                                                                  (string->bytes/utf-8
                                                                   filename))]
                                  -> (success : _int)
                                  -> (if (= -1 success)
                                         #f
                                         success))
  #:c-id tox_new_file_sender)

#|
 # Send a file control request.
 #
 # send_receive is 0 if we want the control packet to target a file we are currently sending,
 # 1 if it targets a file we are currently receiving.
 #
 #  return 0 on success
 #  return -1 on failure
 #
 # int tox_file_send_control(Tox *tox, int32_t friendnumber, uint8_t send_receive,
 #                           uint8_t filenumber, uint8_t message_id,
 #                           uint8_t *data, uint16_t length);
 |#
(define-tox send-file-control (_fun [tox : _Tox-pointer]
                                    [friendnumber : _int32_t]
                                    [receiving? : _bool]
                                    [filenumber : _uint8_t]
                                    [message-id : _uint8_t]
                                    [data : _bytes]
                                    [len : _uint16_t]
                                    -> (success : _int)
                                    -> (cond [(zero? success)]
                                             [else #f]))
  #:c-id tox_file_send_control)

#|
 # Send file data.
 #
 #  return 0 on success
 #  return -1 on failure
 #
 # int tox_file_send_data(Tox *tox, int32_t friendnumber, uint8_t filenumber,
 #                        uint8_t *data, uint16_t length);
 |#
(define-tox send-file-data (_fun [tox : _Tox-pointer]
                                 [friendnumber : _int32_t]
                                 [filenumber : _uint8_t]
                                 [data : _bytes]
                                 [len : _uint16_t = (bytes-length data)]
                                 -> (success : _int)
                                 -> (cond [(zero? success)]
                                          [else #f]))
  #:c-id tox_file_send_data)

#|
 # Returns the recommended/maximum size of the filedata you send with tox_file_send_data()
 #
 #  return size on success
 #  return -1 on failure (currently will never return -1)
 #
 # int tox_file_data_size(Tox *tox, int32_t friendnumber);
 |#
(define-tox file-data-size (_fun [tox : _Tox-pointer]
                                 [friendnumber : _int32_t]
                                 -> (success : _int)
                                 -> (if (= -1 success)
                                        #f
                                        success))
  #:c-id tox_file_data_size)

#|
 # Give the number of bytes left to be sent/received.
 #
 #  send_receive is 0 if we want the sending files, 1 if we want the receiving.
 #
 #  return number of bytes remaining to be sent/received on success
 #  return 0 on failure
 #
 # uint64_t tox_file_data_remaining(Tox *tox, int32_t friendnumber, uint8_t filenumber,
 #                                  uint8_t send_receive);
 |#
(define-tox file-data-remaining (_fun [tox : _Tox-pointer]
                                      [friendnumber : _int32_t]
                                      [filenumber : _uint8_t]
                                      [receiving? : _bool]
                                      -> (remaining : _uint64_t)
                                      -> (if (= -1 remaining)
                                             #f
                                             remaining))
  #:c-id tox_file_data_remaining)

#| ##############END OF FILE SENDING FUNCTIONS################## |#


#|
 # Use this function to bootstrap the client.
 |#

#|
 # Resolves address into an IP address. If successful, sends a "get nodes"
 #   request to the given node with ip, port (in host byte order)
 #   and public_key to setup connections
 #
 # address can be a hostname or an IP address (IPv4 or IPv6).
 #
 #  returns 1 if the address could be converted into an IP address
 #  returns 0 otherwise
 #
 # int tox_bootstrap_from_address(Tox *tox, const char *address, uint16_t port,
 #                                const uint8_t *public_key);
 |#
(define-tox bootstrap-from-address (_fun [tox : _Tox-pointer]
                                         [address : _string]
                                         [port : _uint16_t]
                                         [public-key : _string] -> _bool)
  #:c-id tox_bootstrap_from_address)

#|
 #  return 0 if we are not connected to the DHT.
 #  return 1 if we are.
 #
 # int tox_isconnected(Tox *tox);
 |#
(define-tox tox-connected? (_fun [tox : _Tox-pointer] -> _bool)
  #:c-id tox_isconnected)

#|
 # Run this function at startup.
 #
 # Options are some options that can be passed to the Tox instance (see above struct).
 #
 # If options is NULL, tox_new() will use default settings.
 #
 # Initializes a tox structure
 # return allocated instance of tox on success.
 # return NULL on failure.
 # Tox *tox_new(Tox_Options *options);
 |#
(define-tox tox-new (_fun [options : _pointer] -> _Tox-pointer)
  #:c-id tox_new)

#|
 # Run this before closing shop.
 # Free all datastructures.
 # void tox_kill(Tox *tox);
 |#
(define-tox tox-kill! (_fun [tox : _Tox-pointer] -> _void)
  #:c-id tox_kill)

#|
 # Return the time in milliseconds before tox_do() should be called again
 # for optimal performance.
 #
 # returns time (in ms) before the next tox_do() needs to be run on success.
 #
 # uint32_t tox_do_interval(Tox *tox);
|#
(define-tox tox-do-interval (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_do_interval)

#|
 # The main loop that needs to be run in intervals of tox_do_interval() ms.
 # void tox_do(Tox *tox);
 |#
(define-tox tox-do (_fun [tox : _Tox-pointer] -> _void)
  #:c-id tox_do)

#| SAVING AND LOADING FUNCTIONS: |#

#|
 #  return size of messenger data (for saving).
 # uint32_t tox_size(Tox *tox);
 |#
(define-tox tox-size (_fun [tox : _Tox-pointer] -> _uint32_t)
  #:c-id tox_size)

#|
 # Save the messenger in data (must be allocated memory of size Messenger_size()).
 # void tox_save(Tox *tox, uint8_t *data);
 |#
(define-tox tox-save
  (_fun (tox) ::
        [tox : _Tox-pointer]
        [data : _bytes = (make-bytes (tox-size tox))]
        -> _void
        -> data)
  #:c-id tox_save)

#|
 # Load the messenger from data of size length.
 #
 #  returns 0 on success
 #  returns -1 on failure
 #
 # int tox_load(Tox *tox, uint8_t *data, uint32_t length);
 |#
(define-tox tox-load (_fun [tox : _Tox-pointer]
                           [data : _bytes]
                           [len : _uint32_t = (bytes-length data)]
                           -> (success : _int)
                           -> (cond [(zero? success)]
                                    [else #f]))
  #:c-id tox_load)
)
