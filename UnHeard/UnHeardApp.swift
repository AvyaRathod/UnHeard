//
//  UnHeardApp.swift
//  UnHeard
//
//  Created by Avya Rathod on 02/02/24.
//

import SwiftUI

@main
struct UnHeardApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                NavigationScreen()
            }
        }
    }
}

struct NavigationScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("UnHeard")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 15) {
                        NavigationButton(title: "Alphabet Dictionary", destination: AlphabetDictionaryView())
                        NavigationButton(title: "Live Typer", destination: LiveTyperView())
                        NavigationButton(title: "Quiz", destination: QuizView())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct NavigationButton<Destination: View>: View {
    var title: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: self.destination) {
            Text(title)
                .foregroundColor(Color.black)
                .fontWeight(.medium)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}


struct NavigationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationScreen()
    }
}
