import re

with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/MainTabView.swift", "r") as f:
    content = f.read()

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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hideTabBar)
"""

new_body = """    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                VoiceTranslatorView()
                    .tag(0)
                
                CameraTranslatorView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
                .offset(y: hideTabBar ? 150 : 0)
                .opacity(hideTabBar ? 0 : 1)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hideTabBar)
"""

if old_body in content:
    content = content.replace(old_body, new_body)
    with open("/Users/hung/Documents/VoiceTranslate/Voice Translate/Voice Translate/MainTabView.swift", "w") as f:
        f.write(content)
    print("MainTabView updated for ZStack overlay.")
else:
    print("Could not find old body in MainTabView.")
