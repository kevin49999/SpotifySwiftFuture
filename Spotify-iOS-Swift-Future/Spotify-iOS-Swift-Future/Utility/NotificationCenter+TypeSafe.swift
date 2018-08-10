//
//  NotificationCenter+TypeSafe.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/10/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func addObserver<T>(forName: NSNotification.Name, type: T.Type, callback: @escaping (_ object: T, _ userInfo: [AnyHashable: Any]?) -> Void) {
        addObserver(forName: forName, object: nil, queue: nil) { notification in
            if let object = notification.object as? T {
                callback(object, notification.userInfo)
            }
        }
    }
}
