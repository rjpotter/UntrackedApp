//
//  SafetyView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 11/30/23.
//

import SwiftUI

struct SafetyView: View {
    var body: some View {
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
}
