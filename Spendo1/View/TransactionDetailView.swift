import SwiftUI
import Alamofire

class TransactionDetailViewModel: ObservableObject {
    @Published var transactionDetail: TransactionDetail?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "http://localhost:8080/api"
    
    func fetchTransactionDetail(id: String, type: TransactionType) {
        isLoading = true
        print("🔍 Fetching transaction detail for ID: \(id), Type: \(type)")
        
        let endpoint = type == .income ? "/income/\(id)" : "/expense/\(id)"
        let url = "\(baseURL)\(endpoint)"
        
        AF.request(url, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: TransactionDetail.self) { [weak self] response in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch response.result {
                    case .success(let detail):
                        print("✅ Successfully fetched transaction detail: \(detail)")
                        self?.transactionDetail = detail
                    case .failure(let error):
                        self?.error = error
                        print("❌ Failed to fetch transaction detail: \(error)")
                        if let data = response.data,
                           let jsonString = String(data: data, encoding: .utf8) {
                            print("📄 Response data: \(jsonString)")
                        }
                        if let statusCode = response.response?.statusCode {
                            print("📊 Status code: \(statusCode)")
                        }
                    }
                }
            }
    }
}

struct TransactionDetail: Codable {
    let id: String
    let title: String
    let description: String?
    let amount: Decimal
    let createdAt: String
    let accountId: String
    let accountName: String
    let categoryId: String?
    let categoryName: String?
}

struct TransactionDetailView: View {
    @StateObject private var viewModel = TransactionDetailViewModel()
    @State private var showPopup = false
    var transaction: Transaction
    
    private var backgroundColor: Color {
        return transaction.type == .income ? Color(hex: "#DF835F") : Color(hex: "#3E2449")
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let detail = viewModel.transactionDetail {
                VStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Transaction Details")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top,30)
                        
                        Image(systemName: transaction.type == .income ? "square.and.arrow.down" : "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                        
                        Text("$ \(formatDecimal(detail.amount))")
                            .font(FontScheme.kWorkSansBold(size: 50))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(alignment: .center) {
                            HStack(alignment: .center) {
                                Text(formatDate(detail.createdAt))
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            HStack(alignment: .center) {
                                Image(systemName: "checkmark.seal.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                Text("Successful")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical, 50)
                    
                    VStack(alignment: .center) {
                        HStack {
                            Text("Transaction Details")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "#3E2449"))
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        
                        VStack(spacing: 25) {
                            DetailRow(
                                title: "Title",
                                value: detail.title,
                                icon: "doc.text.fill"
                            )
                            
                            DetailRow(
                                title: "Category",
                                value: detail.categoryName ?? "No Category",
                                icon: "folder.fill"
                            )
                            
                            DetailRow(
                                title: "From",
                                value: detail.accountName,
                                icon: "creditcard.fill"
                            )
                            
                            DetailRow(
                                title: "Description",
                                value: detail.description ?? "No Description",
                                icon: "text.alignleft"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height * 0.55
                    )
                    .background(Color.white)
                    .cornerRadius(30)
                }
                .padding(.horizontal,30)
            } else if let error = viewModel.error {
                Text("Error loading details: \(error.localizedDescription)")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchTransactionDetail(id: transaction.id, type: transaction.type)
        }
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        return String(format: "%.2f", NSDecimalNumber(decimal: value).doubleValue)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // Thử format đầu tiên
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return outputFormatter.string(from: date)
        }
        
        // Nếu format đầu không được, thử format thứ hai
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return outputFormatter.string(from: date)
        }
        
        // Nếu format thứ hai không được, thử format cuối
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: date)
        }
        
        print("⚠️ Could not parse date: \(dateString)")
        return dateString
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "#3E2449"))
                        .font(.system(size: 20))
                    
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                }
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#3E2449"))
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#F6F6F6"))
            )
        }
    }
}
