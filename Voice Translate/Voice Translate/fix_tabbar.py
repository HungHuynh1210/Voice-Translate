import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/MainTabView.swift", "r") as f:
    content = f.read()

# Make sure we use onChange to sync
old_body = """    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                VoiceTranslatorView()
                    .tag(0)
                
                CameraTranslatorView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            
            if !hideTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hideTabBar)
        .accentColor(Color(hex: "#0069F2"))
        .onAppear {
            hideTabBar = false
        }
    }"""

new_body = """    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                VoiceTranslatorView()
                    .tag(0)
                
                CameraTranslatorView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            
            if !hideTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hideTabBar)
        .accentColor(Color(hex: "#0069F2"))
        .onAppear {
            hideTabBar = (selectedTab == 1)
        }
        .onChange(of: selectedTab) { newValue in
            hideTabBar = (newValue == 1)
        }
    }"""

if old_body in content:
    content = content.replace(old_body, new_body)
    with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/MainTabView.swift", "w") as f:
        f.write(content)
    print("MainTabView updated.")
else:
    print("Could not find old body in MainTabView.")
