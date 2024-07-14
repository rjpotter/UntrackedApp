//
//  AuthView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 7/14/24.
//

import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    
    var body: some View {
        ZStack {
            if showLogin {
                LoginView(showLogin: $showLogin)
            } else {
                SignupView(showLogin: $showLogin)
            }
        }
    }
}

