//
//  AVAudioSession+Activate.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/10/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import AVFoundation

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
