import SwiftUI

struct VoiceCloningRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isRecording = false
    @State private var currentStep = 1
    
    let sampleTexts = [
        "Our classroom is very nice. It is large, clean and light.",
        "The quick brown fox jumps over the lazy dog.",
        "Artificial intelligence is transforming how we communicate globally."
    ]
    
    var body: some View {
        VStack {
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
                Text("Generating Your Voice")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themeMainText)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Progress Bar
            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step <= currentStep ? Color.themePrimary : Color.themeSecondaryText.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Text("Sentence \(currentStep) of 3")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.themeSecondaryText)
                .padding(.top, 8)
            
            Spacer()
            
            // Instructional Text
            Text("Please read the following text aloud to train your voice model.")
                .font(.system(size: 16))
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            
            // Voice Sample Text Container
            Text(sampleTexts[currentStep - 1])
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.themeMainText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(8)
            
            Spacer()
            
            // Recording Controls
            VStack(spacing: 24) {
                if isRecording {
                    Text("Recording... 00:05")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                } else {
                    Text("Tap to start")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themeSecondaryText)
                }
                
                Button(action: {
                    withAnimation {
                        isRecording.toggle()
                        // Simulate auto progression for demo
                        if !isRecording && currentStep < 3 {
                            currentStep += 1
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red.opacity(0.2) : Color.themePrimary.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .blur(radius: 7.5)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(isRecording ? Color.red : Color.themePrimary)
                            .clipShape(Circle())
                            .shadow(color: (isRecording ? Color.red : Color.themePrimary).opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                }
                
                if currentStep == 3 && !isRecording {
                    NavigationLink(destination: VoiceCloningProcessingView()) {
                        Text("Process Voice")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.themePrimary)
                            .cornerRadius(20)
                    }
                    .padding(.top, 16)
                } else if !isRecording {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Finish Later")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.themeSecondaryText)
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct VoiceCloningRecordView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCloningRecordView()
    }
}
