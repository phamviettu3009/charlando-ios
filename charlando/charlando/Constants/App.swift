//
//  App.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import Foundation

let SERVICE_NAME = "https://chatflow.info.vn"
let ACCOUNT_NAME = "jwt"
let TENANT_CODE = "MSC"

let DEV_MODE = true

let BASE_URL_DEV = "http://192.168.1.5:8443"
let SOCKETIO_URL_DEV = "http://192.168.1.5:5503"

let BASE_URL_PRO = "https://chatflow.info.vn"
let SOCKETIO_URL_PRO = "https://chatflow.info.vn"

let EXTENSION_URL = "/api/v1/"
let BASE_URL = (DEV_MODE ? BASE_URL_DEV : BASE_URL_PRO) + EXTENSION_URL
let SOCKETIO_URL = DEV_MODE ? SOCKETIO_URL_DEV : SOCKETIO_URL_PRO


//AUTH
let LOGIN_ENDPOINT_ENDPOINT = "auth/login-with-email"
let REGISTER_EMAIL_ENDPOINT = "auth/register-with-email"
let VERIFY_ACCOUNT_ENDPOINT = "auth/verify-account"
let RESEND_VERIFY_CODE_ENDPOINT = "auth/resend-verify-code"
let REGISTER_PASSWORD_ENDPOINT = "auth/update-account-after-verify"
let GET_LIST_DEVICE_ENDPOINT = "auth/devices"
let LOGOUT_ENDPOINT = "auth/logout-device"
let LOGOUT_ALL_ENDPOINT = "auth/logout-all-device"
let GET_NEW_ACCESS_TOKEN_ENDPOINT = "auth/get-new-access-token"
let CHANGE_PASSWORD_ENDPOINT = "auth/change-password"
let REQUEST_FORGOT_PASSWORD = "auth/request-forgot-password"
let FORGOT_PASSWORD = "auth/forgot-password"
let UPDATE_FIREBASE_TOKEN = "auth/update-firebase-token"

//USER
let GET_OWNER_USER_EDNPOINT = "users/self"
let GET_LIST_USER_ENDPOINT = "users"
let GET_USER_ENDPOINT = "users/{id}"
let UPDATE_OWNER_USER_ENDPOINT = "users/self"
let UPDATE_OWNER_SETTING_ENDPOINT = "users/self/setting"

//FRIEND
let SEND_REQUEST_ADD_FRIEND_ENDPOINT = "friends/{id}/send-request-add-friend"
let UNFRIEND_ENDPOINT = "friends/{id}/unfriend"
let REJECT_ADD_FRIEND_ENDPOINT = "friends/{id}/reject-friend-request"
let CONFIRMATION_ADD_FRIEND_ENDPOINT = "friends/{id}/confirmation-add-friend"
let CANCEL_REQUEST_ADD_FRIEND_ENDPOINT = "friends/{id}/cancel-request-add-friend"
let GET_LIST_FRIEND_ENDPOINT = "friends"
let GET_LIST_REQUEST_ADD_FRIEND_ENDPOINT = "friends/request-add-friend"
let GET_NUMBER_REQUEST_ADD_FRIEND_ENDPOINT = "friends/number-request-add-friend"
let GET_FRIEND_OUTSIDE_CHANNEL_ENDPOINT = "friends/channels/{id}/outside"

//CHANNEL
let GET_LIST_CHANNEL_ENDPOINT = "channels"
let GET_LIST_MEMBER_IN_CHANNEL_ENDPOINT = "channels/{id}/members"
let CREATE_GROUP_CHANNEL_ENDPOINT = "channels/group"
let GET_CHANNEL_ENDPOINT = "channels/{id}"
let UPDATE_GROUP_CHANNEL_ENDPOINT = "channels/{id}/group"
let GET_ROLE_ENDPOINT = "channels/{id}/group/my-role"
let REMOVE_MEMBER_ENDPOINT = "channels/{id}/group/remove-members"
let ADD_MEMBER_ENDPOINT = "channels/{id}/group/add-members"
let LEAVE_GROUP_ENDPOINT = "channels/{id}/group/leave-group"
let ADD_ADMIN_ROLE_ENDPOINT = "channels/{id}/group/set-admin-role"
let REVOKE_ADMIN_ROLE_ENDPOINT = "channels/{id}/group/revoke-admin-role"
let SET_OWNER_ROLE_ENDPOINT = "channels/{id}/group/set-owner-role"

//MESSAGE
let GET_LIST_MESSAGE_ENDPOINT = "messages/channels/{id}"
let SYNC_NEW_MESSAGE_ENDPOINT = "messages/channels/{id}"
let SYNC_MESSAGE_REACTION_ENDPOINT = "messages/{id}/reaction"
let SYNC_UPDATE_MESSAGE_ENDPOINT = "messages/{id}"
let SYNC_DELETE_MESSAGE_ENDPOINT = "messages/{id}"
let READ_MESSAGE_ENDPOINT = "messages/{id}/read-message"

//RESOURCE
let UPLOAD_PRIVATE_MULTI = "resources/upload/private/multi"
let UPLOAD_PUBLIC_MULTI = "resources/upload/public/multi"
let GET_RESOURCE_ENDPOINT = "resources/"

