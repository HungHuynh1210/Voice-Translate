import SwiftUI

enum CloningState {
    case intro              // 74:638 Before You Continue
    case recording          // 75:2106 Read Out Sentence
    case recordingActive    // 75:2669 Recording in progress
    case confirm            // 75:2840 Confirm to Proceed (Waveform)
    case generating         // 77:3601 Generating Your Voice
    case success            // 77:3457 Voice Cloning Consent (Start Translation)
    case existingProfile    // 80:4385 Reset Voice Clone / Existing
}

struct VoiceCloningFlowView: View {
    @AppStorage("hasClonedVoice") private var hasClonedVoice = false
    @State private var currentState: CloningState = .intro
    @State private var showDeleteConfirmation: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var audioManager = VoiceCloningAudio()
    
    var body: some View {
        ZStack {
            // Main Content Area
            VStack(spacing: 0) {
                // Top Navigation Bar
                VoiceCloningNavBar(
                    title: (currentState == .intro || currentState == .success) ? "Voice Cloning" : "",
                    onBack: {
                        audioManager.stopAIReading()
                        audioManager.pauseRecording()
                        
                        if currentState == .intro || currentState == .existingProfile {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            // Simple back navigation or reset for testing
                            currentState = .intro
                        }
                    }
                )
                
                Group {
                    switch currentState {
                    case .intro:
                        IntroView(onNext: { currentState = .recording })
                    case .recording:
                        RecordingView(isActive: false, onRecord: {
                            audioManager.requirePermission { granted in
                                if granted {
                                    audioManager.startRecording()
                                    currentState = .recordingActive
                                }
                            }
                        })
                    case .recordingActive:
                        RecordingView(isActive: true, onNext: {
                            audioManager.stopRecording()
                            if audioManager.recordingDuration < 10.0 {
                                // Handled in RecordingView directly via state
                            } else {
                                currentState = .confirm
                            }
                        }, onReset: {
                            currentState = .recording
                        })
                    case .confirm:
                        ConfirmView(onConvert: { 
                            hasClonedVoice = true
                            currentState = .generating 
                        })
                    case .generating:
                        GeneratingView(onComplete: { currentState = .success })
                    case .success:
                        SuccessView(onFinish: { 
                            audioManager.stopAIReading()
                            audioManager.pauseRecording()
                            presentationMode.wrappedValue.dismiss() 
                        })
                    case .existingProfile:
                        ExistingProfileView(
                            onReset: { currentState = .recording },
                            onDelete: { showDeleteConfirmation = true }
                        )
                    }
                }
                .environmentObject(audioManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(hex: "#F8FAFC").edgesIgnoringSafeArea(.all)) // Safe default bg
            .onAppear {
                if hasClonedVoice {
                    currentState = .existingProfile
                } else {
                    currentState = .intro
                }
            }
            
            // Delete Overlay Modal
            if showDeleteConfirmation {
                DeleteConfirmationModal(
                    onCancel: { showDeleteConfirmation = false },
                    onDelete: {
                        hasClonedVoice = false
                        showDeleteConfirmation = false
                        currentState = .intro
                    }
                )
            }
        }
        .navigationBarHidden(true) // We are using a custom nav bar
    }
}

// MARK: - Reusable Components

struct VoiceCloningNavBar: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#0F172A"))
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0F172A"))
                
                Spacer()
                
                // Empty space to push text directly into dead center cleanly
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}

struct VCPrimaryButton: View {
    let title: String
    let action: () -> Void
    var systemImage: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(hex: "#0069F2"))
            .cornerRadius(16)
            .shadow(color: Color(hex: "#0069F2").opacity(0.3), radius: 10, y: 4)
        }
    }
}

struct ChecklistItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#DBEAFE"))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#0069F2"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#0F172A"))
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#64748B"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
        )
    }
}

struct DeleteConfirmationModal: View {
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: onCancel)
            
            VStack(spacing: 24) {
                // Delete Icon Frame
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FEE2E2"))
                        .frame(width: 80, height: 80)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#EF4444"))
                }
                .padding(.top, 16)
                
                VStack(spacing: 8) {
                    Text("Delete Voice Clone")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#0F172A"))
                    
                    Text("Are you sure you want to delete your cloned voice? You will need to record a new sample to create another voice clone.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#64748B"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineSpacing(4)
                }
                
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#64748B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#F1F5F9"))
                            .cornerRadius(12)
                    }
                    
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#EF4444"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(24)
            .padding(24)
        }
        .zIndex(10)
    }
}

// MARK: - Hero Illustration (75:982)
struct VoiceCloningIllustration: View {
    var imageName: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 256)
                .background(
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 256)
                        .clipped()
                )
        }
        .padding(.top, 9)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 172, alignment: .center)
    }
}


struct  VoiceCloningFlowView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCloningFlowView()
    }
}
