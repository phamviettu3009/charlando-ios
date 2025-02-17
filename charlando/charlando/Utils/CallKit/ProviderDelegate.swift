//
//  ProviderDelegate.swift
//  charlando
//
//  Created by Phạm Việt Tú on 04/07/2024.
//

import AVFoundation
import UIKit
import CallKit

typealias ErrorHandler2 = ((NSError?) -> ())


extension Notification.Name {
    static let DidCallEnd = Notification.Name("DidCallEnd")
    
    static let DidCallAccepted = Notification.Name("DidCallAccepted")
}

class ProviderDelegate: NSObject, CXProviderDelegate {
    
    let callManager: CallManager
    private let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider.custom
        
        super.init()
        
        // if queue value is nil, delegate will run on main thread
        provider.setDelegate(self, queue: nil)
    }
    
    func reportIncomingCall(with uuid: UUID, remoteUserID: String, hasVideo: Bool, completionHandler: ErrorHandler2? = nil) {
        // Update call based on DirectCall object
        let update = CXCallUpdate()
        update.update(with: remoteUserID, hasVideo: hasVideo, incoming: true)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            guard error == nil else {
                completionHandler?(error as NSError?)
                return
            }
            
            // Add call to call manager
            self.callManager.addCall(uuid: uuid)
        }
    }
    
    func reportIncomingCall(with uuid: UUID) {
        // Update call based on DirectCall object
        let update = CXCallUpdate()
        update.onFailed(with: uuid)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            self.provider.reportCall(with: uuid, endedAt: Date(), reason: .failed)
        }
    }
    
    func endCall(with uuid: UUID, endedAt: Date, reason: CXCallEndedReason) {
        self.provider.reportCall(with: uuid, endedAt: endedAt, reason: reason)
    }
    
    func connectedCall(with uuid: UUID) {
        self.provider.reportOutgoingCall(with: uuid, connectedAt: Date())
    }
    
    func providerDidReset(_ provider: CXProvider) {
        // 1. Stop audio
        
        // 2. End all calls because they are no longer valid
        // CODE HERE
        
        // 3. Remove all calls from the app's list of call
        self.callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        // configure audio session
        
        // If I am caller, add the call to callManager and `reportOutgoingCall(with:connecteAt)` with `CXProvider`
        self.callManager.addCall(uuid: action.callUUID)
        self.connectedCall(with: action.callUUID)
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // configure audio session
        
        // Accept call
        
        // Notify incoming call accepted if it's required.
        NotificationCenter.default.post(name: NSNotification.Name.DidCallAccepted, object: nil)
        
        action.fulfill()
        
        let deepLink = "app2Charlando://message-screen?channelID=b7a3141d-4b95-432f-9261-321265a7d8b9"
        
        if let url = URL(string: deepLink) {
            UIApplication.shared.open(url)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        // 1. Stop audio
        
        // 2. End call
        NotificationCenter.default.post(name: NSNotification.Name.DidCallEnd, object: nil)
        
        action.fulfill()
        
        // 3. Remove the ended call from callManager.
        self.callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // update holding state
        switch action.isOnHold {
        case true:
            // Stop audio
            // Stop video
            action.fulfill()
        case false:
            // Play audio
            // Play video
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        
        // Stop / start audio by using `action.isMuted`
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Start audio
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Restart any non-call related audio now that the app's audio session has been
        // de-activated after having its priority restored to normal.
    }
}
