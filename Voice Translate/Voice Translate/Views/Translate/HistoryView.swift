import SwiftUI

struct HistoryItem: Identifiable {
    let id = UUID()
    let sourceText: String
    let targetText: String
    let sourceLang: String
    let targetLang: String
    let date: String
}

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    let historyData: [HistoryItem] = [
        HistoryItem(sourceText: "Hello, how are you?", targetText: "Xin chào, bạn khỏe không?", sourceLang: "English", targetLang: "Vietnamese", date: "Today"),
        HistoryItem(sourceText: "Nice to meet you", targetText: "Rất vui được gặp bạn", sourceLang: "English", targetLang: "Vietnamese", date: "Yesterday"),
        HistoryItem(sourceText: "Can I have the bill please?", targetText: "Làm ơn cho tôi hoá đơn?", sourceLang: "English", targetLang: "Vietnamese", date: "Oct 12")
    ]
    
    var filteredData: [HistoryItem] {
        if searchText.isEmpty {
            return historyData
        } else {
            return historyData.filter { $0.sourceText.localizedCaseInsensitiveContains(searchText) || $0.targetText.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                Text("My History")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.themeMainText)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.themeMainText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.themeSecondaryText)
                TextField("Search history...", text: $searchText)
                    .foregroundColor(.themeMainText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // History List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredData) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(item.sourceLang) → \(item.targetLang)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.themePrimary)
                                Spacer()
                                Text(item.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.themeSecondaryText)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.sourceText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.themeMainText)
                                Text(item.targetText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.themeSecondaryText)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.themeBackgroundGray.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
