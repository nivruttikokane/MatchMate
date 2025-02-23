//
//  SplashView.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 24/02/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            MainView() // Replace with your actual main view
        } else {
            VStack {
                Image(systemName: "heart.fill") // Replace with your app's logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(Color(red: 17/255, green: 177/255, blue: 201/255))

                Text("MatchMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 17/255, green: 177/255, blue: 201/255))

                Text("Find your perfect match!")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
