//
//  SpotifyMusicPlayer.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import AVFoundation

typealias TrackPosition = (position: TimeInterval, totalDuration: TimeInterval)

class SpotifyMusicPlayer: NSObject {
    
    // MARK: - Variables
    
    private var isChangingProgress: Bool = false
    
    // MARK: - Init
    
    override init() {
        super.init()
        if !SPTAudioStreamingController.sharedInstance().initialized {
            handleNewSpotifySession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playSpotifyURI(uri: "spotify:user:1216066679:playlist:7d7fTjXToSTR5Spv6yT6Ws")
                SPTAudioStreamingController.sharedInstance().setIsPlaying(true, callback: nil)
            }
        }
    }
    
    // MARK: - Play Spotify URI
    
    private func playSpotifyURI(uri: String) {
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { error in
            if error != nil {
                print("Failed to play: \(error.debugDescription)")
            }
        }
    }
    
    // MARK: - Play/Pause
    
    public func handePlayPause() {
        guard let playbackStatus = SPTAudioStreamingController.sharedInstance().playbackState else { return }
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!playbackStatus.isPlaying, callback: nil)
    }
    
    // MARK: Next/Previous
    
    public func goToPrevious() {
        SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
    }
    
    public func goToNext() {
        SPTAudioStreamingController.sharedInstance().skipNext(nil)
    }
    
    // MARK: Seek With Slider
    
    public func startSeekingWithSlider() {
        isChangingProgress = true
    }
    
    public func seekWithSlider(sliderValue: Float) {
        guard let currentTrack = SPTAudioStreamingController.sharedInstance().metadata?.currentTrack else { return }
        let position = currentTrack.duration * Double(sliderValue)
        let trackPosition = TrackPosition(position, currentTrack.duration)
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackPositionUpdate"), object: trackPosition)
    }
    
    public func finishedSeekingWithSlider(sliderValue: Float) {
        isChangingProgress = false
        guard let currentTrack = SPTAudioStreamingController.sharedInstance().metadata?.currentTrack else { return }
        let destination = currentTrack.duration * Double(sliderValue)
        SPTAudioStreamingController.sharedInstance().seek(to: destination, callback: nil)
    }
    
    // MARK: - Spotify Audio Session
    
    private func handleNewSpotifySession() {
        do {
            guard let accessToken = SPTAuth.defaultInstance().session.accessToken else { return }
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            SPTAudioStreamingController.sharedInstance().delegate = self
            SPTAudioStreamingController.sharedInstance().playbackDelegate = self
            SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache()
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: accessToken)
        } catch let error {
            print("Error starting spotify session: \(error.localizedDescription)")
            closeSpotifySession()
        }
    }
    
    private func closeSpotifySession() {
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
            SPTAuth.defaultInstance().session = nil
        } catch let error {
            print("Error closing spotify session: \(error.localizedDescription)")
        }
    }
}

// MARK: - SPTAudioStreamingPlaybackDelegate

extension SpotifyMusicPlayer: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        guard let currentTrack = metadata.currentTrack else { return }
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackChanged"), object: currentTrack)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackPlaybackChanged"), object: isPlaying)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard !isChangingProgress, let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack else { return }
        let trackPosition = TrackPosition(position, currentTrack.duration)
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackPositionUpdate"), object: trackPosition)
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
}

// MARK: - Audio Session

extension SpotifyMusicPlayer {
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

