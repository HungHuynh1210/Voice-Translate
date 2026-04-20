//
//  ContentView.swift
//  Voice Translate
//
//  Created by Hưng Huỳnh on 3/4/26.
//

import SwiftUI

enum AppState: String {
    case onboarding
    case iap
    case main
}

struct ContentView: View {
    @AppStorage("appState") private var appState: AppState = .onboarding
    
    var body: some View {
        Group {
            switch appState {
            case .onboarding:
                OnboardingView {
                    withAnimation {
                        appState = .iap
                    }
                }
            case .iap:
                IAPView(
                    onDismiss: {
                        withAnimation {
                            UserDefaults.standard.set(0, forKey: "selectedTab")
                            appState = .main
                        }
                    },
                    onSubscribe: {
                        // Normally handle purchase logic here
                        withAnimation {
                            UserDefaults.standard.set(0, forKey: "selectedTab")
                            appState = .main
                        }
                    }
                )
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
