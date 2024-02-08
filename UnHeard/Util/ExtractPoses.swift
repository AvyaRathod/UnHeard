//
//  ExtractPoses.swift
//  UnHeard
//
//  Created by Avya Rathod on 02/02/24.
//

import Foundation
import Vision
import UIKit

struct FramePoseData{
    let frameNumber: Int
    var bodyPoses: [VNHumanBodyPoseObservation] = []
    var handPoses: [VNHumanHandPoseObservation] = []
    var faceLandmarks: [VNFaceObservation] = []
}

class PoseExtractor {
    var bodyPoses: [VNHumanBodyPoseObservation] = []
    var handPoses: [VNHumanHandPoseObservation] = []
    var faceLandmarks: [VNFaceObservation] = []
    
    func extractPoses(from images: [UIImage], completion: @escaping () -> Void) {
        print("extracting Poses")
        
        for image in images {
            guard let cgImage = image.cgImage else { continue }
            
            // Process each image sequentially
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
            let handPoseRequest = VNDetectHumanHandPoseRequest()
            handPoseRequest.maximumHandCount = 2
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
            
            do {
                try handler.perform([bodyPoseRequest, handPoseRequest, faceLandmarksRequest])
                
                if let bodyObservations = bodyPoseRequest.results as? [VNHumanBodyPoseObservation] {
                    bodyPoses.append(contentsOf: bodyObservations)
                }
                
                if let handObservations = handPoseRequest.results as? [VNHumanHandPoseObservation] {
                    handPoses.append(contentsOf: handObservations)
                }
                
                if let faceObservations = faceLandmarksRequest.results as? [VNFaceObservation] {
                    faceLandmarks.append(contentsOf: faceObservations)
                }
            } catch {
                print("Error performing vision request: \(error)")
            }
        }
        
        // Completion handler is called after all images have been processed
        completion()
    }
    
    func extractAndLogPoses(from images: [UIImage], completion: @escaping ([FramePoseData]) -> Void) {
        var framePoseDataArray: [FramePoseData] = []
        
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            guard let cgImage = image.cgImage else {
                dispatchGroup.leave()
                continue
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
            let handPoseRequest = VNDetectHumanHandPoseRequest()
            handPoseRequest.maximumHandCount = 2
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
            
            do {
                try handler.perform([bodyPoseRequest, handPoseRequest, faceLandmarksRequest])
                
                // Convert observations to your Codable structs here
                if let bodyObservations = bodyPoseRequest.results as? [VNHumanBodyPoseObservation] {
                    bodyPoses.append(contentsOf: bodyObservations)
                }
                
                if let handObservations = handPoseRequest.results as? [VNHumanHandPoseObservation] {
                    handPoses.append(contentsOf: handObservations)
                }
                
                if let faceObservations = faceLandmarksRequest.results as? [VNFaceObservation] {
                    faceLandmarks.append(contentsOf: faceObservations)
                }
                
                let framePoseData = FramePoseData(frameNumber: index + 1, bodyPoses: bodyPoses, handPoses: handPoses, faceLandmarks: faceLandmarks)
                framePoseDataArray.append(framePoseData)
                
                dispatchGroup.leave()
            } catch {
                print("Error performing vision request: \(error)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(framePoseDataArray.sorted(by: { $0.frameNumber < $1.frameNumber }))
        }
    }
}
