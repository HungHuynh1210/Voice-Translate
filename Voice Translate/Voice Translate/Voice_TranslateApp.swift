//
//  Voice_TranslateApp.swift
//  Voice Translate
//
//  Created by Hưng Huỳnh on 3/4/26.
//

import SwiftUI

@main
struct Voice_TranslateApp: App {
    // Global language state, defaults to "en" (English)
    @AppStorage("appLanguageCode") private var appLanguageCode = "en"
    
    init() {
        // Force the app to always start on the Translate screen
        UserDefaults.standard.set(0, forKey: "selectedTab")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: appLanguageCode))
                .id(appLanguageCode) // Forces SwiftUI to completely rebuild the view tree when language is changed!
        }
    }
}
