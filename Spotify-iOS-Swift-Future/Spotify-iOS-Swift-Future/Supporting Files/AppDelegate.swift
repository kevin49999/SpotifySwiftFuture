//
//  AppDelegate.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/8/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SPTAuth.defaultInstance().clientID = Secrets.Spotify.clientId
        SPTAuth.defaultInstance().redirectURL = URL(string: "com.onlyfuture://return") // Add to config on developer.spotify.com
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifySession"
        
        //SPTAuth.defaultInstance().tokenSwapURL = URL(string: "http://localhost:1234/swap")
        //SPTAuth.defaultInstance().tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        
        if SPTAuth.defaultInstance().session != nil && SPTAuth.defaultInstance().session.isValid() {
            let playerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PlayerViewController.identifier) as! PlayerViewController
            window?.rootViewController = playerViewController
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if SPTAuth.defaultInstance().canHandle(url) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { error, session in
                if error != nil {
                    print("Spotify auth error: \(error.debugDescription)")
                } else {
                    SPTAuth.defaultInstance().session = session
                }
                NotificationCenter.default.post(name: .spotifySessionUpdated, object: self)
            }
        }
        return false
    }
}
