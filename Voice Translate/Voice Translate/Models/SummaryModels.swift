import UIKit

enum InputType {
    case image(UIImage)
    case text(String)
    case voice(URL)
}

struct SummaryResult {
    var title: String?
    var subtitle: String?
    let content: String
}

enum SummarizeError: Error, LocalizedError {
    case emptyText
    case unclearImage
    case unclearVoice
    case timeout
    case generic(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyText: return "Nội dung văn bản trống, vui lòng nhập nội dung."
        case .unclearImage: return "Không thể xử lý hình ảnh. Vui lòng chụp lại rõ hơn."
        case .unclearVoice: return "Không nhận dạng được giọng nói. Vui lòng ghi âm lại."
        case .timeout: return "Kết nối quá chậm. Vui lòng thử lại."
        case .generic(let msg): return msg
        }
    }
}
