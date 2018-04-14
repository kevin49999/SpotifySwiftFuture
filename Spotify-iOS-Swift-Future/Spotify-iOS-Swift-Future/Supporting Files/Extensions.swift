//
//  Extensions.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/14/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

// MARK: - Double

extension Double {
    func minutesSeconds() -> String {
        let secondsInt = Int(self.rounded())
        let minutes = secondsInt / 60
        let seconds = secondsInt % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
