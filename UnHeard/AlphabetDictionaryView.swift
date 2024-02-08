//
//  AlphabetDictionaryView.swift
//  UnHeard
//
//  Created by Avya Rathod on 04/02/24.
//

import SwiftUI

struct AlphabetSign: Identifiable {
    let id = UUID()
    let letter: String
    let imageName: String
}

extension AlphabetSign {
    static let exampleAlphabets = [
        AlphabetSign(letter: "A", imageName: "deafSymbol"),
        AlphabetSign(letter: "B", imageName: "B_Sign"),
        // Add the rest of the alphabet with corresponding image names
    ]
}

struct AlphabetDictionaryView: View {
    let alphabets = AlphabetSign.exampleAlphabets
    @State private var searchQuery = ""
    @State private var selectedSign: AlphabetSign?
    @State private var isShowingDetail = false

    var filteredAlphabets: [AlphabetSign] {
        if searchQuery.isEmpty {
            return alphabets
        } else {
            return alphabets.filter { $0.letter.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    var body: some View {
        ZStack {
            VStack{
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                List {
                    ForEach(filteredAlphabets) { sign in
                        HStack {
                            Text(sign.letter)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(sign.imageName) // Replace "placeholder" with sign.imageName
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        .contentShape(Rectangle()) // Makes the entire HStack tappable
                        .onTapGesture {
                            self.selectedSign = sign
                            self.isShowingDetail = true
                        }
                    }
                }
                .blur(radius: isShowingDetail ? 20 : 0)
            }

            if isShowingDetail, let sign = selectedSign {
                SignDetailOverlayView(sign: sign) {
                    self.isShowingDetail = false
                }
            }
        }
        .navigationBarTitle("Alphabet Dictionary", displayMode: .inline)
    }
}

struct SignDetailOverlayView: View {
    let sign: AlphabetSign
    var onClose: () -> Void
    @State private var animateImage = false

    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all).onTapGesture {
                onClose()
            }

            // Larger image of the sign with animation
            Image(sign.imageName) // Ensure you have the correct image in your assets
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

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    AlphabetDictionaryView()
}
