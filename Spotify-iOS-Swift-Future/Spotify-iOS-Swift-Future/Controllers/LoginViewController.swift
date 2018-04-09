//
//  LoginViewController.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/6/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Variables
    
    private weak var spotifyAuthViewController: UINavigationController?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.spotifySessionUpdatedNotification), name: NSNotification.Name(rawValue: "SpotifySessionUpdated"), object: nil)
    }
    
    
    // MARK: - Spotify Authentication Process
    
    private func openSpotifyLoginPage() {
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(SPTAuth.defaultInstance().spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
        } else {
            spotifyAuthViewController = getSpotifyAuthViewController(withURL: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
            present(spotifyAuthViewController!, animated: true, completion: nil)
        }
    }
    
    private func getSpotifyAuthViewController(withURL url: URL) -> UINavigationController! {
        let webView = storyboard?.instantiateViewController(withIdentifier: "WebViewControllerIdentifier") as! WebViewController
        webView.initialURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        let navigationController = UINavigationController(rootViewController: webView)
        return navigationController
    }
    
    // MARK: - Notification
    
    @objc func spotifySessionUpdatedNotification(_ notification: Notification) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        if SPTAuth.defaultInstance().session != nil && SPTAuth.defaultInstance().session.isValid() {
            transitionToPlayerViewController()
        } else {
            print("Failed to login with Spotify")
        }
    }
    
    private func transitionToPlayerViewController() {
        let playerViewController = storyboard?.instantiateViewController(withIdentifier: PlayerViewController.identifier()) as! PlayerViewController
        navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func tapSpotifyConnect(_ sender: SPTConnectButton) {
        openSpotifyLoginPage()
    }
}

