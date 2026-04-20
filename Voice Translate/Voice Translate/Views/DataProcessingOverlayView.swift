import SwiftUI

struct DataProcessingOverlayView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasAgreedToDataProcessing") private var hasAgreed: Bool = false
    
    var body: some View {
        ZStack {
            // Dark Background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: dismiss on outside tap
                    // isPresented = false
                }
            
            // Popup Card
            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                Image("data_processing_illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 114, height: 114)
                
                Spacer().frame(height: 32)
                
                Text("How Your Data Is Processed")
                    .font(.custom("SFProDisplay-Bold", size: 25))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(28 - 25)
                
                Spacer().frame(height: 24)
                
                // Body Text
                VStack(alignment: .leading, spacing: 16) {
                    Text("To enable AI translation and processing features, the app securely sends certain data to OpenAI, a third-party AI service provider. This may include:\n • Voice recordings\n • Images that you upload")
                        .font(.custom("SFProDisplay-Regular", size: 17))
                        .lineSpacing(28 - 17)
                        .foregroundColor(.black)
                    
                    Text("This information is used solely to generate translations and AI-generated responses.\nWe do not sell or share your personal data for commercial purposes.")
                        .font(.custom("SFProDisplay-Regular", size: 17))
                        .lineSpacing(28 - 17)
                        .foregroundColor(.black)
                    
                    // Privacy Policy string with blue text
                    (Text("For more information, please refer to our ")
                        .font(.custom("SFProDisplay-Regular", size: 17))
                        .foregroundColor(.black)
                     + Text("Privacy Policy")
                        .font(.custom("SFProDisplay-Semibold", size: 17))
                        .foregroundColor(Color(hex: "#0069F2"))
                     + Text(".")
                        .font(.custom("SFProDisplay-Regular", size: 17))
                        .foregroundColor(.black))
                    .lineSpacing(28 - 17)
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 40)
                 
                // Agree & Continue Button
                Button(action: {
                    hasAgreed = true
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#111111"))
                            .frame(height: 60)
                        
                        Text("Agree & Continue")
                            .font(.custom("SFProDisplay-Bold", size: 18))
                            .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Image("data_processing_arrow")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .padding(.trailing, 24)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 24)
                
                // Not Now Button
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("Not Now")
                        .font(.custom("SFProDisplay-Medium", size: 16))
                        .foregroundColor(Color(hex: "#0F172A"))
                }
                
                Spacer().frame(height: 32)
            }
            .background(Color.white)
            .cornerRadius(24)
            .frame(width: 350)
            // Hardcode height to roughly match Figma if needed, but hug content is usually better in SwiftUI. This layout naturally fills the space correctly.
        }
    }
}

struct DataProcessingOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        DataProcessingOverlayView(isPresented: .constant(true))
    }
}
