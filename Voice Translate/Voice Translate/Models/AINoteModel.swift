import SwiftUI

enum AINoteType: String, CaseIterable, Equatable, Codable {
    case all = "All"
    case voice = "Voice"
    case text = "Text"
    case image = "Image"
    
    var iconName: String {
        switch self {
        case .voice: return "mic"
        case .text: return "doc.text"
        case .image: return "photo"
        case .all: return ""
        }
    }
}

struct AINote: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let type: AINoteType
    let dateString: String
    let hasAISummary: Bool
    var summaryContent: String = "Tính năng tổng hợp bằng AI giúp tóm tắt nội dung bản dịch một cách nhanh chóng..."
    var imageFileName: String? = nil
    
    var displayDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        
        var parsedDate = formatter.date(from: dateString)
        if parsedDate == nil {
            formatter.locale = Locale.current
            parsedDate = formatter.date(from: dateString)
        }
        if parsedDate == nil {
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            parsedDate = formatter.date(from: dateString)
        }
        
        if let date = parsedDate {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    var relativeDateString: String {
        let formatter = DateFormatter()
        
        // Attempt 1: Strict POSIX (Standard format we try to enforce)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        var parsedDate = formatter.date(from: dateString)
        
        // Attempt 2: Current device locale fallback (For old notes saved without POSIX)
        if parsedDate == nil {
            formatter.locale = Locale.current
            parsedDate = formatter.date(from: dateString)
        }
        
        // Attempt 3: 24-hour style format
        if parsedDate == nil {
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            parsedDate = formatter.date(from: dateString)
        }
        
        if let date = parsedDate {
            let interval = Date().timeIntervalSince(date)
            let minutes = Int(interval / 60)
            if minutes < 1 {
                return "Just now"
            } else if minutes < 60 {
                return "\(minutes)m"
            } else if minutes < 24 * 60 {
                let hours = minutes / 60
                return "\(hours)h"
            } else {
                let days = minutes / (24 * 60)
                return "\(days)d"
            }
        }
        return dateString
    }
    
    func loadImage() -> UIImage? {
        guard let fileName = imageFileName else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}

struct AINoteMockData {
    static let storageKey = "AINotesStorageKey"
    
    static var mockNotes: [AINote] = {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedNotes = try? JSONDecoder().decode([AINote].self, from: data) {
            return savedNotes
        }
        return []
    }()
    
    static func saveNotes() {
        if let encoded = try? JSONEncoder().encode(mockNotes) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    static func addNote(title: String, description: String, type: AINoteType, image: UIImage? = nil, summary: String? = nil) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateStr = formatter.string(from: Date())
        
        var savedFileName: String? = nil
        
        if let image = image, let jpegData = image.jpegData(compressionQuality: 0.8) {
            let fileName = "\(UUID().uuidString).jpg"
            savedFileName = fileName
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            try? jpegData.write(to: url)
        }
        
        let newNote = AINote(
            id: UUID(),
            title: title,
            description: description,
            type: type,
            dateString: dateStr,
            hasAISummary: true,
            summaryContent: summary ?? "Translation Summary (\(type.rawValue)):\n- Source text processed successfully.\n- Detected language translated accurately.\n- Context maintained.",
            imageFileName: savedFileName
        )
        
        mockNotes.insert(newNote, at: 0)
        saveNotes()
    }
}

