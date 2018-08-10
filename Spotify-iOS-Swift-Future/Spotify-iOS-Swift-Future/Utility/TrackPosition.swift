//
//  TrackPosition.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/14/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

struct TrackPosition {
    let currentPosition: TimeInterval
    let totalDuration: TimeInterval
    
    init(currentPosition: TimeInterval, totalDuration: TimeInterval) {
        self.currentPosition = currentPosition
        self.totalDuration = totalDuration
    }
    
    var currentTime: String {
        return currentPosition.minutesSeconds()
    }
    
    var remainingTime: String {
        return (totalDuration - currentPosition).minutesSeconds()
    }
    
    var currentValue: Float {
        return Float(currentPosition / totalDuration)
    }
}
