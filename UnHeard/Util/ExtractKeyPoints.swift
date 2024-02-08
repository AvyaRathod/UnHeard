////
////  ExtractKeyPoints.swift
////  UnHeard
////
////  Created by Avya Rathod on 03/02/24.
////
//
//import Foundation
//import Vision
//import UIKit
//
//// Define your structures to hold keypoints data
//struct PoseKeypoint: Codable {
//    let x: CGFloat
//    let y: CGFloat
//}
//
//struct PoseKeypoints: Codable {
//    var pose: [PoseKeypoint]
//    var leftHand: [PoseKeypoint]
//    var rightHand: [PoseKeypoint]
//    var face: [PoseKeypoint]
//}
//
//struct VideoPoseData: Codable {
//    var videoID: String
//    var className: String
//    var keypoints: [PoseKeypoints]
//}
//
//// This class will handle the extraction and saving of keypoints for all frames in a directory
//class PoseDataProcessor {
//    var poseExtractor = PoseExtractor()
//    
//    func processImagesAndExtractPoses(fromDirectory directory: URL, className: String, videoID: String, completion: @escaping (VideoPoseData) -> Void) {
//        let fileManager = FileManager.default
//        do {
//            let imageFiles = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
//            var allPoses: [PoseKeypoints] = []
//            
//            for imageFile in imageFiles where imageFile.pathExtension == "jpg" {
//                let imagePath = directory.appendingPathComponent(imageFile.lastPathComponent).path
//                if let image = UIImage(contentsOfFile: imagePath) {
//                    self.poseExtractor.extractPoses(from: image) { keypoints in
//                        allPoses.append(keypoints)
//                        
//                        // Check if this is the last image and call the completion handler
//                        if imageFile == imageFiles.last {
//                            let videoPoseData = VideoPoseData(videoID: videoID, className: className, keypoints: allPoses)
//                            completion(videoPoseData)
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("Error reading image files: \(error)")
//        }
//    }
//    
//    
//    // Function to save the keypoints data to a JSON file
//    func saveVideoPoseData(_ videoPoseData: VideoPoseData, toDirectory directory: URL) {
//        let className = videoPoseData.className
//        let videoID = videoPoseData.videoID // Declare this outside of the do-catch block
//        
//        do {
//            let data = try JSONEncoder().encode(videoPoseData)
//            let savePath = directory.appendingPathComponent("\(className)_\(videoID)_poses.json")
//            try data.write(to: savePath, options: .atomicWrite)
//            print("Saved pose data for \(videoID) at \(savePath)")
//        } catch {
//            // videoID is now available here as well
//            print("Failed to save pose data for \(videoID): \(error)")
//        }
//    }
//}
//
//// Usage example
////let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////let framesDirectory = documentsDirectory.appendingPathComponent("ISL_extract_frames", isDirectory: true)
////
////let processor = PoseDataProcessor()
////processor.processImagesAndExtractPoses(fromDirectory: framesDirectory) {
////    print("Finished processing all frames and pose data is saved.")
////}
