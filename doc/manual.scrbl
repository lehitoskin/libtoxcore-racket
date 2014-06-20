#lang scribble/manual
@; manual.scrbl
@; add all API functions
@; enter some examples
@(require (for-label racket))

@title{libtoxcore-racket: Racket wrapper for the Tox library}
@author{@author+email["Lehi Toskin" "lehi AT tosk.in"]}

This package provides a 1-to-1 wrapper for the C functions in the Tox
library. There is an OOP implementation being worked on, currently.

@table-of-contents[]

@section[#:tag "Installation"]{Installaion}
@itemlist[@item{If you are using Racket version 6, open a terminal and enter the following:
                @commandline{raco pkg install
                             github://github.com/lehitoskin/libtoxcore-racket/master}}
           @item{If you are using Racket version 5.3.x (most likely), run the following:
                 @commandline{raco pkg install
                     github://github.com/lehitoskin/libtoxcore-racket/racket5.3}}]
Racket's raco package manager will do the rest. Alternatively, you may install
the package by copying the github link and pasting it into DrRacket's "Install
Package" tool.

@section[#:tag "Procedures"]{Procedures}
@defproc[(tox_add_friend [my-tox cpointer?] [address string?] [data string?]
                         [length number?]) integer?]{
  Add a friend.

  Set the data that will be sent along with friend request.

  address is the address of the friend (returned by getaddress of the friend you
  wish to add) it must be TOX_FRIEND_ADDRESS_SIZE bytes.

  data is the data and length is the length.


  return the friend number if success.

  return TOX_FA_TOOLONG if message length is too long.

  return TOX_FAERR_NOMESSAGE if no message (message length must be >= 1 byte).

  return TOX_FAERR_OWNKEY if user's own key.

  return TOX_FAERR_ALREADYSENT if friend request already sent or already a friend.

  return TOX_FAERR_UNKNOWN for unknown error.

  return TOX_FAERR_BADCHECKSUM if bad checksum in address.

  return TOX_FAERR_SETNEWNOSPAM if the friend was already there but the nospam was different.

  (the nospam for that friend was set to the new one).

  return TOX_FAERR_NOMEM if increasing the friend list size fails.
}

@defproc[(tox_add_friend_norequest [my-tox cpointer?] [address string?]
                                   [data string?] [length number?]) integer?]{
  Add a friend without sending a friendrequest.
  
  return the friend number if success.
  
  return -1 if failure.
}

@defproc[(tox_add_groupchat [my-tox cpointer?]) integer?]{
  Creates a new groupchat and puts it in the chats array.

  return group number on success.
  
  return -1 on failure.
}

@defproc[(tox_bootstrap_from_address [my-tox cpointer?] [address string?]
                                     [ipv6enabled number?] [port number?]
                                     [pub_key string?]) integer?]{
  Resolves address into an IP address. If successful, sends a "get nodes"
  request to the given node with ip, port (in network byte order, HINT: use htons())
  and public_key to setup connections

  address can be a hostname or an IP address (IPv4 or IPv6).
  if ipv6enabled is 0 (zero), the resolving sticks STRICTLY to IPv4 addresses
  if ipv6enabled is not 0 (zero), the resolving looks for IPv6 addresses first,
  then IPv4 addresses.
 
  returns 1 if the address could be converted into an IP address

  returns 0 otherwise
}

@defproc[(tox_bootstrap_from_ip [my-tox cpointer?] [ip-port cstruct?]
                                [pubkey string?]) void?]{
  WARNING: DEPRECATED, DO NOT USE
  
  ip-port is an instance of the struct tox_IP_Port

  Sends a "get nodes" request to the given node with ip, port and public_key
  to setup connections
}

@defproc[(tox_callback_connection_status [my-tox cpointer?] [anon-proc void?]
                                [userdata voidptr?]) void?]{
  This function is kind of tricky because the C library requires a function
  as a parameter (anon-proc). This wrapper procedure is kind of tricky and shouldn't be
  considered complete.
  
  anon-proc is in the form
    @commandline{function(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)}
  
  Status:
  
    0 -- friend went offline after being previously online
    
    1 -- friend went online

  NOTE: This callback is not called when adding friends, thus the "after
  being previously online" part. it's assumed that when adding friends,
  their connection status is offline.
}

@defproc[(tox_count_friendlist [my-tox cpointer?]) integer?]{
  Return the number of friends in the instance m.

  You should use this to determine how much memory to allocate
  for copy_friendlist.
}

@defproc[(tox_del_friend [my-tox cpointer?]) integer?]{
  Remove a friend.
 
  return 0 if success.

  return -1 if failure.
}

@defproc[(tox_friend_exists [my-tox cpointer?]) integer?]{
  Checks if there exists a friend with given friendnumber.

  return 1 if friend exists.

  return 0 if friend doesn't exist.
}

@defproc[(tox_get_address [my-tox cpointer?]) void?]{
  return TOX_FRIEND_ADDRESS_SIZE byte address to give to others.

  format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
}

@defproc[(tox_get_client_id [my-tox cpointer?]) integer?]{
  Copies the public key associated to that friend id into client_id buffer.

  Make sure that client_id is of size CLIENT_ID_SIZE.

  return 0 if success.

  return -1 if failure.
}

@defproc[(tox_get_friend_connection_status [my-tox cpointer?]) integer?]{
  Checks friend's connecting status.

  return 1 if friend is connected to us (Online).

  return 0 if friend is not connected to us (Offline).

  return -1 on failure.
}

@defproc[(tox_get_friendlist [my-tox cpointer?]) integer?]{
  Copy a list of valid friend IDs into the array out_list.

  If out_list is NULL, returns 0.

  Otherwise, returns the number of elements copied.

  If the array was too small, the contents
  of out_list will be truncated to list_size.
}

@defproc[(tox_get_friend_number [my-tox cpointer?]) integer?]{
  return the friend number associated to that client id.
  
  return -1 if no such friend
}

@defproc[(tox_get_is_typing [my-tox cpointer?]) integer?]{
  Get the typing status of a friend.

  returns 0 if friend is not typing.

  returns 1 if friend is typing.
}

@defproc[(tox_get_last_online [my-tox cpointer?]) integer?]{
  returns timestamp of last time friendnumber was seen online, or 0 if never seen.

  returns -1 on error.
}

@defproc[(tox_get_name [my-tox cpointer?]) integer?]{
  Get name of friendnumber and put it in name.

  name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.

  return length of name if success.

  return -1 if failure.
}

@defproc[(tox_get_name_size [my-tox cpointer?]) integer?]{
  returns the length of name on success.

  returns -1 on failure.
}

@defproc[(tox_get_num_online_friends [my-tox cpointer?]) integer?]{
  Return the number of online friends in the instance m.
}

@defproc[(tox_get_self_name [my-tox cpointer?]) integer?]{
  name - needs to be a valid memory location with a size of
  at least MAX_NAME_LENGTH (128) bytes.

  return length of name.

  return 0 on error.
}

@defproc[(tox_get_self_name_size [my-tox cpointer?]) integer?]{
  Like @tt{tox_get_name_size}, the @tt{self} variant returns the length of @italic{our} name on success, and returns -1 on failure.
}

@defproc[(tox_get_self_status_message [my-tox cpointer?]) integer?]{
  Like @tt{tox_get_status_message}, the @tt{self} variant copies the @italic{our} status message into buf, truncating if size is over maxlen.
}

@defproc[(tox_get_self_status_message_size [my-tox cpointer?]) integer?]{
  Like @tt{tox_get_status_message_size}, the @tt{self} variant returns the length of our status message on success, and returns -1 on failure.
}

@defproc[(tox_get_self_user_status [my-tox cpointer?]) integer?]{
  Like @tt{tox_get_user_status}, the @tt{self} variant will return @italic{our own} TOX_USERSTATUS.
}

@defproc[(tox_get_status_message [my-tox cpointer?]) integer?]{
  Copy friendnumber's status message into buf, truncating if size is over maxlen.

  Get the size you need to allocate from m_get_statusmessage_size.

  The self variant will copy our own status message.

  returns the length of the copied data on success.

  returns -1 on failure.
}

@defproc[(tox_get_status_message_size [my-tox cpointer?]) integer?]{
  returns the length of status message on success.

  returns -1 on failure.
}

@defproc[(tox_get_user_status [my-tox cpointer?]) integer?]{
  return one of TOX_USERSTATUS values.

  Values unknown to your application should be represented as TOX_USERSTATUS_NONE.

  If friendnumber is invalid, this shall return TOX_USERSTATUS_INVALID.
}

@defproc[(tox_send_action [my-tox cpointer?]) integer?]{
  Send an action to an online friend.

  return the message id if packet was successfully put into the send queue.

  return 0 if it was not.

  You will want to retain the return value, it will be passed to your read_receipt callback
  if one is received.

  m_sendaction_withid will send an action message with the id of your choosing,
  however we can generate an id for you by calling plain m_sendaction.
}

@defproc[(tox_send_action_withid [my-tox cpointer?]) integer?]{
  Like @tt{tox_send_action}, but specify a specific ID.
}

@defproc[(tox_send_message [my-tox cpointer?]) integer?]{
  Send a text chat message to an online friend.

  return the message id if packet was successfully put into the send queue.

  return 0 if it was not.

  You will want to retain the return value, it will be passed to your read_receipt callback
  if one is received.

  m_sendmessage_withid will send a message with the id of your choosing,
  however we can generate an id for you by calling plain m_sendmessage.
}

@defproc[(tox_send_message_withid [my-tox cpointer?]) integer?]{
  Like @tt{tox_send_message}, but specify a specific ID.
}

@defproc[(tox_set_name [my-tox cpointer?]) integer?]{
  Set our nickname.

  name must be a string of maximum MAX_NAME_LENGTH length.

  length must be at least 1 byte.

  length is the length of name with the NULL terminator.

  return 0 if success.

  return -1 if failure.
}

@defproc[(tox_set_sends_receipts [my-tox cpointer?]) void?]{
  Sets whether we send read receipts for friendnumber.

  This function is not lazy, and it will fail if yesno is not (0 or 1).
}

@defproc[(tox_set_status_message [my-tox cpointer?]) integer?]{
  Set our user status.

  userstatus must be one of TOX_USERSTATUS values.

  returns 0 on success.

  returns -1 on failure.
}

@defproc[(tox_set_user_is_typing [my-tox cpointer?]) integer?]{
  Set our typing status for a friend.

  You are responsible for turning it on or off.

  returns 0 on success.

  returns -1 on failure.
}

@defproc[(tox_set_user_status [my-tox cpointer?]) integer?]{
  Set our user status.

  userstatus must be one of TOX_USERSTATUS values.

  returns 0 on success.

  returns -1 on failure.
}

@section[#:tag "Examples"]{Examples}

@verbatim{
; simple 1-to-1 function wrapper
(require libtoxcore-racket)

(define my-tox (tox_new TOX_ENABLE_IPV6_DEFAULT))
(define my-name "Toxizen5k")
(define my-status-message "Testing Tox with the Racket wrapper!")

(tox_set_name my-tox my-name (string-length my-name))
(tox_set_user_status_message my-status_message (string-length my-status-message))

(tox_kill my-tox)
}

@section[#:tag "License"]{License}

This program is free software: you can redistribute it and/or modify it
under the terms of the
@hyperlink["http://www.gnu.org/licenses/gpl.html"]{GNU General Public License}
as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License and GNU Lesser General Public License for more
details.
