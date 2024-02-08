//
//  imageLoader.swift
//  UnHeard
//
//  Created by Avya Rathod on 04/02/24.
//

import Foundation
import UIKit

class DirectoryImageLoader {
    let fileManager = FileManager.default

    func loadImagesForVideo(in label: String, video: String) -> [UIImage] {
        var images: [UIImage] = []
        guard let baseDirectory = Bundle.main.url(forResource: "ISL_data_frames", withExtension: nil) else {
            print("ISL_data_frames directory not found in the app bundle.")
            return images
        }
        let labelDirectoryURL = baseDirectory.appendingPathComponent(label, isDirectory: true)
        let videoDirectoryURL = labelDirectoryURL.appendingPathComponent(video, isDirectory: true)

        do {
            let imageFileURLs = try fileManager.contentsOfDirectory(at: videoDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Sort the files by their frame number
            let sortedImageFileURLs = imageFileURLs.sorted(by: { (url1, url2) -> Bool in
                // Extract frame numbers and compare
                let frameNumber1 = url1.deletingPathExtension().lastPathComponent.components(separatedBy: "_").last.flatMap { Int($0) } ?? 0
                let frameNumber2 = url2.deletingPathExtension().lastPathComponent.components(separatedBy: "_").last.flatMap { Int($0) } ?? 0
                return frameNumber1 < frameNumber2
            })
            
            for fileURL in sortedImageFileURLs where fileURL.pathExtension.lowercased() == "jpg" || fileURL.pathExtension.lowercased() == "png" {
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    images.append(image)
                }
            }
        } catch {
            print("Error while enumerating files in \(videoDirectoryURL.path): \(error.localizedDescription)")
        }

        return images
    }
}
