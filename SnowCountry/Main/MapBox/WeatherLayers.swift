//
//  WeatherLayers.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/4/24.
//

import SwiftUI

struct WeatherLayersView: View {
    @Binding var isRadarVisible: Bool
    @Binding var isCloudsVisible: Bool
    @Binding var isFutureSnowfallVisible: Bool
    @Binding var isCurrentSnowDepthVisible: Bool
    @Environment(\.colorScheme) var colorScheme // Detects the current color scheme

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    private var buttonBackgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    private var activeColor: Color {
        Color.blue
    }
    private var inactiveColor: Color {
        Color.gray
    }
    private let buttonHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 15

    var body: some View {
        VStack(spacing: 20) {
            Text("Weather Layers")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .padding(.top)

            modernButton("Toggle Radar", isActive: isRadarVisible) {
                isRadarVisible.toggle()
            }

            modernButton("Toggle Clouds", isActive: isCloudsVisible) {
                isCloudsVisible.toggle()
            }

            modernButton("Toggle Future Snowfall", isActive: isFutureSnowfallVisible) {
                isFutureSnowfallVisible.toggle()
            }

            modernButton("Toggle Current Snow Depth", isActive: isCurrentSnowDepthVisible) {
                isCurrentSnowDepthVisible.toggle()
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .cornerRadius(25)
        .shadow(radius: 10)
    }

    private func modernButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                Spacer()
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isActive ? activeColor : inactiveColor)
            }
            .padding()
            .frame(height: buttonHeight)
            .background(isActive ? activeColor.opacity(0.1) : buttonBackgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isActive ? activeColor : inactiveColor, lineWidth: 2)
            )
        }
    }
}

struct WeatherLayersView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherLayersView(isRadarVisible: .constant(false), isCloudsVisible: .constant(false), isFutureSnowfallVisible: .constant(false), isCurrentSnowDepthVisible: .constant(false))
            .preferredColorScheme(.light) // or .dark for testing
    }
}

