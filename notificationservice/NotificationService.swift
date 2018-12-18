//
//  NotificationService.swift
//  notificationservice
//
//  Created by Igor Efremov on 05/03/2019.
//  Copyright © 2019 Exantech. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var improvedContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        improvedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let improvedContent = improvedContent {
            if let data = improvedContent.userInfo["custom-data"] as? [String: String] {
                var info = ""
                if let status = data["status"] {
                    switch status {
                    case "joined":
                        info = "Participant joined"
                    default:
                        break
                    }
                }
                
                improvedContent.body = info
            }
            
            contentHandler(improvedContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let improvedContent =  improvedContent {
            contentHandler(improvedContent)
        }
    }

}
