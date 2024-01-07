//
//  SessionsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI

// A simple model for the Ski Session (group chat)
struct SkiSession: Identifiable {
    var id = UUID()
    var name: String
    // Add more properties as needed, like members, chat history, map information, etc.
}

struct SessionsView: View {
    // Sample data for ski sessions
    @State private var skiSessions: [SkiSession] = [
        SkiSession(name: "Beginners Group"),
        SkiSession(name: "Expert Run")
        // Add more sample groups or fetch from your backend
    ]

    var body: some View {
        VStack {
            Text("SnowCountry")
                .font(Font.custom("Good Times", size: 30))
                .padding()
            NavigationView {
                List(skiSessions) { session in
                    NavigationLink(destination: Text("Details for \(session.name)")) {
                        Text(session.name)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("Ski Sessions")
                            Spacer()
                            Button(action: createNewSession) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
    }

    private func createNewSession() {
        // Implement the creation logic here
        // For example, add a new SkiSession to skiSessions array
    }
}

