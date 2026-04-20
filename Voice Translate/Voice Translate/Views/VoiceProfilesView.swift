import SwiftUI

struct VoiceProfile: Identifiable {
    let id = UUID()
    let name: String
    let isDefault: Bool
}

struct VoiceProfilesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Sample existing profiles
    @State private var profiles: [VoiceProfile] = [
        VoiceProfile(name: "My Professional Voice", isDefault: true),
        VoiceProfile(name: "Casual Tone", isDefault: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themeMainText)
                }
                Spacer()
                Text("Voice Profiles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themeMainText)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            if profiles.isEmpty {
                // Empty State
                VStack {
                    Spacer()
                    Image(systemName: "waveform.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.themeSecondaryText.opacity(0.5))
                        .padding(.bottom, 16)
                    
                    Text("No Voice Profiles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themeMainText)
                    Text("Create a voice profile to personalize your translated audio output.")
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                    Spacer()
                }
            } else {
                // List of profiles
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(profiles) { profile in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.themePrimary.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "waveform")
                                        .foregroundColor(.themePrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.themeMainText)
                                    if profile.isDefault {
                                        Text("Default")
                                            .font(.system(size: 12))
                                            .foregroundColor(.themeSecondaryText)
                                    }
                                }
                                .padding(.leading, 12)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.themePrimary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(profile.isDefault ? Color.themePrimary : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Create New Button
            NavigationLink(destination: VoiceCloningIntroView()) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Create New Voice Profile")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.themePrimary)
                .foregroundColor(.white)
                .cornerRadius(20)
                .shadow(color: Color.themePrimary.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 16)
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct VoiceProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceProfilesView()
    }
}
