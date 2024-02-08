//
//  QuizView.swift
//  UnHeard
//
//  Created by Avya Rathod on 06/02/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var recognizedTextViewModel = RecognizedTextViewModel()
    
    @State private var score: Int = 500
    @State private var currentLetter: String = "A"
    @State private var timeRemaining: Int = 59
    @State private var recognizedSign: String = "A"
    @State private var confidence: Double = 0.0
    @State private var isFrontCamera: Bool = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    var body: some View {
        ZStack {
            // The live camera feed
            LiveStreamView(isUsingFrontCamera: $isFrontCamera, recognizedTextViewModel: recognizedTextViewModel)
            VStack {
                
                HStack{
                    Spacer()
                    Text("Score: \(score) pts")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
                
                // Prompt for current letter
                VStack{
                    Text("Make the sign for:")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding([.top, .leading, .trailing])
                    
                    Text(currentLetter)
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .padding([.leading, .bottom, .trailing])
                }
                .background(Color.black.opacity(0.5))
                .cornerRadius(25)
                .frame(minWidth: 0, maxWidth: .infinity)
                
                Spacer()
                
                // Timer and recognized text
                VStack {
                    Text("Time Left: \(timeRemaining)")
                        .onReceive(timer) { _ in
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            }
                        }
                    
                    HStack(spacing: 38.0) {
                        Image(systemName: "camera.rotate")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding()
                            .foregroundColor(.white)
                            .onTapGesture {
                                isFrontCamera.toggle()
                                // Action to switch camera
                            }
                        
                        VStack(alignment: .leading) {
                            Text("Recognized sign: \(recognizedSign)")
                                .font(.title2)
                            Text("confidence: \(Int(confidence * 100))%")
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .offset(y:35)
            }
        }
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear {
            generateRandomLetter()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                generateRandomLetter()
                timeRemaining = 59 // Reset the timer for the next letter
            }
        }
    }
    
    func generateRandomLetter() {
        // Randomly pick a letter from the alphabet
        let randomIndex = Int.random(in: 0..<alphabet.count)
        currentLetter = String(alphabet[alphabet.index(alphabet.startIndex, offsetBy: randomIndex)])
    }
}


struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}
