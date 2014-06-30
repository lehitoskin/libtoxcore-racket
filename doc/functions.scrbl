#lang scribble/doc
@; functions.scrbl
@(require "common.rkt")

@title[#:tag "functions"]{Functions}
@defmodule[libtoxcore-racket/functions]

The functions in @racketmodname[libtoxcore-racket/functions] are the base wrappers
for the functions found in libtoxcore.

@section[#:tag "get-set"]{Getters and Setters}

@defproc[(friendlist-length [tox _Tox-pointer]) integer?]{
  Return the number of friends in the instance.

  You should use this to determine how much memory to allocate
  for copy_friendlist.
}

@defproc[(friend-exists? [tox _Tox-pointer] [friendnumber integer?]) boolean?]{
  Checks if there exists a friend with given friendnumber.

  return @racket[#t] if friend exists.

  return @racket[#f] if friend doesn't exist.
}

@defproc[(get-address [tox _Tox-pointer] [address bytes?]) void?]{
  format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
  
  @racket[address] should be a buffer of @racket[(make-bytes TOX_FRIEND_ADDRESS_SIZE)].
  
  Modify @racket[address] to be a byte address to give to others. (Must be transformed
  into hex format for ordinary usage).
}

@defproc[(get-client-id [tox _Tox-pointer] [friendnumber integer?] [client-id bytes?]) integer?]{
  Copies the public key associated to that friend id into @racket[client-id] buffer.

  Make sure that client-id is of size @racket[CLIENT_ID_SIZE].

  return 0 if success.

  return -1 if failure.
}

@defproc[(get-friend-connection-status [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  Checks friend's connecting status.

  return 1 if friend is connected to us (Online).

  return 0 if friend is not connected to us (Offline).

  return -1 on failure.
}

@defproc[(get-friendlist [tox _Tox-pointer] [out-list bytes?] [list-size integer?]) integer?]{
  Copy a list of valid friend IDs into the array @racket[out-list].

  If @racket[out-list] is NULL, returns 0.

  Otherwise, returns the number of elements copied.

  If the array was too small, the contents
  of @racket[out-list] will be truncated to @racket[list-size].
}

@defproc[(get-friend-number [tox _Tox-pointer] [client-id bytes?]) integer?]{
  return the friend number associated to that client id.
  
  return -1 if no such friend
}

@defproc[(is-typing? [tox _Tox-pointer] [friendnumber integer?]) boolean?]{
  Get the typing status of a friend.

  returns 0 if friend is not typing.

  returns 1 if friend is typing.
}

@defproc[(get-last-online [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  returns timestamp of last time @racket[friendnumber] was seen online, or 0 if never seen.

  returns -1 on error.
}

@defproc[(get-name [tox _Tox-pointer] [friendnumber integer?] [name bytes?]) integer?]{
  Get name of friendnumber and put it in name.

  name needs to be a valid memory location with a size of at least
  @racket[MAX_NAME_LENGTH] (128) bytes.

  return length of name if success.

  return -1 if failure.
}

@defproc[(get-name-size [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  returns the length of name on success.

  returns -1 on failure.
}

@defproc[(get-num-online-friends [tox _Tox-pointer]) integer?]{
  Return the number of online friends in the instance m.
}

@defproc[(get-self-name [tox _Tox-pointer] [name bytes?]) integer?]{
  name - needs to be a valid bytes buffer with a size of
  at least @racket[MAX_NAME_LENGTH] (128) bytes.

  return length of name.

  return 0 on error.
}

@defproc[(get-self-name-size [tox _Tox-pointer]) integer?]{
  The @tt{self} variant returns the length of @italic{our} name on success,
  and returns -1 on failure.
}

@defproc[(get-self-status-message [tox _Tox-pointer] [buf bytes?] [maxlen integer?]
                                  (bytes-length buf)) integer?]{
  Like @tt{get-status-message}, the @tt{self} variant copies the @italic{our}
  status message into buf, truncating if size is over maxlen.
}

@defproc[(get-self-status-message-size [tox _Tox-pointer]) integer?]{
  Like @tt{get-status_message-size}, the @tt{self} variant returns the length of our
  status message on success, and returns -1 on failure.
}

@defproc[(get-self-user-status [tox _Tox-pointer]) integer?]{
  Like @tt{get-user-status}, the @tt{self} variant will return @italic{our own}
  @racket[TOX_USERSTATUS].
}

@defproc[(get-status-message [tox _Tox-pointer] [friendnumber integer?]
                             [buf bytes?] [maxlen integer?]) integer?]{
  Copy friendnumber's status message into buf, truncating if size is over maxlen.

  Get the size you need to allocate from @tt{get-status-message-size}.

  The self variant will copy our own status message.

  returns the length of the copied data on success.

  returns -1 on failure.
}

@defproc[(get-status-message-size [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  returns the length of status message on success.

  returns -1 on failure.
}

@defproc[(get-user-status [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  return one of @racket[TOX_USERSTATUS] values.

  Values unknown to your application should be represented as @racket[TOX_USERSTATUS_NONE].

  If friendnumber is invalid, this shall return @racket[TOX_USERSTATUS_INVALID].
}

@defproc[(set-name [tox _Tox-pointer] [name string?] [len integer?
                                                       (bytes-length
                                                        (string->bytes/utf-8))]) integer?]{
  Set our nickname.
  
  name must be a string of maximum @racket[MAX_NAME_LENGTH] length.
  
  length must be at least 1 byte.
  
  length is the length of name with the NULL terminator.
 
  return 0 if success.
  
  return -1 if failure.
}

@defproc[(set-sends-receipts [tox _Tox-pointer] [friendnumber integer?]
                                 [yesno? boolean?]) void?]{
  Sets whether we send read receipts for friendnumber.
}

@defproc[(set-status-message [tox _Tox-pointer] [status string?]
                             [len integer? (bytes-length
                                            (string->bytes/utf-8 status))]) integer?]{
  Set our status message.
  
  max length of the status is @racket[TOX_MAX_STATUSMESSAGE_LENGTH].
  
  returns 0 on success.
  
  returns -1 on failure.
}

@defproc[(set-user-status [tox _Tox-pointer] [userstatus integer?]) integer?]{
  Set our user status.
 
  userstatus must be one of @racket[TOX_USERSTATUS] values.
 
  returns 0 on success.
  
  returns -1 on failure.
}

@defproc[(set-user-is-typing [tox _Tox-pointer] [friendnumber integer?]
                             [istyping? boolean?]) integer?]{
  Set our typing status for a friend.

  You are responsible for turning it on or off.

  returns 0 on success.

  returns -1 on failure.
}

@defproc[(get-group-number-peers [tox _Tox-pointer] [groupnumber integer?]) integer?]{
  Return the number of peers in the group chat on success.
  
  return -1 on failure
}

@defproc[(get-group-names [tox _Tox-pointer] [groupnumber integer?]
                          [names (list-of/c string?)] [lengths (list-of/c integer?)]
                          [len integer?]) integer?]{
  List all the peers in the group chat.
 
  Copies the names of the peers to the name[length][TOX_MAX_NAME_LENGTH] array.
 
  Copies the lengths of the names to lengths[length]
 
  returns the number of peers on success.
 
  return -1 on failure.
}

@defproc[(count-chatlist [tox _Tox-pointer]) integer?]{
  Return the number of group chats in the instance @racket[tox].
 
  You should use this to determine how much memory to allocate
  for copy_chatlist.
}

@defproc[(get-chatlist [tox _Tox-pointer] [out-list bytes?]
                       [list-size integer?]) integer?]{
  Copy a list of valid chat IDs into @racket[out-list].
  
  If @racket[out-list] is NULL, returns 0.
  
  Otherwise, returns the number of elements copied.
  
  If the array was too small, the contents of @racket[out-list] will be truncated
  to @racket[list-size].
}

@section[#:tag "interactors"]{Interact with Tox}

@defproc[(bootstrap-from-address [tox _Tox-pointer] [address string?]
                                 [ipv6? boolean?] [port integer?]
                                 [public-key string?]) boolean?]{
  Resolves address into an IP address. If successful, sends a "get nodes"
  request to the given node with ip, port (in network byte order, HINT: use htons())
  and public_key to setup connections

  address can be a hostname or an IP address (IPv4 or IPv6)
  
  if @racket[ipv6?] is @racket[#f], the resolving sticks STRICTLY to IPv4 addresses
  
  if @racket[ipv6?] is not @racket[#f], the resolving looks for IPv6 addresses first,
  then IPv4 addresses.
 
  returns @racket[#t] if the address was converted into an IP address

  returns @racket[#f] otherwise
}

@defproc[(send-message [tox _Tox-pointer] [friendnumber integer?]
                       [message string?] [len integer?]) integer?]{
  Send a text chat message to an online friend.
 
  return the message id if packet was successfully put into the send queue.
  
  return 0 if it was not.
 
  maximum length of messages is @racket[TOX_MAX_MESSAGE_LENGTH], your client must split
  larger messages or else sending them will not work.
 
  You will want to retain the return value, it will be passed to your read_receipt callback
  if one is received.
  
  @tt{send-message-withid} will send a message with the id of your choosing,
  however we can generate an id for you by calling plain @tt{send-message}.
}

@defproc[(send-message-withid [tox _Tox-pointer] [friendnumber integer?]
                                  [theid integer?] [message string?] [len integer?]) integer?]{
  Like @tt{tox_send_message}, but specify a specific ID.
}

@defproc[(send-action [tox _Tox-pointer] [friendnumber integer?] [action string?]
                      [len integer?]) integer?]{
  Send an action to an online friend.

  return the message id if packet was successfully put into the send queue.

  return 0 if it was not.

  You will want to retain the return value, it will be passed to your read_receipt callback
  if one is received.

  @tt{send-action-withid} will send an action message with the id of your choosing,
  however we can generate an id for you by calling plain @tt{send-action}.
}

@defproc[(send-action-withid [tox _Tox-pointer] [friendnumber integer?]
                             [theid integer?] [action string?] [len integer?]) integer?]{
  Like @tt{tox_send_action}, but specify a specific ID.
}

@defproc[(group-message-send [tox _Tox-pointer] [groupnumber integer?]
                             [message string?] [len integer?]) integer?]{
  Send a group message.
  
  return 0 on success.
  
  return -1 on failure.
}

@defproc[(group-action-send [tox _Tox-pointer] [groupnumber integer?]
                            [action string?] [len integer?]) integer?]{
  Send a group action.
  
  return 0 on success.
  
  return -1 on failure.
}

@defproc[(tox-new [ipv6? boolean?]) _Tox-pointer]{
  Run this function at startup.
  
  Initializes a tox structure
  
  The type of communication socket depends on ipv6enabled:
  
  If set to 0 (zero), creates an IPv4 socket which subsequently only allows
  IPv4 communication
  
  If set to anything else, creates an IPv6 socket which allows both IPv4 AND
  IPv6 communication
  
  return allocated instance of tox on success.
  
  return 0 if there are problems.
}

@defproc[(tox-kill! [tox _Tox-pointer]) void?]{
  Run this before closing shop.
  
  Free all datastructures.
}

@defproc[(tox-do [tox _Tox-pointer]) void?]{
  The main loop that needs to be run in intervals of @tt{tox-do-interval} ms.
}

@defproc[(tox-do-interval [tox _Tox-pointer]) integer?]{
  Return the time in milliseconds before @tt{tox-do} should be called again
  for optimal performance.
}

@section[#:tag "friend-group"]{Friend and Group Manipulation}

@defproc[(add-friend [tox _Tox-pointer] [address bytes?]
                     [message string?] [message-length integer?
                                                       (bytes-length
                                                        (string->bytes/utf-8 message))])
         integer?]{
  Add a friend.
  
  Set the message that will be sent along with friend request.
  
  @racket[address] is the address of the friend (returned by getaddress of the friend
  you wish to add) it must be @racket[TOX_FRIEND_ADDRESS_SIZE] bytes.
  
  @racket[message] is the friend request message and @racket[message-length] is the length
  of the message being sent.
 
  return the friend number if success.
  
  return @racket[TOX_FA_TOOLONG] if message length is too long.
  
  return @racket[TOX_FAERR_NOMESSAGE] if no message (message length must be >= 1 byte).
  
  return @racket[TOX_FAERR_OWNKEY] if our own key.
  
  return @racket[TOX_FAERR_ALREADYSENT] if friend request already sent or already a friend.
  
  return @racket[TOX_FAERR_UNKNOWN] for unknown error.
  
  return @racket[TOX_FAERR_BADCHECKSUM] if bad checksum in address.
  
  return @racket[TOX_FAERR_SETNEWNOSPAM] if the friend was already there but the nospam
  was different. (the nospam for that friend was set to a different one).
  
  return @racket[TOX_FAERR_NOMEM] if increasing the friend list size fails.
}

@defproc[(add-friend-norequest [tox _Tox-pointer] [client-id bytes?]) integer?]{
  Add a friend without sending a friendrequest.
  
  return the friend number if success.
  
  return -1 if failure.
  
  @racket[client-id] is the bytes form of the Tox ID; e.g. @racket[(hex-string->bytes str)].
}

@defproc[(del-friend [tox _Tox-pointer] [friendnumber integer?]) integer?]{
  Remove a friend.
 
  return 0 if success.

  return -1 if failure.
}

@defproc[(add-groupchat [tox _Tox-pointer]) integer?]{
  Creates a new groupchat and puts it in the chats array.

  return group number on success.
  
  return -1 on failure.
}

@defproc[(del-groupchat! [tox _Tox-pointer] [groupnumber integer?]) integer?]{
  Delete a groupchat.
  
  return 0 on success.
  
  return -1 on failure.(define-tox group-message-send (_fun [tox : _Tox-pointer]
                                     [groupnumber : _int]
                                     [message : _string]
                                     [len : _uint32_t] -> _int)
  #:c-id tox_group_message_send)
}

@defproc[(invite-friend [tox _Tox-pointer] [friendnumber integer?]
                        [groupnumber integer?]) integer?]{
  Invite friendnumber to groupnumber.
  
  return 0 on success.
  
  return -1 on failure.
}

@defproc[(join-groupchat [tox _Tox-pointer] [friendnumber integer?]
                         [group-id string?]) integer?]{
  Join a group (you need to have been invited first.)
  
  return groupnumber on success.
  
  return -1 on failure.
}

@section[#:tag "callbacks"]{Callbacks}

@subsection[#:tag "general-callbacks"]{General Callbacks}

@defproc[(callback-connection-status [tox _Tox-pointer] [anonproc procedure?]
                                     [userdata cpointer? #f]) void?]{
  This function is kind of tricky because the C library requires a function
  as a parameter (anonproc). This wrapper procedure is kind of tricky and shouldn't be
  considered complete.
  
  @racket[anonproc] is in the form @racket[(anonproc tox friendnumber status userdata)]
  where @racket[status] is a string.
  
  Status:
  
    0 -- friend went offline after being previously online
    
    1 -- friend went online

  NOTE: This callback is not called when adding friends, thus the "after
  being previously online" part. it's assumed that when adding friends,
  their connection status is offline.
}

@subsection[#:tag "file-sending"]{File Sending Callbacks}

@defproc[(callback-file-send-request [tox _Tox-pointer] [anonproc procedure?]
                                     [userdata cpointer? #f]) void?]{
  Set the callback for file send requests.
 
  @racket[anonproc] is in the form @racket[(anonproc tox friendnumber filenumber filesize
                                                    filename filename-length userdata)]
  where @racket[filename] is a string.
}

@defproc[(callback-file-control [tox _Tox-pointer] [anonproc procedure?]
                                [userdata cpointer? #f]) void?]{
  Set the callback for file control requests.
  
  @racket[anonproc] is in the form @racket[(anonproc tox friendnumber sending? filenumber
                                                     control-type data len userdata)]
  where @racket[control-type] is a @racket[TOX_FILECONTROL] enum value.
}
