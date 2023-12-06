//
//  SafetyView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI

struct SafetyView: View {
    var body: some View {
        VStack{
            Text("SnowCountry")
                .font(Font.custom("Good Times", size:30))
            
            NavigationView {
                List {
                    Section(header: Text("Avalanche Safety")) {
                        Text("Avalanche Report")
                    }
                    Section(header: Text("Treewell Safety")) {
                        Text("Treewell Safety Guidelines")
                    }
                    Section(header: Text("AR Visualization")) {
                        Text("AR Top of Run (Coming Soon)")
                    }
                }
                .navigationTitle("Safety")
            }
        }
        .background(Color("Background").opacity(0.5))
    }
        
}
