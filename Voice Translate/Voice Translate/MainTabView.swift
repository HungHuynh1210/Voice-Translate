import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("hideTabBar") private var hideTabBar = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
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
        .accentColor(Color(hex: "#0069F2"))
        .onAppear {
            hideTabBar = (selectedTab == 1)
        }
        .onChange(of: selectedTab) { newValue in
            hideTabBar = (newValue == 1)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(icon: "icon_tab_translate", activeIcon: "icon_tab_translate", title: "Translate", isSystem: false, isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            if selectedTab != 2 {
                TabButton(icon: "camera", activeIcon: "camera.fill", title: "Camera", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            TabButton(icon: "gearshape", activeIcon: "gearshape.fill", title: "Settings", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.top, 13)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#F3F7F8").ignoresSafeArea(.all, edges: .bottom))
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color(hex: "#E2E8F0")),
            alignment: .top
        )
    }
}

struct TabButton: View {
    let icon: String
    let activeIcon: String
    let title: String
    var isSystem: Bool = true
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isSystem {
                    Image(systemName: isSelected ? activeIcon : icon)
                        .font(.system(size: 24))
                } else {
                    Image(isSelected ? activeIcon : icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(title)
                    .font(.custom("SFProDisplay-Medium", size: 12))
            }
            .foregroundColor(isSelected ? Color(hex: "#0069F2") : Color(hex: "#94A3B8"))
            .frame(maxWidth: .infinity)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
