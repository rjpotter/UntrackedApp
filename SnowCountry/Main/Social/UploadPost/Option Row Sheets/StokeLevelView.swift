//
//  StokeLevelView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/25/24.
//

import SwiftUI

struct StokeLevelPickerView: View {
    @Binding var selectedLevel: Int
    
    var body: some View {
        VStack {
            Text("Rate Stoke Level")
                .font(.headline)
                .padding()
            
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Button(action: {
                        selectedLevel = level
                    }) {
                        Image(systemName: "snowflake")
                            .font(.largeTitle)
                            .foregroundColor(level <= selectedLevel ? .blue : .gray)
                    }
                }
            }
            .padding()
        }
    }
}
