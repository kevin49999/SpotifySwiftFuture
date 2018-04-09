//
//  PlayerViewController.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/7/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    // MARK: - Variables
    
    private var spotifyMusicPlayer: SpotifyMusicPlayer = SpotifyMusicPlayer()
    @IBOutlet weak private var albumImageView: UIImageView!
    @IBOutlet weak private var songLabel: UILabel!
    @IBOutlet weak private var artistLabel: UILabel!
    @IBOutlet weak private var playbackSlider: UISlider!
    @IBOutlet weak private var playPauseButton: UIButton!
    @IBOutlet weak private var currentTimeLabel: UILabel!
    @IBOutlet weak private var endTimeLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentTrackChangedNotification(notification:)), name: NSNotification.Name.init("TrackChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentTrackPlaybackStatusChanged(notification:)), name: NSNotification.Name.init("TrackPlaybackChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentTrackPositionChanged(notification:)), name: NSNotification.Name.init("TrackPositionUpdate"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Notifications
    
    @objc func currentTrackChangedNotification(notification: NSNotification) {
        if let track = notification.object as? SPTPlaybackTrack {
            currentTrackChanged(track: track)
        }
    }
    
    @objc func currentTrackPlaybackStatusChanged(notification: NSNotification) {
        if let isPlaying = notification.object as? Bool {
            currentTrackDidChangePlaybackStatus(isPlaying: isPlaying)
        }
    }
    
    @objc func currentTrackPositionChanged(notification: NSNotification) {
        if let trackPosition = notification.object as? TrackPosition {
            currentTrackPositionUpdated(position: trackPosition.position, totalDuration: trackPosition.totalDuration)
        }
    }
    
    // MARK: - Update Current Track
    
    private func currentTrackChanged(track: SPTPlaybackTrack) {
        songLabel.text = track.name
        artistLabel.text = track.artistName
        endTimeLabel.text = track.duration.seconds()
        if let albumCoverURLString = track.albumCoverArtURL, let albumCoverURL = URL.init(string: albumCoverURLString) {
            setAlbumCoverWithURL(url: albumCoverURL)
        }
    }
    
    private func setAlbumCoverWithURL(url: URL) {
        DispatchQueue.global().async {
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
    
    private func currentTrackPositionUpdated(position: TimeInterval, totalDuration: TimeInterval) {
        currentTimeLabel.text = position.seconds()
        endTimeLabel.text = (totalDuration - position).seconds()
        let value = Float(position / totalDuration)
        playbackSlider.value = value
    }
    
    private func currentTrackDidChangePlaybackStatus(isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setTitle("Pause", for: .normal)
            spotifyMusicPlayer.activateAudioSession()
        } else {
            playPauseButton.setTitle("Play", for: .normal)
            spotifyMusicPlayer.deactivateAudioSession()
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
        spotifyMusicPlayer.goToPrevious()
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
}

// MARK: - Storyboard Identifier

extension PlayerViewController {
    class func identifier()-> String {
        return "PlayerViewControllerIdentifier"
    }
}

// MARK: - Seconds Extension

extension Double {
    func seconds() -> String {
        let secondsInt = Int(self.rounded())
        let minutes = secondsInt / 60
        let seconds = secondsInt % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    func createDateWithAPITimestamp() -> Date? {
        return Date.init(timeIntervalSince1970: self)
    }
}

