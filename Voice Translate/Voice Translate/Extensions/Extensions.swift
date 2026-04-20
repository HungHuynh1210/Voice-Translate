import SwiftUI

extension Color {
    static let themePrimary = Color(hex: "#0069F2")
    static let themeDarkPrimary = Color(hex: "#0062FF")
    static let themeMainText = Color(hex: "#0F172A")
    static let themeSecondaryText = Color(hex: "#94A3B8")
    static let themeBackgroundGray = Color(hex: "#F0F7FA")
    static let themeBackgroundWhite = Color(hex: "#FFFFFF")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color.themePrimary)
            .cornerRadius(20)
            .shadow(color: Color.themePrimary.opacity(0.25), radius: 21.4, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

// MARK: - Navigation Control
extension View {
    func hideTabBar() -> some View {
        self.onAppear {
            UserDefaults.standard.set(true, forKey: "hideTabBar")
        }
    }
    
    func showTabBar() -> some View {
        self.onAppear {
            UserDefaults.standard.set(false, forKey: "hideTabBar")
        }
    }
}
