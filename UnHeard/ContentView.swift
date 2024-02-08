import SwiftUI
import Vision

extension PoseExtractor {
    func logPoses(from images: [UIImage]) {
        extractPoses(from: images) {
            // Assuming bodyPoses, handPoses, and faceLandmarks are populated at this point.
            for bodyPose in self.bodyPoses {
                do {
                    // Example: Log the nose point of the body pose if available.
                    let nosePoint = try bodyPose.recognizedPoint(.nose)
                    print("Nose: \(nosePoint.location)")
                } catch {
                    print("Error extracting nose point: \(error)")
                }
            }
            // Similarly log for hand poses and face landmarks if required.
        }
    }
}


struct ContentView: View {
    @State private var images: [UIImage] = [] // Assume this gets populated appropriately.
    private var poseExtractor = PoseExtractor() // No need for @State here as we don't need UI updates based on this.
    
    var body: some View {
        NavigationView {
            Text("Check console for pose data")
                .navigationBarTitle("Pose Data Logger", displayMode: .inline)
                .onAppear {
                    // Example usage - you would replace with actual images loading logic
                    // This assumes `images` is already populated with images to process.
                    poseExtractor.logPoses(from: self.images)
                }
        }
        .navigationBarTitle("Pose Preview", displayMode: .inline)
        .onAppear {
            self.images = DirectoryImageLoader().loadImagesForVideo(in: "Beautiful", video: "MVI_9569")
        }
    }
}

//    private func processAllVideos() {
//        // Assuming the directory structure "ISL_DATA" is in the main bundle, otherwise update this path
//        guard let videoDirectoryURL = Bundle.main.url(forResource: "ISL_DATA", withExtension: nil) else {
//            print("ISL_DATA directory not found in bundle.")
//            return
//        }
//
//        // Process videos and update UI upon completion
//        videoProcessor.processVideos(fromDirectory: videoDirectoryURL) {
//            // After processing is complete, load the names of the processed videos
//            self.loadProcessedVideos(fromDirectory: videoDirectoryURL)
//        }
//    }
//
//    private func loadProcessedVideos(fromDirectory directory: URL) {
//        do {
//            // Assuming that JSON files are saved in the same directory as the videos
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
//            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
//            self.processedVideoNames = jsonFiles.map { $0.lastPathComponent }
//        } catch {
//            print("Error loading processed video names: \(error)")
//        }
//    }
//}
