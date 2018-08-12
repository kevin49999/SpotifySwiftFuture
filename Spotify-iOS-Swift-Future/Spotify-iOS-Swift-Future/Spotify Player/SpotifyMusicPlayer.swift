//
//  SpotifyMusicPlayer.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import Foundation
import MediaPlayer

class SpotifyMusicPlayer: NSObject {
    
    // MARK: - Variables
    
    private let audioStreamingController = SPTAudioStreamingController.sharedInstance()!
    private let auth = SPTAuth.defaultInstance()!
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private var isSeeking: Bool = false
    
    // MARK: - Init
    
    override init() {
        super.init()
        startSession()
        setupControlCenterCallbacks()
    }
    
    deinit {
        closeSession()
    }
    
    // MARK: - Play Spotify URI
    
    private func playSpotifyURI(uri: String) {
        audioStreamingController.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { error in
            if error != nil {
                print("Failed to play: \(error.debugDescription)")
            }
        }
    }
    
    // MARK: - Play/Pause
    
    public func handePlayPause() {
        guard let playbackState = audioStreamingController.playbackState else { return }
        audioStreamingController.setIsPlaying(!playbackState.isPlaying, callback: nil)
    }
    
    // MARK: Next/Previous
    
    public func goToNext() {
        audioStreamingController.skipNext(nil)
    }
    
    public func handlePrevious() {
        guard let playbackState = audioStreamingController.playbackState else { return }
        if playbackState.position <= 3.0 {
            audioStreamingController.skipPrevious(nil)
        } else {
            audioStreamingController.seek(to: 0.0, callback: nil)
        }
    }
    
    // MARK: Seek With Slider
    
    public func startSeekingWithSlider() {
        isSeeking = true
    }
    
    public func seekWithSlider(sliderValue: Float) {
        guard let currentTrack = audioStreamingController.metadata?.currentTrack else { return }
        let currentPosition = currentTrack.duration * TimeInterval(sliderValue)
        let trackPosition = TrackPosition(currentPosition: currentPosition, totalDuration: currentTrack.duration)
        NotificationCenter.default.post(name: .trackPositionUpdate, object: trackPosition)
    }
    
    public func finishedSeekingWithSlider(sliderValue: Float) {
        isSeeking = false
        guard let currentTrack = audioStreamingController.metadata?.currentTrack else { return }
        let destination = currentTrack.duration * Double(sliderValue)
        audioStreamingController.seek(to: destination, callback: nil)
    }
    
    // MARK: - Shuffle
    
    public func handleShuffle() {
        guard let playbackState = audioStreamingController.playbackState else { return }
        audioStreamingController.setShuffle(!playbackState.isShuffling, callback: nil)
    }
    
    // MARK: - Spotify Audio Session
    
    func startSession() {
        do {
            try audioStreamingController.start(withClientId: auth.clientID, audioController: nil, allowCaching: true)
            audioStreamingController.delegate = self
            audioStreamingController.playbackDelegate = self
            audioStreamingController.diskCache = SPTDiskCache()
            if let accessToken = auth.session?.accessToken {
                authenticateSession(accessToken: accessToken)
            }
        } catch let error {
            print("Error starting spotify session: \(error.localizedDescription)")
            closeSession()
        }
    }
    
    func closeSession() {
        audioStreamingController.logout()
    }
    
    func authenticateSession(accessToken: String) {
        audioStreamingController.login(withAccessToken: accessToken)
    }
}

// MARK: - SPTAudioStreamingPlaybackDelegate

extension SpotifyMusicPlayer: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        guard let currentTrack = metadata.currentTrack else { return }
        configureControlCenter(for: currentTrack)
        NotificationCenter.default.post(name: .trackChanged, object: currentTrack)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
        NotificationCenter.default.post(name: .trackIsShufflingChanged, object: enabled)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        NotificationCenter.default.post(name: .trackIsPlayingChanged, object: isPlaying)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard !isSeeking, let currentTrack = audioStreamingController.metadata?.currentTrack else { return }
        let trackPosition = TrackPosition(currentPosition: position, totalDuration: currentTrack.duration)
        NotificationCenter.default.post(name: .trackPositionUpdate, object: trackPosition)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error.debugDescription)")
    }
}

// MARK: - SPTAudioStreamingDelegate

extension SpotifyMusicPlayer: SPTAudioStreamingDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        print("Message from Spotify: \(message)")
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        playSpotifyURI(uri: "spotify:user:1216066679:playlist:7d7fTjXToSTR5Spv6yT6Ws")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        do {
            try audioStreamingController.stop()
        } catch let error {
            print("Error stopping: \(error.localizedDescription)")
        }
        auth.session = nil
    }
}

// MARK: - Command Center

extension SpotifyMusicPlayer {
    func setupControlCenterCallbacks() {
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = true
        remoteCommandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.audioStreamingController.seek(to: positionEvent.positionTime, callback: nil)
            }
            return .success
        }
        remoteCommandCenter.playCommand.addTarget { [weak self] event in
            self?.audioStreamingController.setIsPlaying(true, callback: nil)
            return .success
        }
        remoteCommandCenter.pauseCommand.addTarget { [weak self] event in
            self?.audioStreamingController.setIsPlaying(false, callback: nil)
            return .success
        }
        remoteCommandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.handlePrevious()
            return .success
        }
        remoteCommandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.goToNext()
            return .success
        }
    }
    
    func configureControlCenter(for currentTrack: SPTPlaybackTrack) {
        var nowPlayingInfo: [String: Any] = [MPMediaItemPropertyTitle : currentTrack.name,
                                             MPMediaItemPropertyArtist : currentTrack.artistName,
                                             MPMediaItemPropertyAlbumTitle : currentTrack.albumName,
                                             MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: audioStreamingController.playbackState.position),
                                             MPMediaItemPropertyPlaybackDuration : NSNumber(value: currentTrack.duration),
                                             MPNowPlayingInfoPropertyPlaybackRate : NSNumber(value: audioStreamingController.playbackState.isPlaying ? 1.0 : 0.0)]
        
        guard let albumCoverURL = currentTrack.albumCoverURL else {
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            return
        }
        albumCoverURL.loadImage { [weak self] image in
            if let image = image {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200.0, height: 200.0)) { size in
                    return image
                }
            }
            self?.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
}
