//
//  LiveStreamView.swift
//  UnHeard
//
//  Created by Avya Rathod on 05/02/24.
//

import UIKit
import SwiftUI
import AVFoundation
import CoreVideo
import Vision
import CoreML

struct LiveStreamView: View {
    @Binding var isUsingFrontCamera: Bool
    var recognizedTextViewModel: RecognizedTextViewModel  // Add this line
    
    var body: some View {
        HostedViewController(isUsingFrontCamera: $isUsingFrontCamera, recognizedTextViewModel: recognizedTextViewModel)  // Update this line
            .edgesIgnoringSafeArea(.all)
    }
}


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var lastFrameProcessTime: Date?
    
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
        
    private var handPoseRequest: VNDetectHumanHandPoseRequest!
    private var predictionModel: VNCoreMLModel!
    private var predictionRequest: VNCoreMLRequest!
    
    var recognizedTextViewModel: RecognizedTextViewModel?

    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
                guard permissionGranted else { return }
                self.setupCaptureSession()
                self.setupCoreMLModel() // Initialize the ML model
                self.captureSession.startRunning()
            }
        }

        private func setupCoreMLModel() {
            do {
                predictionModel = try VNCoreMLModel(for: AlphabetsImageClassifier().model)
                predictionRequest = VNCoreMLRequest(model: predictionModel, completionHandler: handlePrediction)
                predictionRequest.imageCropAndScaleOption = .scaleFill
            } catch {
                fatalError("Failed to load Core ML model: \(error)")
            }
        }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
            // Home button on top
            case UIDeviceOrientation.portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
             
            // Home button on right
            case UIDeviceOrientation.landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight
            
            // Home button on left
            case UIDeviceOrientation.landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft
             
            // Home button at bottom
            case UIDeviceOrientation.portrait:
                self.previewLayer.connection?.videoOrientation = .portrait
                
            default:
                break
            }
    }
    
    var isUsingFrontCamera = false

    func switchCamera() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }

        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)

        let newCameraDevice = isUsingFrontCamera ? getCamera(with: .back) : getCamera(with: .front)
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice) else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(newVideoInput) {
            captureSession.addInput(newVideoInput)
            isUsingFrontCamera.toggle()
        } else {
            captureSession.addInput(currentInput) // Re-add the old input if the new one fails
        }

        captureSession.commitConfiguration()
    }

    func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        guard let device = devices.first else {
            fatalError("No cameras available.")
        }
        return device
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
            case .authorized:
                permissionGranted = true
                
            // Permission has not been requested yet
            case .notDetermined:
                requestPermission()
                    
            default:
                permissionGranted = false
            }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
    
    // MARK: - MLModels
    
    
    private func handlePrediction(request: VNRequest, error: Error?) {
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            // Assuming you want the top result
            if let topResult = results.first {
                let predictedText = topResult.identifier // The recognized text from the model
                let confidence = topResult.confidence
                
                // Update the recognized text ViewModel
                recognizedTextViewModel?.updateRecognizedText(newText: predictedText)
                
                // If you want to include confidence in the UI update, modify the ViewModel's method to accept it
                // For simplicity, this example only passes the predicted text
            }
        }


    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Perform hand detection and cropping on a background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.processFrame(sampleBuffer: sampleBuffer)
            }
        }

    func processFrame(sampleBuffer: CMSampleBuffer) {
        // Make sure we have a valid pixel buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Create a Vision handler and perform the hand pose request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        
        do {
            try handler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results, !observations.isEmpty else {
                return  // No hands were detected
            }
            
            // Crop hands from the pixel buffer
            if let croppedBuffer = cropHands(from: pixelBuffer, using: observations) {
                // Create and perform a Core ML request with the cropped image
                let requestHandler = VNImageRequestHandler(cvPixelBuffer: croppedBuffer, options: [:])
                try requestHandler.perform([predictionRequest])
            }
        } catch {
            print("Error performing hand pose request: \(error)")
        }
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    @Binding var isUsingFrontCamera: Bool
    var recognizedTextViewModel: RecognizedTextViewModel

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.isUsingFrontCamera = isUsingFrontCamera
        viewController.recognizedTextViewModel = recognizedTextViewModel
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.isUsingFrontCamera = isUsingFrontCamera
    }
}

