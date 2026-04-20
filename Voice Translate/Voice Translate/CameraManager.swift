import Foundation
import Combine
import SwiftUI
import AVFoundation
import Vision
import UIKit

// MARK: - CameraManager
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    @Published var capturedImage: UIImage? = nil
    @Published var recognizedText: String = ""
    @Published var translatedText: String = ""
    @Published var isProcessing: Bool = false
    
    private var currentSourceLanguage: String = "English"
    private var currentTargetLanguage: String = "Vietnamese"
    
    override init() {
        super.init()
        setupCamera()  
    }
    
    func setupCamera() {
        #if targetEnvironment(simulator)
        return // Ignore AV setup on simulator
        #else
        AVCaptureDevice.requestAccess(for: .video) { authorized in
            guard authorized else { return }
            
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            
            self.session.sessionPreset = .photo
            self.session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
        #endif
    }
    
    func capturePhoto(sourceLanguage: String, targetLanguage: String) {
        self.currentSourceLanguage = sourceLanguage
        self.currentTargetLanguage = targetLanguage
        
        #if targetEnvironment(simulator)
        // MOCK BEHAVIOR FOR SIMULATOR
        DispatchQueue.main.async {
            self.capturedImage = UIImage(systemName: "photo")
            self.isProcessing = true
            self.recognizedText = "Hôm nay trời đẹp quá, chúng ta đi chơi nhé!"
            if let img = self.capturedImage {
                self.processExtractedText(self.recognizedText, image: img)
            }
        }
        #else
        let settings = AVCapturePhotoSettings()
        self.photoOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }
    
    func processSelectedImage(_ image: UIImage, sourceLanguage: String, targetLanguage: String) {
        self.currentSourceLanguage = sourceLanguage
        self.currentTargetLanguage = targetLanguage
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.isProcessing = true
            self.recognizedText = ""
            self.translatedText = ""
        }
        
        recognizeText(from: image)
    }
    
    #if !targetEnvironment(simulator)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.isProcessing = true
            self.recognizedText = ""
            self.translatedText = ""
        }
        
        recognizeText(from: image)
    }
    #endif
    
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { self.isProcessing = false }
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async { self?.isProcessing = false }
                return
            }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self?.recognizedText = text
                if !text.isEmpty {
                    self?.processExtractedText(text, image: image)
                } else {
                    self?.translatedText = "No text found in image."
                    self?.isProcessing = false
                }
            }
        }
        
        request.recognitionLevel = .accurate
        do {
            try requestHandler.perform([request])
        } catch {
            DispatchQueue.main.async { self.isProcessing = false }
        }
    }
    
    private func processExtractedText(_ text: String, image: UIImage) {
        Task {
            do {
                let result = try await OpenAIService.shared.summarize(image: image, targetLanguage: currentTargetLanguage)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.translatedText = result.content
                    self.isProcessing = false
                    
                    let title = "Image Summary"
                    let desc = "Captured Image Details"
                    let capturedImg = self.capturedImage
                    
                    AINoteMockData.addNote(
                        title: title,
                        description: desc,
                        type: .image,
                        image: capturedImg,
                        summary: result.content
                    )
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.translatedText = "Failed to summarize: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func reset() {
        self.capturedImage = nil
        self.recognizedText = ""
        self.translatedText = ""
        self.isProcessing = false
    }
}
