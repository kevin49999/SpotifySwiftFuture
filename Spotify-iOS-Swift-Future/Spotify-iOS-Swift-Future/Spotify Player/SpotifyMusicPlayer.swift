//
//  SpotifyMusicPlayer.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

class SpotifyMusicPlayer: NSObject {
    
    // MARK: - Variables
    
    private var audioStreamingController: SPTAudioStreamingController?
    private var isSeeking: Bool = false
    
    // MARK: - Init
    
    override init() {
        super.init()
        if let accessToken = SPTAuth.defaultInstance().session?.accessToken {
            handleNewSpotifySession(accessToken: accessToken)
        } else {
            closeSpotifySession()
        }
    }
    
    // MARK: - Play Spotify URI
    
    private func playSpotifyURI(uri: String) {
        audioStreamingController?.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0) { error in
            if error != nil {
                print("Failed to play: \(error.debugDescription)")
            }
        }
    }
    
    // MARK: - Play/Pause
    
    public func handePlayPause() {
        guard let playbackState = audioStreamingController?.playbackState else { return }
        audioStreamingController?.setIsPlaying(!playbackState.isPlaying, callback: nil)
    }
    
    // MARK: Next/Previous
    
    public func handlePrevious() {
        guard let playbackState = audioStreamingController?.playbackState else { return }
        if playbackState.position <= 3.0 {
            audioStreamingController?.skipPrevious(nil)
        } else {
            audioStreamingController?.seek(to: 0.0, callback: nil)
        }
    }
    
    public func goToNext() {
        audioStreamingController?.skipNext(nil)
    }
    
    // MARK: Seek With Slider
    
    public func startSeekingWithSlider() {
        isSeeking = true
    }
    
    public func seekWithSlider(sliderValue: Float) {
        guard let currentTrack = audioStreamingController?.metadata?.currentTrack else { return }
        let currentPosition = currentTrack.duration * Double(sliderValue)
        let trackPosition = TrackPosition(currentPosition: currentPosition, totalDuration: currentTrack.duration)
        NotificationCenter.default.post(name: .trackPositionUpdate, object: trackPosition)
    }
    
    public func finishedSeekingWithSlider(sliderValue: Float) {
        isSeeking = false
        guard let currentTrack = audioStreamingController?.metadata?.currentTrack else { return }
        let destination = currentTrack.duration * Double(sliderValue)
        audioStreamingController?.seek(to: destination, callback: nil)
    }
    
    // MARK: - Shuffle
    
    public func handleShuffle() {
        guard let playbackState = audioStreamingController?.playbackState else { return }
        audioStreamingController?.setShuffle(!playbackState.isShuffling, callback: nil)
    }
    
    // MARK: - Spotify Audio Session
    
    public func handleNewSpotifySession(accessToken: String) {
        if self.audioStreamingController == nil {
            self.audioStreamingController = SPTAudioStreamingController.sharedInstance()
            do {
                try audioStreamingController?.start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
                audioStreamingController?.delegate = self
                audioStreamingController?.playbackDelegate = self
                audioStreamingController?.diskCache = SPTDiskCache()
                audioStreamingController?.login(withAccessToken: accessToken)
            } catch let error {
                self.audioStreamingController = nil
                print("Error starting spotify session: \(error.localizedDescription)")
                closeSpotifySession()
            }
        }
    }
    
    private func closeSpotifySession() {
        do {
            try audioStreamingController?.stop()
        } catch let error {
            print("Error closing spotify session: \(error.localizedDescription)")
        }
        SPTAuth.defaultInstance().session = nil
    }
}

// MARK: - SPTAudioStreamingPlaybackDelegate

extension SpotifyMusicPlayer: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        guard let currentTrack = metadata.currentTrack else { return }
        NotificationCenter.default.post(name: .trackChanged, object: currentTrack)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
        NotificationCenter.default.post(name: .trackIsShufflingChanged, object: enabled)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        NotificationCenter.default.post(name: .trackIsPlayingChanged, object: isPlaying)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard !isSeeking, let currentTrack = audioStreamingController?.metadata?.currentTrack else { return }
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
}
