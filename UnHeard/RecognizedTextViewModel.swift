//
//  RecognizedTextViewModel.swift
//  UnHeard
//
//  Created by Avya Rathod on 07/02/24.
//

import Foundation

class RecognizedTextViewModel: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var typedText: String = ""
    private var lastRecognizedText: String = ""
    private var consecutiveCount: Int = 0
    
    // Call this function whenever a new prediction is made
    func updateRecognizedText(newText: String) {
        if newText == lastRecognizedText {
            consecutiveCount += 1
        } else {
            consecutiveCount = 1
            lastRecognizedText = newText
        }
        
        // Update recognized text for display
        DispatchQueue.main.async {
            self.recognizedText = newText
        }
        
        // If the same text has been recognized for 3 consecutive frames, append it
        if consecutiveCount >= 3 {
            appendToTypedText(text: newText)
            consecutiveCount = 0 // Reset count after appending
        }
    }
    
    private func appendToTypedText(text: String) {
        DispatchQueue.main.async {
            self.typedText += text + " " // Append new text to typed text
        }
    }
}
