import Foundation
import SwiftUI
import Alamofire
import Combine

// MARK: - Models
struct StatisticResponse: Codable {
    let dailySummaries: [DailySummary]
    let categorySpending: [CategorySpending]
}

struct DailySummary: Codable {
    let date: String
    let totalIncome: Decimal
    let totalExpense: Decimal
    let netAmount: Decimal
}

struct CategorySpending: Codable {
    let id: String?
    let name: String?
    let expense: Decimal
}

class StatisticViewModel: ObservableObject {
    @Published var dailySummaries: [DailySummary] = []
    @Published var categorySpending: [CategorySpending] = []
    @Published var selectedDuration: Int = 7 // Default to week view
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var cards: [CardItem] = []
    
    private let baseURL = "http://localhost:8080/api"
    private var cancellables = Set<AnyCancellable>()
    
    struct CardItem: Identifiable {
        let id: String
        let icon: String
        let title: String
        let amount: Decimal
        let backgroundColor: Color
    }
    
    // MARK: - Public Methods
    func fetchStatistics() {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseURL)/statistic"
        let parameters: [String: Any] = ["duration": selectedDuration]
        
        AF.request(url, method: .get, parameters: parameters, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: StatisticResponse.self) { [weak self] response in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch response.result {
                    case .success(let data):
                        self?.dailySummaries = data.dailySummaries
                        self?.categorySpending = data.categorySpending
                        self?.updateCards()
                        
                    case .failure(let error):
                        print("❌ Error fetching statistics: \(error.localizedDescription)")
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("🔴 Error response body: \(str)")
                        }
                        self?.errorMessage = "Không thể tải dữ liệu thống kê: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    func updateDuration(for tab: String) {
        switch tab {
        case "Week":
            selectedDuration = 7
        case "Month":
            selectedDuration = 30
        case "Year":
            selectedDuration = 365
        default:
            selectedDuration = 7
        }
        fetchStatistics()
    }
    
    // MARK: - Private Methods
    private func updateCards() {
        cards = categorySpending.enumerated().compactMap { index, category in
            guard let name = category.name else { return nil }
            let isEven = index % 2 == 0
            return CardItem(
                id: category.id ?? UUID().uuidString,
                icon: "dollarsign.circle.fill",
                title: name,
                amount: category.expense,
                backgroundColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F")
            )
        }
    }
    
    // MARK: - Helper Methods
    func getTotalSpending() -> Decimal {
        dailySummaries.reduce(Decimal(0)) { $0 + $1.totalExpense }
    }
    
    func getChartData() -> [(date: String, income: Decimal, expense: Decimal)] {
        dailySummaries.map { summary in
            (date: formatDate(summary.date),
             income: summary.totalIncome,
             expense: summary.totalExpense)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}
