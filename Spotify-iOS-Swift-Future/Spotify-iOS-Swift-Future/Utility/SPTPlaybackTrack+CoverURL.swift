//
//  SPTPlaybackTrack+CoverURL.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/12/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation

extension SPTPlaybackTrack {
    var albumCoverURL: URL? {
        if let albumCoverArtURLString = self.albumCoverArtURL {
            return URL(string: albumCoverArtURLString)
        }
        return nil
    }
}
