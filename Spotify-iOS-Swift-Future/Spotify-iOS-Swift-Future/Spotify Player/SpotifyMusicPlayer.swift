//
//  SpotifyMusicPlayer.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

class SpotifyMusicPlayer: NSObject {
    
    // MARK: - Variables
    
    private var isChangingProgress: Bool = false
    
    // MARK: - Init
    
    override init() {
        super.init()
        if !SPTAudioStreamingController.sharedInstance().initialized {
            handleNewSpotifySession()
        }
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
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
        guard let playbackState = SPTAudioStreamingController.sharedInstance().playbackState else { return }
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!playbackState.isPlaying, callback: nil)
    }
    
    // MARK: Next/Previous
    
    public func handlePrevious() {
        guard let playbackState = SPTAudioStreamingController.sharedInstance().playbackState else { return }
        if playbackState.position <= 3.0 {
            SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
        } else {
            SPTAudioStreamingController.sharedInstance().seek(to: 0.0, callback: nil)
        }
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
        let currentPosition = currentTrack.duration * Double(sliderValue)
        let trackPosition = TrackPosition(currentPosition: currentPosition, totalDuration: currentTrack.duration)
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackPositionUpdate"), object: trackPosition)
    }
    
    public func finishedSeekingWithSlider(sliderValue: Float) {
        isChangingProgress = false
        guard let currentTrack = SPTAudioStreamingController.sharedInstance().metadata?.currentTrack else { return }
        let destination = currentTrack.duration * Double(sliderValue)
        SPTAudioStreamingController.sharedInstance().seek(to: destination, callback: nil)
    }
    
    // MARK: - Shuffle
    
    public func handleShuffle() {
        guard let playbackState = SPTAudioStreamingController.sharedInstance().playbackState else { return }
        SPTAudioStreamingController.sharedInstance().setShuffle(!playbackState.isShuffling, callback: nil)
    }
    
    // MARK: - Spotify Audio Session
    
    private func handleNewSpotifySession() {
        guard let accessToken = SPTAuth.defaultInstance().session?.accessToken else { return }
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
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
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackIsShufflingChanged"), object: enabled)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.init("TrackIsPlayingChanged"), object: isPlaying)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard !isChangingProgress, let currentTrack = SPTAudioStreamingController.sharedInstance().metadata?.currentTrack else { return }
        let trackPosition = TrackPosition(currentPosition: position, totalDuration: currentTrack.duration)
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
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        playSpotifyURI(uri: "spotify:user:1216066679:playlist:7d7fTjXToSTR5Spv6yT6Ws")
    }
}
