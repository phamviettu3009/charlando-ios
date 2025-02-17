//
//  File.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 24/04/2024.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import PushKit
import CallKit

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate {
    let callManager = CallManager()
    var providerDelegate: ProviderDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase Notification Config
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOption) { _, _ in }
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
        // PushKit Config
        let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        return true
    }
    
    // MARK: - Notification Delegate
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let deleteNotifyID = userInfo["deleteNotifyID"] as? String else {
            completionHandler(.noData)
            return
        }
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [deleteNotifyID])
        completionHandler(.noData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let deepLink = userInfo["deepLink"] as? String {
            if let url = URL(string: deepLink) {
                UIApplication.shared.open(url)
            }
        }
        
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
        // Lưu trữ FCM token trên máy chủ của bạn hoặc sử dụng nó trong ứng dụng của bạn.
    }
    
    // MARK: - PushKit Delegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("PushKit token: \(token)")
        // Gửi token này lên server của bạn
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received PushKit notification: \(payload.dictionaryPayload)")
        // Xử lý thông báo ở đây
        
        let data = payload.dictionaryPayload
        
        guard let caller = data["caller"] as? [String: Any] else {
            reportInvalidIncomingCall {}
            return
        }
        
        guard let callerID = caller["id"] as? String else {
            reportInvalidIncomingCall {}
            return
        }
        
        guard let callerName = caller["name"] as? String else {
            reportInvalidIncomingCall {}
            return
        }
        
        guard let hasVideo = data["callType"] as? String else {
            reportInvalidIncomingCall {}
            return
        }
        
        reportIncomingCall(from: callerName, hasVideo: hasVideo == "video")
        
        
        completion()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        // Xử lý khi token bị invalid
    }
    
    func reportInvalidIncomingCall(completion: () -> Void) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "invalid")
        let randomUUID = UUID()
        
        self.providerDelegate?.reportIncomingCall(with: randomUUID)
        completion()
    }
    
    func reportIncomingCall(from callerID: String, hasVideo: Bool) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callerID)
        let uuid = UUID()
        
        self.providerDelegate?.reportIncomingCall(with: uuid, remoteUserID: callerID, hasVideo: hasVideo) { error in
            if let error = error { print(error.localizedDescription) }
            else { print("Ring Ring...") }
        }
    }
}
