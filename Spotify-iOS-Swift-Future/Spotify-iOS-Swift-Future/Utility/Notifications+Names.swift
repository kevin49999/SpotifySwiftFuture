//
//  Notifications+Names.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/10/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let trackChanged = NSNotification.Name("TrackChanged")
    static let trackIsPlayingChanged = NSNotification.Name("TrackIsPlayingChanged")
    static let trackIsShufflingChanged = NSNotification.Name("TrackIsShufflingChanged")
    static let trackPositionUpdate = NSNotification.Name("TrackPositionUpdate")
    static let spotifySessionUpdated = NSNotification.Name("SpotifySessionUpdated")
}
