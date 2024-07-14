//
//  AuthView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/14/24.
//

import SwiftUI

struct AuthView: View {
    @State private var showLogin = 0
    
    var body: some View {
        ZStack {
            if (showLogin == 0 || showLogin == 2) {
                LoginView(showLogin: $showLogin)
            } else {
                SignupView(showLogin: $showLogin)
            }
        }
    }
}


