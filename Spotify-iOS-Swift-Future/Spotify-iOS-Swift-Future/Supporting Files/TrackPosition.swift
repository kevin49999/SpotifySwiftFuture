//
//  TrackPosition.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/14/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

struct TrackPosition {
    var currentPosition: TimeInterval!
    var totalDuration: TimeInterval!
    
    init(currentPosition: TimeInterval, totalDuration: TimeInterval) {
        self.currentPosition = currentPosition
        self.totalDuration = totalDuration
    }
    
    func currentTime() -> String {
        return currentPosition.minutesSeconds()
    }
    
    func remainingTime() -> String {
        return (totalDuration - currentPosition).minutesSeconds()
    }
    
    func currentValue() -> Float {
        return Float(currentPosition / totalDuration)
    }
}
