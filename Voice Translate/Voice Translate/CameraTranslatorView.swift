import SwiftUI
import PhotosUI
import AVFoundation

struct CameraTranslatorView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("hideTabBar") private var hideTabBar = false
    @AppStorage("hasAgreedToDataProcessing") private var hasAgreed: Bool = false
    @State private var showDataProcessingOverlay: Bool = false
    @State private var sourceLanguage: String = "English"
    @State private var targetLanguage: String = "Vietnamese"
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isFlashOn: Bool = false
    
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Main Background (Dark textured foliage from Figma)
            ZStack {
                Color(hex: "#1C1C1C").ignoresSafeArea()
                Image("camera_main_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            
            // Full Screen Live Camera
            LiveCameraView(sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage, cameraManager: cameraManager)
            
            if !(cameraManager.capturedImage != nil && cameraManager.isProcessing) {
                VStack {
                    Spacer()
                    bottomBar
                }
                .ignoresSafeArea(edges: .bottom)
                
                if showDataProcessingOverlay {
                    DataProcessingOverlayView(isPresented: $showDataProcessingOverlay)
                        .zIndex(200)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if !hasAgreed {
                showDataProcessingOverlay = true
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        cameraManager.processSelectedImage(uiImage, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
                    }
                }
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
    }
    
    // MARK: - Subcomponents
    
    // Constraint Bottom Bar matches Figma's 307px container width
    private var bottomBar: some View {
        HStack(alignment: .center) {
            // Gallery Button
            VStack(spacing: 6) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .background(.regularMaterial, in: Circle())
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.9)
                                )
                            
                            Image("camera_gallery_icon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("Gallery")
                        .font(.custom("SFProDisplay-Medium", size: 12))
                        .foregroundColor(.white)
                        .tracking(1) // roughly 1px tracking
                }
                
                Spacer()
                
                // Shutter Button
                Button(action: {
                    cameraManager.capturePhoto(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
                }) {
                    ZStack {
                        // Outer Black
                        Circle()
                            .fill(Color.black)
                            .frame(width: 88, height: 88)
                        
                        // White Stroke Ring
                        Circle()
                            .fill(Color.white)
                            .frame(width: 77, height: 77)
                        
                        // Inner Black Core
                        Circle()
                            .fill(Color.black)
                            .frame(width: 69.6, height: 69.6)
                    }
                }
                .padding(.bottom, 20) // Nudge it up slightly
                
                Spacer()
                
                // Flash Button
                VStack(spacing: 6) {
                    Button(action: {
                        isFlashOn.toggle()
                        toggleFlash()
                    }) {
                        ZStack {
                            Circle()
                                .fill(isFlashOn ? Color.white : Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .background(.regularMaterial, in: Circle())
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.9)
                                )
                            
                            Image("camera_flash_icon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(isFlashOn ? .black : .white)
                        }
                    }
                    
                    Text("Flash")
                        .font(.custom("SFProDisplay-Medium", size: 12))
                        .foregroundColor(.white)
                        .tracking(1)
                }
            }
            .frame(width: 307) // Matches the exact constrained width of bottom buttons spacing in Figma
            .frame(maxWidth: .infinity) // Centers the 307px container
            .padding(.top, 30) // Pushing gradient upwards
            .padding(.bottom, 34 + 20)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.clear, location: 0),
                        .init(color: Color.black.opacity(0.4), location: 0.5),
                        .init(color: Color.black.opacity(0.8), location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.bottom)
            )
        }
    
    // MARK: - Flashlight Logic
    private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
    }
}

struct CameraTranslatorView_Previews: PreviewProvider {
        static var previews: some View {
            CameraTranslatorView()
        }
    }

