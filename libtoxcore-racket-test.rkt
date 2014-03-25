#!/usr/bin/env racket
#lang racket
; libtoxcore-racket-test.rkt
(require racket/include)
(include "libtoxcore-racket.rkt")

; initialize a new Tox and grab the _Tox-pointer
(define my-tox (tox_new TOX_ENABLE_IPV6_DEFAULT))
(define my-name "Leah Twoskin")

(display "Setting my name\n")
; set name
(tox_set_name my-tox my-name (string-length my-name))

(display "How long is my name?\n")
; returns length of my-name
(tox_get_self_name_size my-tox)
; returns the same as above... for some reason
(tox_get_self_name my-tox my-name)

(display "How large is the encrypted data?\n")
(tox_size_encrypted my-tox)

; THIS KILLS THE TOX
(tox_kill my-tox)

#|
    haven't tried using these yet
    might take a while...
    
    tox_get_address
    tox_add_friend
    tox_add_friend_norequest
    tox_get_friend_number
    tox_get_client_id
    tox_del_friend
    tox_get_friend_connection_status
    tox_friend_exists
    tox_send_message
    tox_send_message_withid
    tox_send_action
    tox_send_action_withid
    tox_get_name
    tox_get_name_size
    tox_set_status_message
    tox_set_user_status
    tox_get_status_message_size
    tox_get_self_status_message_size
    tox_get_status_message
    tox_get_self_status_message
    tox_get_user_status
    tox_get_self_user_status
    tox_get_last_online
    tox_set_user_is_typing
    tox_get_is_typing
    tox_set_sends_receipts
    tox_count_friendlist
    tox_get_num_online_friends
    tox_get_friendlist
    tox_callback_friend_request
    tox_callback_friend_message
    tox_callback_friend_action
    tox_callback_name_change
    tox_callback_status_message
    tox_callback_user_status
    tox_callback_typing_change
    tox_callback_read_receipt
    tox_callback_connection_status
    tox_callback_group_invite
    tox_callback_group_message
    tox_callback_group_action
    tox_callback_group_namelist_change
    tox_add_groupchat
    tox_del_groupchat
    tox_group_peername
    tox_invite_friend
    tox_join_groupchat
    tox_group_message_send
    tox_group_action_sent
    tox_group_number_peers
    tox_group_get_names
    tox_count_chatlist
    tox_get_chatlist
    tox_callback_file_send_request
    tox_callback_file_control
    tox_callback_file_data
    tox_new_file_sender
    tox_file_send_control
    tox_file_send_data
    tox_file_data_size
    tox_file_data_remaining
    tox_bootstrap_from_ip
    tox_bootstrap_from_address
    tox_isconnected
    tox_do
    tox_wait_data_size
    tox_wait_prepare
    tox_wait_execute
    tox_wait_cleanup
    tox_size
    tox_save
    tox_load
    tox_size_encrypted
    tox_save_encrypted
    tox_load_encrypted
|#