////
////  LiveVideoFeedView.swift
////  UnHeard
////
////  Created by Avya Rathod on 04/02/24.
////
//
//import SwiftUI
//import AVFoundation
//
//struct LiveVideoFeedView: UIViewControllerRepresentable {
//    var videoCapture: VideoCapture
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        guard let previewLayer = videoCapture.previewLayer else { return viewController }
//        previewLayer.frame = viewController.view.bounds
//        viewController.view.layer.addSublayer(previewLayer)
//        videoCapture.startRunning()
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // Here you might handle updating the UI or reacting to changes, such as device rotation.
//    }
//    
//    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
//        videoCapture.stopRunning()
//    }
//}
//
//class VideoCaptureWrapperView: View {
//    private var videoCapture = VideoCapture()
//    
//    var body: some View {
//        LiveVideoFeedView(videoCapture: videoCapture)
//            .onAppear {
//                videoCapture.setupSession()
//            }
//            .onDisappear {
//                videoCapture.stopRunning()
//            }
//            // Add any additional UI controls as needed, e.g., a button to switch cameras.
//    }
//}
//
//#Preview {
//    LiveVideoFeedView()
//}
