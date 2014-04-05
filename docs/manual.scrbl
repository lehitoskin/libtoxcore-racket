#lang scribble/manual
@; manual.scrbl
@; add all API functions
@; enter some examples

@title{libtoxcore-racket: Racket wrapper for the Tox library}
@author{@author+email["Lehi Toskin" "lehi AT tosk.in"]}

This package provides a 1-to-1 wrapper for the C functions in the Tox
library. There is an OOP implementation being worked on, currently.

@section{Installaion}
@commandline{raco pkg install
                     github://github.com/lehitoskin/libtoxcore-racket/master}

@section{Procedures}
@defproc[(tox_add_friend [my-tox cpointer?] [address string?] [data string?]
                         [length number?]) number?]{
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
                                   [data string?] [length number?]) number?]{
  Add a friend without sending a friendrequest.
  
  return the friend number if success.
  
  return -1 if failure.
}

@defproc[(tox_add_groupchat [my-tox cpointer?]) number?]{
  Creates a new groupchat and puts it in the chats array.

  return group number on success.
  
  return -1 on failure.
}

@defproc[(tox_get_address [my-tox cpointer?] [address string?]) void?]{
  return TOX_FRIEND_ADDRESS_SIZE byte address to give to others.
}

@defproc[(tox_bootstrap_from_address [my-tox cpointer?] [address string?]
                                     [ipv6enabled number?] [port number?]
                                     [pub_key string?]) number?]{
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

@section{Examples}

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

@section{License}

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
