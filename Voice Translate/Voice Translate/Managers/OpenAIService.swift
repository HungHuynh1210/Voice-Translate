import Foundation
import UIKit
import Speech
import Security

// MARK: - Keychain Helper
struct KeychainHelper {
    static let shared = KeychainHelper()
    
    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    func save(_ string: String, service: String, account: String) {
        if let data = string.data(using: .utf8) {
            save(data, service: service, account: account)
        }
    }
    
    func read(service: String, account: String) -> String? {
        let rawData: Data? = read(service: service, account: account)
        if let data = rawData {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
// MARK: - OpenAI Service
class OpenAIService {
    static let shared = OpenAIService()
    
    private var apiKey: String {
        let key: String? = KeychainHelper.shared.read(
            service: "com.voicetranslate.openai",
            account: "apikey"
        )
        if let key = key, !key.isEmpty { return key }
        return "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"
    }
    
    func updateAPIKey(_ newKey: String) {
        KeychainHelper.shared.save(
            newKey,
            service: "com.voicetranslate.openai",
            account: "apikey"
        )
    }
    
    // MARK: - System Prompt (Cải tiến)
    private func systemPrompt(for language: String = "Vietnamese", isDeepAnalysis: Bool = false) -> String {
        return """
        Bạn là trợ lý phân tích và tóm tắt nội dung.

        KHI NHẬN ĐƯỢC ẢNH CHỨA CODE:
        1. Đọc hiểu toàn bộ code trong ảnh
        2. Chọn ra 3 dòng/đoạn quan trọng nhất
        3. Giải thích ngắn gọn từng dòng đó làm gì

        OUTPUT BẮT BUỘC ĐÚNG FORMAT:

        **[Tên màn hình/file]**

        Tổng quan: [1 câu mô tả file/màn hình này làm gì]

        3 dòng code chính:
        - [dòng code 1 ngắn gọn] → [giải thích]
        - [dòng code 2 ngắn gọn] → [giải thích]  
        - [dòng code 3 ngắn gọn] → [giải thích]

        VÍ DỤ:
        **UserGuidePhotoTranslationView**

        Tổng quan: Màn hình hướng dẫn người dùng 
        cách dịch nội dung qua ảnh chụp.

        3 dòng code chính:
        - struct UserGuidePhotoTranslationView → 
          Tạo giao diện hướng dẫn
        - photoTranslationContent: some View → 
          Chứa nội dung hướng dẫn hiển thị
        - VStack(alignment: .leading, spacing: 16) → 
          Sắp xếp nội dung theo chiều dọc
        """
    }

    // MARK: - Summarize Text
    func summarize(text: String, targetLanguage: String = "Vietnamese") async throws -> SummaryResult {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SummarizeError.emptyText
        }
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt(for: targetLanguage)],
                ["role": "user", "content": "Tóm tắt nội dung sau theo đúng format đã yêu cầu: \(text)"]
            ],
            "temperature": 0.5
        ]
        
        return try await fetchAsyncResult(body: body)
    }

    // MARK: - Summarize Image
    func summarize(image: UIImage, targetLanguage: String = "Vietnamese", isDeepAnalysis: Bool = false) async throws -> SummaryResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SummarizeError.unclearImage
        }
        let base64Image = imageData.base64EncodedString()
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt(for: targetLanguage, isDeepAnalysis: isDeepAnalysis)],
                ["role": "user", "content": [
                    [
                        "type": "text",
                        "text": "Hãy trích xuất và tóm tắt hình ảnh này theo đúng định dạng đã yêu cầu."
                    ],
                    [
                        "type": "image_url",
                        "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]
                    ]
                ]]
            ],
            "max_tokens": 500,
            "temperature": 0.5
        ]
        
        return try await fetchAsyncResult(body: body)
    }

    // MARK: - Summarize Voice
    func summarize(audioUrl: URL, targetLanguage: String = "Vietnamese") async throws -> SummaryResult {
        let text = try await transcribeAudioWhisper(url: audioUrl)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SummarizeError.unclearVoice
        }
        return try await summarize(text: text, targetLanguage: targetLanguage)
    }

    // MARK: - Core Fetch
    private func fetchAsyncResult(body: [String: Any]) async throws -> SummaryResult {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw SummarizeError.generic("URL API không hợp lệ.")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw SummarizeError.generic("Định dạng dữ liệu trả về không hợp lệ.")
            }
            
            if let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw SummarizeError.generic("API Error: \(message)")
            }
            
            guard let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw SummarizeError.generic("Không có kết quả từ OpenAI.")
            }
            
            
            return SummaryResult(
                content: content.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
        } catch let error as URLError where error.code == .timedOut {
            throw SummarizeError.timeout
        } catch let error as SummarizeError {
            throw error
        } catch {
            throw SummarizeError.generic(error.localizedDescription)
        }
    }

    // MARK: - Whisper Transcription
    private func transcribeAudioWhisper(url: URL) async throws -> String {
        guard let requestUrl = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
            throw SummarizeError.generic("URL API không hợp lệ.")
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.addValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        var bodyData = Data()
        let audioData = try Data(contentsOf: url)
        
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        bodyData.append("whisper-1\r\n".data(using: .utf8)!)
        
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        bodyData.append(audioData)
        bodyData.append("\r\n".data(using: .utf8)!)
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = bodyData
        request.timeoutInterval = 60
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw SummarizeError.generic("Không thể phân tích dữ liệu trả về từ Whisper API.")
        }
        
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw SummarizeError.generic("Whisper API Error: \(message)")
        }
        
        if let text = json["text"] as? String {
            return text
        } else {
            throw SummarizeError.generic("Không nhận dạng được nội dung giọng nói.")
        }
    }

    // MARK: - Translation (Giữ nguyên, không thay đổi)
    func translate(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String,
        industry: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        You are a professional translator specializing in the \(industry) industry. \
        Translate the following text from \(sourceLanguage) to \(targetLanguage). \
        Only provide the translated text without any quotes or explanations. \
        Text to translate: \(text)
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a helpful translation assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = responseJSON["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                DispatchQueue.main.async {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
