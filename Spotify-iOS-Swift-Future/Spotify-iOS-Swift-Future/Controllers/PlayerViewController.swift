//
//  PlayerViewController.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    // MARK: - Properties
    
    static let identifier: String = "PlayerViewControllerIdentifier"
    private var spotifyMusicPlayer: SpotifyMusicPlayer = SpotifyMusicPlayer()
    @IBOutlet weak private var albumImageView: UIImageView!
    @IBOutlet weak private var songLabel: UILabel!
    @IBOutlet weak private var artistLabel: UILabel!
    @IBOutlet weak private var playbackSlider: UISlider!
    @IBOutlet weak private var playPauseButton: UIButton!
    @IBOutlet weak private var currentTimeLabel: UILabel!
    @IBOutlet weak private var endTimeLabel: UILabel!
    @IBOutlet weak private var shuffleButton: UIButton!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        registerForNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Update Current Track
    
    private func currentTrackChanged(track: SPTPlaybackTrack) {
        songLabel.text = track.name
        artistLabel.text = track.artistName
        endTimeLabel.text = track.duration.minutesSeconds()
        if let albumCoverURLString = track.albumCoverArtURL, let albumCoverURL = URL(string: albumCoverURLString) {
            setAlbumCoverWithURL(url: albumCoverURL)
        }
    }
    
    private func setAlbumCoverWithURL(url: URL) {
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData = try Data(contentsOf: url, options: [])
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.albumImageView.image = image
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func currentTrackPositionUpdated(trackPosition: TrackPosition) {
        currentTimeLabel.text = trackPosition.currentTime
        endTimeLabel.text = trackPosition.remainingTime
        playbackSlider.value = trackPosition.currentValue
    }
    
    private func currentTrackDidChangePlaying(isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setTitle("Pause", for: .normal)
            AVAudioSession.activateAudioSession()
        } else {
            playPauseButton.setTitle("Play", for: .normal)
            AVAudioSession.deactivateAudioSession()
        }
    }
    
    private func currentTrackDidChangeShuffling(isShuffling: Bool) {
        if isShuffling {
            shuffleButton.titleLabel?.textColor = #colorLiteral(red: 0.6509803922, green: 1, blue: 0.5960784314, alpha: 1)
        } else {
            shuffleButton.titleLabel?.textColor = .darkGray
        }
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: .trackChanged, type: SPTPlaybackTrack.self) { [weak self] track, _ in
            self?.currentTrackChanged(track: track)
        }
        NotificationCenter.default.addObserver(forName: .trackIsPlayingChanged, type: Bool.self) { [weak self] isPlaying, _ in
            self?.currentTrackDidChangePlaying(isPlaying: isPlaying)
        }
        NotificationCenter.default.addObserver(forName: .trackIsShufflingChanged, type: Bool.self) { [weak self] isShuffling, _ in
            self?.currentTrackDidChangeShuffling(isShuffling: isShuffling)
        }
        NotificationCenter.default.addObserver(forName: .trackPositionUpdate, type: TrackPosition.self) { [weak self] trackPosition, _ in
            self?.currentTrackPositionUpdated(trackPosition: trackPosition)
        }
    }

    // MARK: - IBAction
    
    @IBAction func tapPlayPause(_ sender: UIButton) {
        spotifyMusicPlayer.handePlayPause()
    }
    
    @IBAction func tapNext(_ sender: UIButton) {
        spotifyMusicPlayer.goToNext()
    }
    
    @IBAction func tapPrevious(_ sender: UIButton) {
        spotifyMusicPlayer.handlePrevious()
    }
    
    @IBAction func trackingSliderTouchDown(_ sender: UISlider) {
        spotifyMusicPlayer.startSeekingWithSlider()
    }
    
    @IBAction func trackingSliderValueChanged(_ sender: UISlider) {
        spotifyMusicPlayer.seekWithSlider(sliderValue: sender.value)
    }
    
    @IBAction func trackingSliderTouchInside(_ sender: UISlider) {
        spotifyMusicPlayer.finishedSeekingWithSlider(sliderValue: sender.value)
    }
    
    @IBAction func tapShuffle(_ sender: UIButton) {
        spotifyMusicPlayer.handleShuffle()
    }
}
