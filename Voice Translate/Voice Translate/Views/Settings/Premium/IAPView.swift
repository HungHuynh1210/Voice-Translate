import SwiftUI

struct IAPFeature: Identifiable {
    let id = UUID()
    let title: String
}

struct IAPView: View {
    let features: [IAPFeature] = [
        IAPFeature(title: "Photo Translation & AI Note"),
        IAPFeature(title: "Real-time Translation"),
        IAPFeature(title: "Translate without limits"),
        IAPFeature(title: "Unlimited Voice Cloning")
    ]
    
    @State private var isYearlySelected = true
    @State private var freeTrialEnabled = true
    
    var onDismiss: () -> Void
    var onSubscribe: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themeMainText)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 36)
            
            // Top Illustration Placeholder
            Spacer().frame(height: 12)
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.themePrimary)
                .padding(.bottom, 24)
            
            // Title
            HStack(spacing: 0) {
                Text("Unlock ")
                    .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
                Text("All")
                    .foregroundColor(Color(red: 0, green: 105/255, blue: 242/255))
                Text(" Features")
                    .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
            }
            .font(.system(size: 37, weight: .bold))
            .padding(.bottom, 32)
            
            // Features List
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.themePrimary)
                            .font(.system(size: 20))
                        
                        Text(LocalizedStringKey(feature.title))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.themeMainText)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Plans
            VStack(spacing: 10) {
                // Free Trial Toggle Row
                HStack {
                    Text("Enable Free Trial")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    Spacer()
                    Toggle("", isOn: $freeTrialEnabled)
                        .labelsHidden()
                        .tint(Color(red: 0, green: 98/255, blue: 255/255))
                }
                .frame(height: 76)
                .padding(.horizontal, 20)
                .background(Color(red: 252/255, green: 253/255, blue: 255/255))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0, green: 105/255, blue: 242/255).opacity(0.2), lineWidth: 2)
                )
                .padding(.horizontal, 20)
                
                // Yearly Plan
                Button(action: { isYearlySelected = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Yearly Plan")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            Text("đ 1.999.000")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0, green: 105/255, blue: 242/255))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("just 38.442")
                            Text("per week")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    }
                    .frame(height: 76)
                    .padding(.horizontal, 20)
                    .background(isYearlySelected ? Color(red: 0, green: 105/255, blue: 242/255).opacity(0.1) : Color(red: 252/255, green: 253/255, blue: 255/255))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isYearlySelected ? Color(red: 0, green: 105/255, blue: 242/255) : Color(red: 0, green: 105/255, blue: 242/255).opacity(0.2), lineWidth: isYearlySelected ? 3 : 2)
                    )
                }
                .padding(.horizontal, 20)
                
                // Weekly Plan
                Button(action: { isYearlySelected = false }) {
                    HStack {
                        Text("Weekly Plan")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("299.000")
                            Text("per week")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    }
                    .frame(height: 76)
                    .padding(.horizontal, 20)
                    .background(!isYearlySelected ? Color(red: 0, green: 105/255, blue: 242/255).opacity(0.1) : Color(red: 252/255, green: 253/255, blue: 255/255))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isYearlySelected ? Color(red: 0, green: 105/255, blue: 242/255) : Color(red: 0, green: 105/255, blue: 242/255).opacity(0.2), lineWidth: !isYearlySelected ? 3 : 2)
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            
            // Bottom Area
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "lock.shield")
                    Text("Cancel anytime")
                }
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                
                Button(action: {
                    onSubscribe()
                }) {
                    ZStack {
                        Text("CONTINUE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(red: 17/255, green: 17/255, blue: 17/255))
                    .cornerRadius(20)
                    .shadow(color: Color(red: 0, green: 69/255, blue: 230/255).opacity(0.25), radius: 21.4, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 34) {
                    Button(action: {}) {
                        Text("Terms of Service")
                            .underline()
                    }
                    Button(action: {}) {
                        Text("Privacy policy")
                            .underline()
                    }
                }
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 103/255, green: 103/255, blue: 103/255))
            }
            .padding(.bottom, 16)
        }
        .background(Color.themeBackgroundWhite.ignoresSafeArea())
    }
}

struct IAPView_Previews: PreviewProvider {
    static var previews: some View {
        IAPView(onDismiss: {}, onSubscribe: {})
    }
}
