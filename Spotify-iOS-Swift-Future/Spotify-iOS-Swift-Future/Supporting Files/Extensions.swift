//
//  Extensions.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/14/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import AVFoundation

// MARK: - Double

extension Double {
    func minutesSeconds() -> String {
        let secondsInt = Int(self.rounded())
        let minutes = secondsInt / 60
        let seconds = secondsInt % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - AVAudioSession

extension AVAudioSession {
    static func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
