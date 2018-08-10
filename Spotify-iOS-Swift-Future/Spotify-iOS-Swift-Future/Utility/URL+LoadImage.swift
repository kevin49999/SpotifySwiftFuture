//
//  URL+LoadImage.swift
//  Spotify-iOS-Swift-Future
//
//  Created by Kevin Johnson on 8/10/18.
//  Copyright © 2018 FFR. All rights reserved.
//

import UIKit

extension URL {
    func loadImage(_ completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData = try Data(contentsOf: self, options: [])
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    completion(image)
                }
            } catch let error {
                print("Error loading image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
