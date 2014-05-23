#lang racket
; libtoxcore-racket/functions.rkt
; FFI implementation of libtoxcore
(require ffi/unsafe
         ffi/unsafe/define
         "enums.rkt")
(provide (all-from-out "enums.rkt")
         (all-defined-out))

(define-ffi-definer define-tox (ffi-lib "libtoxcore"))

#|
 # this code is verbose, messy, and probably doesn't work at all.
 # DEAL WITH IT
 #
 # TODO:
 #     (provide) all the API functions
 #     testing!
 #     make certain the tox_callback functions work
 #     tox_group_get_names takes two arrays - works as-written?
 |#

#|###################
 # type definitions #
 ################## |#

; *_t definitions
(define _sa_family_t _ushort)
(define _mmask_t _ulong)
(define _size_t _uint)
(define _int32_t _int32)
(define _uint8_t _uint8)
(define _uint16_t _uint16)
(define _uint32_t _uint32)
(define _uint64_t _uint64)

; pointer definitions
(define _int32_t-pointer (_cpointer 'int32_t))
(define _uint8_t-pointer (_cpointer 'uint8_t))
(define _uint16_t-pointer (_cpointer 'uint16_t))
(define _uint32_t-pointer (_cpointer 'uint32_t))
(define _voidptr (_cpointer 'void))
; The _string type supports conversion between Racket strings
; and char* strings using a parameter-determined conversion.
; instead of using _bytes, which is unnatural, use _string
; of specified type _string*/utf-8.
(default-_string-type _string*/utf-8)
(define _char-pointer _string)

; define Tox struct
;(define-cstruct _Tox ([Tox (_cpointer 'Tox)]))
(define _Tox-pointer (_cpointer 'Tox))


#|##########################
 # structs, constants, etc #
 ######################### |#
; are these constants even necessary for the wrapper?


(define TOX_MAX_NAME_LENGTH 128)
(define TOX_MAX_STATUSMESSAGE_LENGTH 1007)
(define TOX_CLIENT_ID_SIZE 32)

(define TOX_FRIEND_ADDRESS_SIZE (+ TOX_CLIENT_ID_SIZE
                                   (ctype-sizeof _uint32_t) (ctype-sizeof _uint16_t)))

(define TOX_PORTRANGE_FROM 33445)
(define TOX_PORTRANGE_TO 33545)
(define TOX_PORT_DEFAULT TOX_PORTRANGE_FROM)

; UNIONS ARE ALWAYS TREATED LIKE STRUCTS
; http://docs.racket-lang.org/foreign/C_Union_Types.html

#|
####################################
# THESE ARE DEPRECATED, DO NOT USE #
####################################
|#

; pulled in from netinet/in.h
#| IPv6 address |#
(define-cstruct _in6_addr ([__in6_addr8 (_array _int 16)]
                           [__in6_addr16 (_array _int 8)]
                           [__in6_addr32 (_array _int 4)]))

(define-cstruct _tox_IP4 ([c (_array _uint8_t 4)]
                          [s (_array _uint16_t 2)]
                          [i _uint32_t]))

(define-cstruct _tox_IP6 ([uint8 (_array _uint8_t 16)]
                          [uint16 (_array _uint16_t 8)]
                          [uint32 (_array _uint32_t 4)]
                          [in6_addr (make-cstruct-type (list _in6_addr) 'default #f)]))

; anonymous unions/structs is the butts. the WHOLE butts
(define-cstruct _tox_IP ([family _sa_family_t]
                         [_tox_IP4 (make-cstruct-type (list _tox_IP4))]
                         [_tox_IP6 (make-cstruct-type (list _tox_IP4))]))

#| will replace IP_Port as soon as the complete infrastructure is in place
 # removed the unused union and padding also |#
(define-cstruct _tox_IP_PORT ([ip _tox_IP] [port _uint16_t]))
#|THE ABOVE ARE DEPRECATED, DO NOT USE|#

(define TOX_ENABLE_IPV6_DEFAULT 1)

#|

enum definitions have moved to enums.rkt which uses r6rs

; enum definitions
; Errors for m_addfriend
; FAERR - Friend Add Error
(define TOX_FAERR (_enum '(TOX_FAERR_TOOLONG = -1
                                             TOX_FAERR_NOMESSAGE = -2
                                             TOX_FAERR_OWNKEY = -3
                                             TOX_FAERR_ALREADYSENT = -4
                                             TOX_FAERR_UNKNOWN = -5
                                             TOX_FAERR_BADCHECKSUM = -6
                                             TOX_FAERR_SETNEWNOSPAM = -7
                                             TOX_FAERR_NOMEM = -8)))

; USERSTATUS -
; Represents userstatuses someone can have.
(define TOX_USERSTATUS (_enum '(TOX_USERSTATUS_NONE TOX_USERSTATS_AWAY TOX_USERSTATUS_BUSY
                                                    TOX_USERSTATUS_BUSY)))
(define TOX_CHAT_CHANGE (_enum '(TOX_CHAT_CHANGE_PEER_ADD TOX_CHAT_CHANGE_PEER_DEL
                                                          TOX_CHAT_CHANGE_PEER_NAME)))
; improvised from line 521-ish of tox.h
(define TOX_FILECONTROL (_enum
                         '(TOX_FILECONTROL_ACCEPT TOX_FILECONTROL_PAUSE
                                                  TOXFILECONTROL_KILL TOXFILECONTROL_FINISHED
                                                  TOX_FILECONTROL_RESUME_BROKEN)))|#


#|#######################
 # function definitions #
 ###################### |#

#| NOTE: Strings in Tox are all UTF-8, (This means that there is no terminating NULL character.)
 #
 # The exact buffer you send will be received at the other end without modification.
 #
 # Do not treat Tox strings as C strings.
 |#

#| return TOX_FRIEND_ADDRESS_SIZE byte address to give to others.
 # format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
 #
 # void tox_get_address(Tox *tox, uint8_t *address);
 |#
(define-tox tox_get_address (_fun _Tox-pointer _pointer -> _void))

#| Add a friend.
 # Set the data that will be sent along with friend request.
 # address is the address of the friend (returned by getaddress of the friend you wish to add) it must be TOX_FRIEND_ADDRESS_SIZE bytes. TODO: add checksum.
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
(define-tox tox_add_friend (_fun _Tox-pointer _string _string _uint16_t -> _int32_t))

#| Add a friend without sending a friendrequest.
 #  return the friend number if success.
 #  return -1 if failure.
 #
 # int32_t tox_add_friend_norequest(Tox *tox, uint8_t *client_id);
 |#
(define-tox tox_add_friend_norequest (_fun _Tox-pointer _string -> _int32_t))

#|
 #  return the friend number associated to that client id.
 #  return -1 if no such friend */
 # int32_t tox_get_friend_number(Tox *tox, uint8_t *client_id);
|#
(define-tox tox_get_friend_number (_fun _Tox-pointer _string -> _int32_t))

#|
 # Copies the public key associated to that friend id into client_id buffer.
 # Make sure that client_id is of size CLIENT_ID_SIZE.
 #  return 0 if success.
 #  return -1 if failure.
 #
 # int tox_get_client_id(Tox *tox, int32_t friend_id, uint8_t *client_id);
 |#
(define-tox tox_get_client_id (_fun _Tox-pointer _int32_t _string -> _int))

#| Remove a friend.
 # 
 # return 0 if success.
 # return -1 if failure.
 #
 # int tox_del_friend(Tox *tox, int32_t friendnumber);
 |#
(define-tox tox_del_friend (_fun _Tox-pointer _int32_t -> _int))

#| Checks friend's connecting status.
 #
 #  return 1 if friend is connected to us (Online).
 #  return 0 if friend is not connected to us (Offline).
 #  return -1 on failure.
 #
 # int tox_get_friend_connection_status(Tox *tox, int friendnumber);
 |#
(define-tox tox_get_friend_connection_status (_fun _Tox-pointer _int32_t -> _int))

#| Checks if there exists a friend with given friendnumber.
 #
 #  return 1 if friend exists.
 #  return 0 if friend doesn't exist.
 #
 # int tox_friend_exists(Tox *tox, int32_t friendnumber);
 |#
(define-tox tox_friend_exists (_fun _Tox-pointer _int32_t -> _int))

#| Send a text chat message to an online friend.
 #
 #  return the message id if packet was successfully put into the send queue.
 #  return 0 if it was not.
 #
 # You will want to retain the return value, it will be passed to your read_receipt callback
 # if one is received.
 # m_sendmessage_withid will send a message with the id of your choosing,
 # however we can generate an id for you by calling plain m_sendmessage.
 #
 # uint32_t tox_send_message(Tox *tox, int32_t friendnumber, uint8_t *message, uint32_t length);
 # uint32_t tox_send_message_withid(Tox *tox, int32_t friendnumber, uint32_t theid, uint8_t *message, uint32_t length);
 |#
(define-tox tox_send_message (_fun _Tox-pointer _int32_t _string _uint32_t -> _uint32_t))
(define-tox tox_send_message_withid (_fun _Tox-pointer _int32_t _uint32_t _string _uint32_t -> _uint32_t))

#| Send an action to an online friend.
 #
 #  return the message id if packet was successfully put into the send queue.
 #  return 0 if it was not.
 #
 #  You will want to retain the return value, it will be passed to your read_receipt callback
 #  if one is received.
 #  m_sendaction_withid will send an action message with the id of your choosing,
 #  however we can generate an id for you by calling plain m_sendaction.
 #
 # uint32_t tox_send_action(Tox *tox, int32_t friendnumber, uint8_t *action, uint32_t length);
 # uint32_t tox_send_action_withid(Tox *tox, int32_t friendnumber, uint32_t theid, uint8_t *action, uint32_t length);
 |#
(define-tox tox_send_action (_fun _Tox-pointer _int32_t _string _uint32_t -> _uint32_t))
(define-tox tox_send_action_withid (_fun _Tox-pointer _int32_t _uint32_t _string _uint32_t -> _uint32_t))

#| Set our nickname.
 # name must be a string of maximum MAX_NAME_LENGTH length.
 # length must be at least 1 byte.
 # length is the length of name with the NULL terminator.
 #
 #  return 0 if success.
 #  return -1 if failure.
 #
 # int tox_set_name(Tox *tox, uint8_t *name, uint16_t length);
 |#
(define-tox tox_set_name (_fun _Tox-pointer _string _uint16_t -> _int))

#|
 # Get your nickname.
 # m - The messanger context to use.
 # name - needs to be a valid memory location with a size of
 # at least MAX_NAME_LENGTH (128) bytes.
 #
 #  return length of name.
 #  return 0 on error.
 #
 # uint16_t tox_get_self_name(Tox *tox, uint8_t *name);
 |#
(define-tox tox_get_self_name (_fun _Tox-pointer _string -> _uint16_t))

#| Get name of friendnumber and put it in name.
 # name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
 #
 #  return length of name if success.
 #  return -1 if failure.
 #
 # int tox_get_name(Tox *tox, int32_t friendnumber, uint8_t *name);
 |#
(define-tox tox_get_name (_fun _Tox-pointer _int32_t _pointer -> _int))

#|  returns the length of name on success.
 #  returns -1 on failure.
 #
 # int tox_get_name_size(Tox *tox, int32_t friendnumber);
 # int tox_get_self_name_size(Tox *tox);
 |#
(define-tox tox_get_name_size (_fun _Tox-pointer _int32_t -> _int))
(define-tox tox_get_self_name_size (_fun _Tox-pointer -> _int))

#| Set our user status.
 #
 # userstatus must be one of TOX_USERSTATUS values.
 #
 #  returns 0 on success.
 #  returns -1 on failure.
 #
 # int tox_set_status_message(Tox *tox, uint8_t *status, uint16_t length);
 # int tox_set_user_status(Tox *tox, uint8_t userstatus);
 |#
(define-tox tox_set_status_message (_fun _Tox-pointer _string _uint16_t -> _int))
(define-tox tox_set_user_status (_fun _Tox-pointer _uint8_t -> _int))

#|  returns the length of status message on success.
 #  returns -1 on failure.
 #
 # int tox_get_status_message_size(Tox *tox, int32_t friendnumber);
 # int tox_get_self_status_message_size(Tox *tox);
 |#
(define-tox tox_get_status_message_size (_fun _Tox-pointer _int32_t -> _int))
(define-tox tox_get_self_status_message_size (_fun _Tox-pointer -> _int))

#| Copy friendnumber's status message into buf, truncating if size is over maxlen.
 # Get the size you need to allocate from m_get_statusmessage_size.
 # The self variant will copy our own status message.
 #
 # returns the length of the copied data on success.
 # returns -1 on failure.
 #
 # int tox_get_status_message(Tox *tox, int32_t friendnumber, uint8_t *buf, uint32_t maxlen);
 # int tox_get_self_status_message(Tox *tox, uint8_t *buf, uint32_t maxlen);
 |#
(define-tox tox_get_status_message (_fun _Tox-pointer _int32_t _string _uint32_t -> _int))
(define-tox tox_get_self_status_message (_fun _Tox-pointer _string _uint32_t -> _int))

#|  return one of TOX_USERSTATUS values.
 #  Values unknown to your application should be represented as TOX_USERSTATUS_NONE.
 #  As above, the self variant will return our own TOX_USERSTATUS.
 #  If friendnumber is invalid, this shall return TOX_USERSTATUS_INVALID.
 #
 # uint8_t tox_get_user_status(Tox *tox, int32_t friendnumber);
 # uint8_t tox_get_self_user_status(Tox *tox);
 |#
(define-tox tox_get_user_status (_fun _Tox-pointer _int32_t -> _uint8_t))
(define-tox tox_get_self_user_status (_fun _Tox-pointer -> _uint8_t))

#| returns timestamp of last time friendnumber was seen online, or 0 if never seen.
 # returns -1 on error.
 #
 # uint64_t tox_get_last_online(Tox *tox, int32_t friendnumber);
 |#
(define-tox tox_get_last_online (_fun _Tox-pointer _int32_t -> _uint64_t))

#| Set our typing status for a friend.
 # You are responsible for turning it on or off.
 #
 # returns 0 on success.
 # returns -1 on failure.
 #
 # int tox_set_user_is_typing(Tox *tox, int32_t friendnumber, uint8_t is_typing);
 |#
(define-tox tox_set_user_is_typing (_fun _Tox-pointer _int32_t _uint8_t -> _int))

#| Get the typing status of a friend.
 #
 # returns 0 if friend is not typing.
 # returns 1 if friend is typing.
 #
 # uint8_t tox_get_is_typing(Tox *tox, int32_t friendnumber);
 |#
(define-tox tox_get_is_typing (_fun _Tox-pointer _int32_t -> _uint8_t))

#| Sets whether we send read receipts for friendnumber.
 # This function is not lazy, and it will fail if yesno is not (0 or 1).
 #
 # void tox_set_sends_receipts(Tox *tox, int32_t friendnumber, int yesno);
 |#
(define-tox tox_set_sends_receipts (_fun _Tox-pointer _int32_t _int -> _void))

#| Return the number of friends in the instance m.
 # You should use this to determine how much memory to allocate
 # for copy_friendlist.
 # uint32_t tox_count_friendlist(Tox *tox);
 |#
(define-tox tox_count_friendlist (_fun _Tox-pointer -> _uint32_t))

#| Return the number of online friends in the instance m.
 # uint32_t tox_get_num_online_friends(Tox *tox);
 |#
(define-tox tox_get_num_online_friends (_fun _Tox-pointer -> _uint32_t))

#| Copy a list of valid friend IDs into the array out_list.
 # If out_list is NULL, returns 0.
 # Otherwise, returns the number of elements copied.
 # If the array was too small, the contents
 # of out_list will be truncated to list_size.
 # uint32_t tox_get_friendlist(Tox *tox, int32_t *out_list, uint32_t list_size);
 |#
(define-tox tox_get_friendlist (_fun _Tox-pointer _int32_t-pointer _uint32_t -> _uint32_t))

#| Set the function that will be executed when a friend request is received.
 #  Function format is function(Tox *tox, uint8_t * public_key, uint8_t * data, uint16_t length, void *userdata)
 #
 #
 # I wonder if this is done correctly...
 #
 # void tox_callback_friend_request(Tox *tox, void (*function)(Tox *tox, uint8_t *, uint8_t *, uint16_t, void *),
 #                                 void *userdata);
 |#
(define-tox tox_callback_friend_request (_fun _Tox-pointer
                                              (_fun _Tox-pointer _string _string
                                                    _uint16_t _voidptr -> _voidptr)
                                              _voidptr -> _void))

#| Set the function that will be executed when a message from a friend is received.
 #  Function format is: function(Tox *tox, int friendnumber, uint8_t * message, uint32_t length, void *userdata)
 #
 # I wonder if this is done correctly...
 #
 # void tox_callback_friend_message(Tox *tox, void (*function)(Tox *tox, int, uint8_t *, uint16_t, void *),
 #                                  void *userdata);
 |#
(define-tox tox_callback_friend_message (_fun _Tox-pointer
                                              (_fun _Tox-pointer _int _string _uint16_t
                                                    _voidptr -> _void)
                                              _voidptr -> _void))

#| Set the function that will be executed when an action from a friend is received.
 #  Function format is: function(Tox *tox, int32_t friendnumber, uint8_t * action, uint32_t length, void *userdata)
 #
 # I wonder if this is done correctly...
 #
 # void tox_callback_friend_action(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *, uint16_t, void *),
 #                                void *userdata);
 |#
(define-tox tox_callback_friend_action (_fun _Tox-pointer
                                             (_fun _Tox-pointer _int32_t _string _uint16_t _voidptr -> _void)
                                             _voidptr -> _void))

#| Set the callback for name changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t *newname, uint16_t length, void *userdata)
 #  You are not responsible for freeing newname
 #
 # Jesus Christ, this never ends.
 #
 # void tox_callback_name_change(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *, uint16_t, void *),
 #                               void *userdata);
 |#
(define-tox tox_callback_name_change (_fun _Tox-pointer
                                           (_fun _Tox-pointer _int32_t _string _uint16_t _voidptr -> _void)
                                           _voidptr -> _void))

#| Set the callback for status message changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t *newstatus, uint16_t length, void *userdata)
 #  You are not responsible for freeing newstatus.
 #
 # void tox_callback_status_message(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *, uint16_t, void *),
 #                                  void *userdata);
 |#
(define-tox tox_callback_status_message (_fun _Tox-pointer
                                              (_fun _Tox-pointer _int32_t _string _uint16_t _voidptr -> _void)
                                              _voidptr -> _void))

#| Set the callback for status type changes.
 #  function(Tox *tox, int32_t friendnumber, uint8_t TOX_USERSTATUS, void *userdata)
 #
 # void tox_callback_user_status(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t, void *), void *userdata);
 |#
(define-tox tox_callback_user_status (_fun _Tox-pointer
                                           (_fun _Tox-pointer _int32_t _uint8_t _voidptr -> _void)
                                           _voidptr -> _void))

#| Set the callback for typing changes.
 #  function (Tox *tox, int32_t friendnumber, int is_typing, void *userdata)
 #
 # void tox_callback_typing_change(Tox *tox, void (*function)(Tox *tox, int32_t, int, void *), void *userdata);
 |#
(define-tox tox_callback_typing_change (_fun _Tox-pointer
                                             (_fun _Tox-pointer _int32_t _int _voidptr -> _void)
                                             _voidptr -> _void))

#| Set the callback for read receipts.
 #  function(Tox *tox, int32_t friendnumber, uint32_t status, void *userdata)
 #
 #  If you are keeping a record of returns from m_sendmessage;
 #  receipt might be one of those values, meaning the message
 #  has been received on the other side.
 #  Since core doesn't track ids for you, receipt may not correspond to any message.
 #  In that case, you should discard it.
 #
 # void tox_callback_read_receipt(Tox *tox, void (*function)(Tox *tox, int32_t, uint32_t, void *), void *userdata);
 |#
(define-tox tox_callback_read_receipt (_fun _Tox-pointer
                                            (_fun _Tox-pointer _int32_t _uint32_t _voidptr -> _void)
                                            _voidptr -> _void))

#| Set the callback for connection status changes.
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
 # void tox_callback_connection_status(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t, void *), void *userdata);
 |#
(define-tox tox_callback_connection_status (_fun _Tox-pointer
                                                 (_fun _Tox-pointer _int32_t _uint8_t _voidptr -> _void)
                                                 _voidptr -> _void))

#| ##########ADVANCED FUNCTIONS (If you don't know what they do you can safely ignore them.) ############ |#
#| Functions to get/set the nospam part of the id.
 #
 # uint32_t tox_get_nospam(Tox *tox);
 # void tox_set_nospam(Tox *tox, uint32_t nospam);
|#
(define-tox tox_get_nospam (_fun _Tox-pointer -> _uint32_t))
(define-tox tox_set_nospam (_fun _Tox-pointer  _uint32_t -> _void))

#| ##########GROUP CHAT FUNCTIONS: WARNING Group chats will be rewritten so this might change ########### |#

#| Set the callback for group invites.
 #
 #  Function(Tox *tox, int friendnumber, uint8_t *group_public_key, void *userdata)
 #
 # void tox_callback_group_invite(Tox *tox, void (*function)(Tox *tox, int32_t, uint8_t *, void *), void *userdata);
 |#
(define-tox tox_callback_group_invite (_fun _Tox-pointer
                                            (_fun _Tox-pointer _int32_t _string _voidptr -> _void)
                                            _voidptr -> _void))

#| Set the callback for group messages.
 #
 #  Function(Tox *tox, int groupnumber, int friendgroupnumber, uint8_t * message, uint16_t length, void *userdata)
 #
 # void tox_callback_group_message(Tox *tox, void (*function)(Tox *tox, int, int, uint8_t *, uint16_t, void *),
 #                                void *userdata);
 |#
(define-tox tox_callback_group_message (_fun _Tox-pointer
                                             (_fun _Tox-pointer _int _int _string _uint16_t _voidptr -> _void)
                                             _voidptr -> _void))

#| Set the callback for group actions.
 #
 #  Function(Tox *tox, int groupnumber, int friendgroupnumber, uint8_t * action, uint16_t length, void *userdata)
 #
 # void tox_callback_group_action(Tox *tox, void (*function)(Tox *tox, int, int, uint8_t *, uint16_t, void *),
 #                               void *userdata);
 |#
(define-tox tox_callback_group_action (_fun _Tox-pointer
                                            (_fun _Tox-pointer _int _int _string _uint16_t _voidptr -> _void)
                                            _voidptr -> _void))

#| Set callback function for peer name list changes.
 #
 # It gets called every time the name list changes(new peer/name, deleted peer)
 #  Function(Tox *tox, int groupnumber, int peernumber, TOX_CHAT_CHANGE change, void *userdata)
 #
 # void tox_callback_group_namelist_change(Tox *tox, void (*function)(Tox *tox, int, int, uint8_t, void *),
 #                                        void *userdata);
 |#
(define-tox tox_callback_group_namelist_change (_fun _Tox-pointer
                                                     (_fun _Tox-pointer _int _int _uint8_t _voidptr -> _void)
                                                     _voidptr -> _void))

#| Creates a new groupchat and puts it in the chats array.
 #
 # return group number on success.
 # return -1 on failure.
 #
 # int tox_add_groupchat(Tox *tox);
 |#
(define-tox tox_add_groupchat (_fun _Tox-pointer -> _int))

#| Delete a groupchat from the chats array.
 #
 # return 0 on success.
 # return -1 if failure.
 #
 # int tox_del_groupchat(Tox *tox, int groupnumber);
 |#
(define-tox tox_del_groupchat (_fun _Tox-pointer _int -> _int))

#| Copy the name of peernumber who is in groupnumber to name.
 # name must be at least TOX_MAX_NAME_LENGTH long.
 #
 # return length of name if success
 # return -1 if failure
 #
 # int tox_group_peername(Tox *tox, int groupnumber, int peernumber, uint8_t *name);
 |#
(define-tox tox_group_peername (_fun _Tox-pointer _int _int _string -> _int))

#| invite friendnumber to groupnumber
 # return 0 on success
 # return -1 on failure
 #
 # int tox_invite_friend(Tox *tox, int32_t friendnumber, int groupnumber);
 |#
(define-tox tox_invite_friend (_fun _Tox-pointer _int32_t _int -> _int))

#| Join a group (you need to have been invited first.)
 #
 # returns group number on success
 # returns -1 on failure.
 #
 # int tox_join_groupchat(Tox *tox, int32_t friendnumber, uint8_t *friend_group_public_key);
 |#
(define-tox tox_join_groupchat (_fun _Tox-pointer _int32_t _string -> _int))

#| send a group message
 # return 0 on success
 # return -1 on failure
 #
 # int tox_group_message_send(Tox *tox, int groupnumber, uint8_t *message, uint32_t length);
 |#
(define-tox tox_group_message_send (_fun _Tox-pointer _int _string _uint32_t -> _int))

#| send a group action
 # return 0 on success
 # return -1 on failure
 #
 # int tox_group_action_send(Tox *tox, int groupnumber, uint8_t *action, uint32_t length);
 |#
(define-tox tox_group_action_send (_fun _Tox-pointer _int _string _uint32_t -> _int))

#| Return the number of peers in the group chat on success.
 # return -1 on failure
 #
 # int tox_group_number_peers(Tox *tox, int groupnumber);
 |#
(define-tox tox_group_number_peers (_fun _Tox-pointer _int -> _int))

#| List all the peers in the group chat.
 #
 # Copies the names of the peers to the name[length][TOX_MAX_NAME_LENGTH] array.
 #
 # Copies the lengths of the names to lengths[length]
 #
 # returns the number of peers on success.
 #
 # return -1 on failure.
 #
 # int tox_group_get_names(Tox *tox, int groupnumber, uint8_t names[][TOX_MAX_NAME_LENGTH], uint16_t lengths[],
 #                         uint16_t length);
 |#
(define-tox tox_group_get_names (_fun _Tox-pointer _int _pointer _pointer _uint16_t -> _int))

#| Return the number of chats in the instance m.
 # You should use this to determine how much memory to allocate
 # for copy_chatlist.
 # uint32_t tox_count_chatlist(Tox *tox);
 |#
(define-tox tox_count_chatlist (_fun _Tox-pointer -> _uint32_t))

#| Copy a list of valid chat IDs into the array out_list.
 # If out_list is NULL, returns 0.
 # Otherwise, returns the number of elements copied.
 # If the array was too small, the contents
 # of out_list will be truncated to list_size.
 # uint32_t tox_get_chatlist(Tox *tox, int *out_list, uint32_t list_size);
 |#
(define-tox tox_get_chatlist (_fun _Tox-pointer _intptr _uint32_t -> _uint32_t))

#|
 #################FILE SENDING FUNCTIONS#####################
 # If you wish to see the long-ass comments at this point,  #
 # check the real header file. Hell, check the actual docs. #
 # Why the fuck are you relying on this for information on  #
 # how the library operates? Or at all. Really.             #
 ############################################################
 |#

#| Set the callback for file send requests.
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint64_t filesize, uint8_t *filename, uint16_t filename_length, void *userdata)
 #
 # void tox_callback_file_send_request(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t, uint64_t, uint8_t *, uint16_t,
 #                                    void *), void *userdata);
 |#
(define-tox tox_callback_file_send_request (_fun _Tox-pointer
                                                 (_fun _Tox-pointer _int32_t _uint8_t _uint64_t
                                                       _string _uint16_t _voidptr -> _void)
                                                 _voidptr -> _void))

#| Set the callback for file control requests.
 #
 #  receive_send is 1 if the message is for a slot on which we are currently sending a file and 0 if the message
 #  is for a slot on which we are receiving the file
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t receive_send, uint8_t filenumber, uint8_t control_type, uint8_t *data, uint16_t length, void *userdata)
 #
 #
 # void tox_callback_file_control(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t, uint8_t, uint8_t, uint8_t *,
 #                                uint16_t, void *), void *userdata);
 |#
(define-tox tox_callback_file_control (_fun _Tox-pointer
                                            (_fun _Tox-pointer _int32_t _uint8_t _uint8_t _uint8_t
                                                  _uint8_t-pointer _uint16_t _voidptr -> _void)
                                            _voidptr -> _void))

#| Set the callback for file data.
 #
 #  Function(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint8_t *data, uint16_t length, void *userdata)
 #
 #
 # void tox_callback_file_data(Tox *tox, void (*function)(Tox *m, int32_t, uint8_t, uint8_t *, uint16_t length, void *),
 #                             void *userdata);
 |#
(define-tox tox_callback_file_data (_fun _Tox-pointer
                                         (_fun _Tox-pointer _int32_t _uint8_t _string
                                               _uint16_t _voidptr -> _void)
                                         _voidptr -> _void))

#| Send a file send request.
 # Maximum filename length is 255 bytes.
 #  return file number on success
 #  return -1 on failure
 #
 # int tox_new_file_sender(Tox *tox, int32_t friendnumber, uint64_t filesize, uint8_t *filename, uint16_t filename_length);
 |#
(define-tox tox_new_file_sender (_fun _Tox-pointer _int32_t _uint64_t
                                      _string _uint16_t
                                      -> _int))

#| Send a file control request.
 #
 # send_receive is 0 if we want the control packet to target a file we are currently sending,
 # 1 if it targets a file we are currently receiving.
 #
 #  return 0 on success
 #  return -1 on failure
 #
 # int tox_file_send_control(Tox *tox, int32_t friendnumber, uint8_t send_receive, uint8_t filenumber, uint8_t message_id,
 #                           uint8_t *data, uint16_t length);
 |#
(define-tox tox_file_send_control (_fun _Tox-pointer _int32_t _uint8_t
                                        _uint8_t _uint8_t _string
                                        _uint16_t -> _int))

#| Send file data.
 #
 #  return 0 on success
 #  return -1 on failure
 #
 # int tox_file_send_data(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint8_t *data, uint16_t length);
 |#
(define-tox tox_file_send_data (_fun _Tox-pointer _int32_t _uint8_t
                                    _uint8_t-pointer _uint16_t -> _int))

#| Returns the recommended/maximum size of the filedata you send with tox_file_send_data()
 #
 #  return size on success
 #  return -1 on failure (currently will never return -1)
 #
 # int tox_file_data_size(Tox *tox, int32_t friendnumber);
 |#
(define-tox tox_file_data_size (_fun _Tox-pointer _int32_t -> _int))

#| Give the number of bytes left to be sent/received.
 #
 #  send_receive is 0 if we want the sending files, 1 if we want the receiving.
 #
 #  return number of bytes remaining to be sent/received on success
 #  return 0 on failure
 #
 # uint64_t tox_file_data_remaining(Tox *tox, int32_t friendnumber, uint8_t filenumber, uint8_t send_receive);
 |#
(define-tox tox_file_data_remaining (_fun _Tox-pointer _int32_t _uint8_t _uint8_t -> _uint64_t))

#| ##############END OF FILE SENDING FUNCTIONS################## |#


#|
 # Use this function to bootstrap the client.
 |#

#| Resolves address into an IP address. If successful, sends a "get nodes"
 #   request to the given node with ip, port (in network byte order, HINT: use htons())
 #   and public_key to setup connections
 #
 # address can be a hostname or an IP address (IPv4 or IPv6).
 # if ipv6enabled is 0 (zero), the resolving sticks STRICTLY to IPv4 addresses
 # if ipv6enabled is not 0 (zero), the resolving looks for IPv6 addresses first,
 #   then IPv4 addresses.
 #
 #  returns 1 if the address could be converted into an IP address
 #  returns 0 otherwise
 #
 # int tox_bootstrap_from_address(Tox *tox, const char *address, uint8_t ipv6enabled,
 #                                uint16_t port, uint8_t *public_key);
 |#
(define-tox tox_bootstrap_from_address (_fun _Tox-pointer _string _uint8_t
                                             _uint16_t _string
                                             -> _int))

#|  return 0 if we are not connected to the DHT.
 #  return 1 if we are.
 #
 # int tox_isconnected(Tox *tox);
 |#
(define-tox tox_isconnected (_fun _Tox-pointer -> _int))

#|
 #  Run this function at startup.
 #
 # Initializes a tox structure
 #  The type of communication socket depends on ipv6enabled:
 #  If set to 0 (zero), creates an IPv4 socket which subsequently only allows
 #    IPv4 communication
 #  If set to anything else, creates an IPv6 socket which allows both IPv4 AND
 #    IPv6 communication
 #
 #  return allocated instance of tox on success.
 #  return 0 if there are problems.
 #
 # Tox *tox_new(uint8_t ipv6enabled);
 |#
(define-tox tox_new (_fun _uint8_t -> _Tox-pointer))

#| Run this before closing shop.
 # Free all datastructures.
 # void tox_kill(Tox *tox);
 |#
(define-tox tox_kill (_fun _Tox-pointer -> _void))

#| The main loop that needs to be run at least 20 times per second.
 # void tox_do(Tox *tox);
 |#
(define-tox tox_do (_fun _Tox-pointer -> _void))

#|
 # tox_wait_data_size():
 #
 #  returns a size of data buffer to allocate. the size is constant.
 #
 # tox_wait_prepare(): function should be called under lock every time we want to call tox_wait_execute()
 # Prepares the data required to call tox_wait_execute() asynchronously
 #
 # data[] should be of at least tox_wait_data_size() size and it's reserved and kept by the caller
 # Use that data[] to call tox_wait_execute()
 #
 #  returns  1 on success
 #  returns  0 if data was NULL
 #
 #
 # tox_wait_execute(): function can be called asynchronously
 # Waits for something to happen on the socket for up to seconds seconds and mircoseconds microseconds.
 # mircoseconds should be between 0 and 999999.
 # If you set either or both seconds and microseconds to negatives, it will block indefinetly until there
 # is an activity.
 #
 #  returns  2 if there is socket activity (i.e. tox_do() should be called)
 #  returns  1 if the timeout was reached (tox_do() should be called anyway. it's advised to call it at least
 #             once per second)
 #  returns  0 if data was NULL
 #
 #
 # tox_wait_cleanup(): function should be called under lock,  every time tox_wait_execute() finishes
 # Stores results from tox_wait_execute().
 #
 # returns  1 on success
 #  returns  0 if data was NULL
 #
 #
 # size_t tox_wait_data_size();
 # int tox_wait_prepare(Tox *tox, uint8_t *data);
 # int tox_wait_execute(uint8_t *data, long seconds, long microseconds);
 # int tox_wait_cleanup(Tox *tox, uint8_t *data);
 |#
(define-tox tox_wait_data_size (_fun -> _size_t))
(define-tox tox_wait_prepare (_fun _Tox-pointer _pointer -> _int))
(define-tox tox_wait_execute (_fun _pointer _long _long -> _int))
(define-tox tox_wait_cleanup (_fun _Tox-pointer _pointer -> _int))


#| SAVING AND LOADING FUNCTIONS: |#

#|  return size of messenger data (for saving).
 # uint32_t tox_size(Tox *tox);
 |#
(define-tox tox_size (_fun _Tox-pointer -> _uint32_t))

#| Save the messenger in data (must be allocated memory of size Messenger_size()).
 # void tox_save(Tox *tox, uint8_t *data);
 |#
(define-tox tox_save (_fun _Tox-pointer _pointer -> _void))

#| Load the messenger from data of size length.
 #
 #  returns 0 on success
 #  returns -1 on failure
 #
 # int tox_load(Tox *tox, uint8_t *data, uint32_t length);
 |#
(define-tox tox_load (_fun _Tox-pointer _pointer _uint32_t -> _int))
