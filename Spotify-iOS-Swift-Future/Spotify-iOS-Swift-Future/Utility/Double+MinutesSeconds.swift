//
//  Double+MinutesSeconds.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/10/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

extension Double {
    func minutesSeconds() -> String {
        let secondsInt = Int(self.rounded())
        let minutes = secondsInt / 60
        let seconds = secondsInt % 60
        return String(format: "%i:%02d", minutes, seconds)
    }
}
