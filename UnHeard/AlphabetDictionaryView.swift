//
//  AlphabetDictionaryView.swift
//  UnHeard
//
//  Created by Avya Rathod on 04/02/24.
//

import SwiftUI

struct Sign: Identifiable {
    let id = UUID()
    let word: String
    let imageName: String?
}

extension Sign {
    static let Alphabets = [
        Sign(word: "A", imageName: "A"),
        Sign(word: "B", imageName: "B"),
        Sign(word: "C", imageName: "C"),
        Sign(word: "D", imageName: "D"),
        Sign(word: "E", imageName: "E"),
        Sign(word: "F", imageName: "F"),
        Sign(word: "G", imageName: "G"),
        Sign(word: "H", imageName: "H"),
        Sign(word: "I", imageName: "I"),
        Sign(word: "J", imageName: "J"),
        Sign(word: "K", imageName: "K"),
        Sign(word: "L", imageName: "L"),
        Sign(word: "M", imageName: "M"),
        Sign(word: "N", imageName: "N"),
        Sign(word: "O", imageName: "O"),
        Sign(word: "P", imageName: "P"),
        Sign(word: "Q", imageName: "Q"),
        Sign(word: "R", imageName: "R"),
        Sign(word: "S", imageName: "S"),
        Sign(word: "T", imageName: "T"),
        Sign(word: "U", imageName: "U"),
        Sign(word: "V", imageName: "V"),
        Sign(word: "W", imageName: "W"),
        Sign(word: "X", imageName: "X"),
        Sign(word: "Y", imageName: "Y"),
        Sign(word: "Z", imageName: "Z")
    ]
    
}

struct AlphabetPlacardView: View {
    let sign: Sign
    
    var backgroundColor: Color {
        Color(
            red: Double.random(in: 0.4...0.8),
            green: Double.random(in: 0.4...0.8),
            blue: Double.random(in: 0.4...0.8),
            opacity: 1.0
        )
    }
    
    var body: some View {
        VStack {
            Image(sign.imageName!)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
            
            Text(sign.word)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
    }
}


struct AlphabetDictionaryView: View {
    let alphabets = Sign.Alphabets
    @State private var searchQuery = ""
    @State private var selectedSign: Sign?
    @State private var isShowingDetail = false
    
    var filteredAlphabets: [Sign] {
        if searchQuery.isEmpty {
            return alphabets
        } else {
            return alphabets.filter { $0.word.lowercased().contains(searchQuery.lowercased()) }
        }
    }
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredAlphabets) { sign in
                        AlphabetPlacardView(sign: sign)
                            .onTapGesture {
                                self.selectedSign = sign
                                self.isShowingDetail = true
                            }
                    }
                }
                .padding()
            }
            .blur(radius: isShowingDetail ? 20 : 0)
            .navigationBarTitle("Alphabet Dictionary", displayMode: .inline)
            .overlay(
                Group {
                    if isShowingDetail, let sign = selectedSign {
                        SignDetailOverlayView(sign: sign) {
                            self.isShowingDetail = false
                            self.selectedSign = nil
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: isShowingDetail)
                    }
                }
            )
        }
    }
}

struct SignDetailOverlayView: View {
    let sign: Sign
    var onClose: () -> Void
    @State private var animateImage = false

    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all).onTapGesture {
                onClose()
            }

            // Container for the image and text
            VStack {
                // Close button aligned to the top trailing corner
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20) // Adjust padding as needed
                }

                Spacer()

                // Image and Text overlay
                VStack {
                    Text(sign.word)
                        .font(.largeTitle) // Adjust the font size as needed
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 5) // Space between text and image

                    Image(sign.imageName!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: animateImage ? 200 : 100, height: animateImage ? 200 : 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                        .padding()
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                animateImage = true
                            }
                        }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all) // Ensure the overlay covers the entire screen
    }
}


struct AlphabetDictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        AlphabetDictionaryView()
    }
}
