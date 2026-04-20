import SwiftUI
import AVFoundation
import Speech
import Combine

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    @StateObject private var audioRecorder = AudioRecorder()
    
    @State private var showImagePicker = false
    @State private var showTextInput = false
    @State private var textInputData = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 3 Input Methods
                HStack(spacing: 15) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "camera")
                                .font(.title)
                            Text("Camera")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showTextInput = true
                    }) {
                        VStack {
                            Image(systemName: "doc.text")
                                .font(.title)
                            Text("Văn bản")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                            if let url = audioRecorder.recordingURL {
                                viewModel.process(input: .voice(url))
                            }
                        } else {
                            audioRecorder.startRecording()
                        }
                    }) {
                        VStack {
                            Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic")
                                .font(.title)
                                .foregroundColor(audioRecorder.isRecording ? .red : .primary)
                            Text(audioRecorder.isRecording ? "Đang ghi âm..." : "Giọng nói")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Content Output Area
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Đang gọi Gemini AI...")
                        .scaleEffect(1.2)
                    Spacer()
                } else if let result = viewModel.summaryResult {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Kết quả tóm tắt")
                                .font(.headline)
                            
                            Text(result.content)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            
                            Button(action: {
                                UIPasteboard.general.string = result.content
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy kết quả")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                    Text("Vui lòng chọn 1 trong 3 phương thức trên để bắt đầu")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("AI Summary")
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView { image in
                    if let img = image {
                        viewModel.process(input: .image(img))
                    }
                }
            }
            .sheet(isPresented: $showTextInput) {
                TextInputView(text: $textInputData) {
                    if !textInputData.isEmpty {
                        viewModel.process(input: .text(textInputData))
                    }
                    textInputData = ""
                }
            }
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(
                    title: Text("Lỗi"),
                    message: Text(viewModel.errorMessage ?? "Có lỗi xảy ra."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Audio Recorder
class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    var recordingURL: URL?

    override init() {
        super.init()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)
        
        // Request Permissions for Audio and Speech
        session.requestRecordPermission { _ in }
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("voice_summary_input.m4a")
            recordingURL = audioFilename

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("Could not start recording")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

// MARK: - ImagePicker
struct ImagePickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Default to camera, fallback to photo library in simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onImagePicked(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Text Input View
struct TextInputView: View {
    @Binding var text: String
    @Environment(\.presentationMode) var presentationMode
    var onCommit: () -> Void
    
    var body: some View {
        NavigationView {
            TextEditor(text: $text)
                .padding()
                .navigationTitle("Nhập văn bản")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Hủy") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Tóm tắt") {
                        onCommit()
                        presentationMode.wrappedValue.dismiss()
                    }.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                )
        }
    }
}
