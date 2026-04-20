import Foundation
import SwiftUI
import Combine

@MainActor
class SummaryViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var summaryResult: SummaryResult?
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    func process(input: InputType) {
        isLoading = true
        summaryResult = nil
        errorMessage = nil
        
        Task {
            do {
                let result: SummaryResult
                switch input {
                case .text(let text):
                    result = try await OpenAIService.shared.summarize(text: text)
                case .image(let image):
                    result = try await OpenAIService.shared.summarize(image: image)
                case .voice(let url):
                    result = try await OpenAIService.shared.summarize(audioUrl: url)
                }
                
                self.summaryResult = result
                self.summaryResult = result
                self.saveToAINotes(input: input, result: result)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.showErrorAlert = true
                self.isLoading = false
            }
        }
    }
    
    private func saveToAINotes(input: InputType, result: SummaryResult) {
        var noteType: AINoteType = .text
        var imageToSave: UIImage? = nil
        var originalInputDescription = ""
        
        switch input {
        case .text(let t):
            noteType = .text
            originalInputDescription = t
        case .image(let image):
            noteType = .image
            imageToSave = image
            originalInputDescription = "Hình ảnh chụp từ thiết bị."
        case .voice:
            noteType = .voice
            originalInputDescription = "Bản ghi âm giọng nói (Speech-to-text)."
        }
        
        let cleanLines = result.content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        var parsedTitle = "AI Summary"
        var parsedSubtitle = originalInputDescription
        
        if let firstLine = cleanLines.first {
            parsedTitle = firstLine.replacingOccurrences(of: "**", with: "")
        }
        
        if cleanLines.count > 1 {
            let overviewLine = cleanLines[1]
            let parts = overviewLine.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                parsedSubtitle = String(parts[1]).trimmingCharacters(in: .whitespaces)
            } else {
                parsedSubtitle = overviewLine
            }
        }
        
        AINoteMockData.addNote(
            title: parsedTitle,
            description: parsedSubtitle,
            type: noteType,
            image: imageToSave,
            summary: result.content
        )
    }
}
