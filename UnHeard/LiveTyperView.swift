//
//  LiveTyperView.swift
//  UnHeard
//
//  Created by Avya Rathod on 06/02/24.
//

import SwiftUI

struct LiveTyperView: View {
    @StateObject private var recognizedTextViewModel = RecognizedTextViewModel()
    @State private var isProcessing: Bool = true
    @State private var isFrontCamera: Bool = false
    
    var body: some View {
        ZStack {
            // The live camera feed
            LiveStreamView(isUsingFrontCamera: $isFrontCamera, recognizedTextViewModel: recognizedTextViewModel)
            
            // Bottom overlay container
            
            VStack {
                Spacer()
                // Display the recognized text
                Text(recognizedTextViewModel.recognizedText)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                VStack(spacing: 2) {
                    // Top row with camera switch and start/stop button
                    HStack {
                        // Camera switch button
                        Button(action: {
                            isFrontCamera.toggle()
                            // Action to switch camera
                        }) {
                            Image(systemName: "camera.rotate")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .padding()
                                .foregroundColor(.white)
                            
                        }
                        
                        Spacer()
                        
                        // Start/stop button
                        Button(action: {
                            isProcessing.toggle()
                        }) {
                            Image(systemName: isProcessing ? "stop.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isProcessing ? .red : .green)
                                .padding(20)
                        }
                    }
                    .padding(.horizontal, 10.0)
                    .padding(.top,8.0)
                    
                    Text(recognizedTextViewModel.typedText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                        .padding()
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.5))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Start processing or setup your model
        }
    }
}

struct LiveTyperView_Previews: PreviewProvider {
    static var previews: some View {
        LiveTyperView()
    }
}
