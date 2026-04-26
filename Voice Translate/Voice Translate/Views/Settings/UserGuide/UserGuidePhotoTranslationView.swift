import SwiftUI

struct UserGuidePhotoTranslationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        titleSection
                        
                        FAQItemView(title: "How to use photo translation") {
                            photoTranslationContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        ZStack {
            Text("User Guide")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
            
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
                Spacer()
            }
        }
    }
    
    private var titleSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 241/255, green: 245/255, blue: 249/255))
                    .frame(width: 44, height: 44)
                
                Image("issues_photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
            Text("Photo Translation Related Issues")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
        }
        .padding(.vertical, 20)
    }
    
    private var photoTranslationContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            step1Content
            
            HStack(spacing: 12) {
                Image("issues_photo_1")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
                
                Image("issues_photo_2")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            step2Content
            
            HStack(spacing: 12) {
                Image("issues_photo_3")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
                
                Image("issues_photo_4")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .font(.system(size: 14, weight: .regular))
        .foregroundColor(Color(red: 71/255, green: 85/255, blue: 105/255))
        .lineSpacing(4)
    }
    
    private var step1Content: some View {
        Text("Open **Camera tab**, then click **Gallery button** to select a photo from your album for translation, or use the camera to photograph text for translation. When using it for the first time, you'll need to grant ")
        + Text("camera and photo access permissions.")
            .foregroundColor(.red)
            .fontWeight(.bold)
        + Text(" When taking photos in a dimly lit environment, click the **Flashlight** icon to turn on the flash.")
    }
    
    private var step2Content: some View {
        Text("After taking a photo, the translation will ")
        + Text("be automatically displayed")
            .foregroundColor(.green)
            .fontWeight(.bold)
        + Text(" on the screen. Click the **Show Original button** to see the original image. Click the Share button , then click the **Copy button** to copy the translated content and share it with other apps.")
    }
}
