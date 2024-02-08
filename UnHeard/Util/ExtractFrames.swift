//
//  ExtractFrames.swift
//  UnHeard
//
//  Created by Avya Rathod on 01/02/24.
//

import AVFoundation
import UIKit

class VideoFrameExtractor: ObservableObject {
    @Published var frames: [UIImage] = []
    
    func extractFrames(from url: URL, interval: TimeInterval, completion: @escaping ([UIImage]) -> Void) {
        print("Starting to extract frames from \(url.lastPathComponent)")
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        assetImgGenerate.requestedTimeToleranceAfter = CMTime(seconds: 0.02, preferredTimescale: 600)
        assetImgGenerate.requestedTimeToleranceBefore = CMTime(seconds: 0.02, preferredTimescale: 600)
        
        // Ensure the asset's duration is loaded before proceeding
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            if status == .loaded {
                let durationSeconds = CMTimeGetSeconds(asset.duration)
                self.processFrames(asset: asset, assetImgGenerate: assetImgGenerate, duration: durationSeconds, interval: interval, completion: completion)
            } else {
                print("Error loading asset duration for \(url.lastPathComponent): \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    private func processFrames(asset: AVAsset, assetImgGenerate: AVAssetImageGenerator, duration: TimeInterval, interval: TimeInterval, completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let concurrencyLimit = 5
            let semaphore = DispatchSemaphore(value: concurrencyLimit)
            
            var times: [NSValue] = []
            var currentTime = 0.0
            
            while currentTime <= duration {
                let cmTime = CMTime(seconds: min(currentTime, duration), preferredTimescale: 600)
                times.append(NSValue(time: cmTime))
                currentTime += interval
            }
            
            var uiImages: [UIImage] = []
            
            // A group to track when all async tasks are complete
            let group = DispatchGroup()
            
            for time in times {
                semaphore.wait() // Wait for a "slot" to be available
                group.enter() // Enter the group for each task
                
                assetImgGenerate.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, error in
                    DispatchQueue.main.async {
                        if let cgImage = image {
                            uiImages.append(UIImage(cgImage: cgImage))
                        } else {
                            print("Error generating image at time \(time.timeValue.seconds): \(String(describing: error))")
                        }
                        semaphore.signal() // Signal that the "slot" is now free
                        group.leave() // Leave the group when task is complete
                    }
                }
            }
            
            // Wait for all tasks in the group to complete
            group.notify(queue: .main) {
                completion(uiImages)
            }
        }
    }
}
