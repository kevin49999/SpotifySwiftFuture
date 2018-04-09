//
//  WebViewController.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 4/6/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    // MARK: - Variables
    
    var loadComplete: Bool = false
    public var initialURL: URL!
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialRequest = URLRequest(url: self.initialURL)
        webView.loadRequest(initialRequest)
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedDone(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //
    }
}
