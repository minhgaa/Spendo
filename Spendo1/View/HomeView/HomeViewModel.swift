import Foundation
import SwiftUI
import Combine
import Alamofire



class HomeViewModel: ObservableObject {
    struct TransItem: Identifiable {
        let id: Int
        let title: String
        let date: String
        let amount: Decimal
        let color: Color
    }
    struct CardItem: Identifiable {
        let id: Int
        let date: String
        let textColor: Color
        let title: String
        let amount: String
        let backgroundColor: Color
        let buttonColor: Color
        let frameColor: Color
    }

    @Published var todayBudget: Decimal = 0
    @Published var todayRemaining: Decimal = 0
    @Published var budgets: [Budget] = []
    private let baseURL = "http://localhost:8080/api"

    let cards: [CardItem]
    let trans: [TransItem]
    
    init() {
        let rawCard = [
            ("16 November 2024", "Electric", "$100",1),
            ("16 November 2024", "Spaylater", "$100",2),
            ("16 November 2024", "Electric", "$100",3),
            ("16 November 2024", "Spaylater", "$100",4),
            ("16 November 2024", "Electric", "$100",5),
            ("16 November 2024", "Spaylater", "$100",6),
        ]
        let rawTrans = [
            ("Mama Bank", "16.11.2024", 1000,1),
            ("Dinner", "16.11.2024", -100,2),
            ("Mama Bank", "16.11.2024", 1000,3),
            ("Dinner", "16.11.2024", -100,4),
            ("Mama Bank", "16.11.2024", 1000,5),
            ("Dinner", "16.11.2024", -100,6),
        ]
        self.cards = rawCard.enumerated().map { index, item in
            let isEven = index % 2 == 0
            return CardItem(
                id: item.3,
                date: item.0,
                textColor: isEven ? Color(hex: "#B284C6") : Color(hex: "#EEC0AE"),
                title: item.1,
                amount: item.2,
                backgroundColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F"),
                buttonColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F"),
                frameColor: isEven ? Color(hex: "#926EA1") : Color(hex: "#F1BE7B")
            )
        }
        self.trans = rawTrans.enumerated().map { index, item in
            let isRed = Float(item.2) < 0
            return TransItem(
                id: item.3,
                title: item.0,
                date: item.1,
                amount: Decimal(item.2),
                color: isRed ? .red : .green)
        }
        
        fetchBudgets()
    }
    
    func fetchBudgets() {
        let url = "\(baseURL)/budget"
        
        AF.request(url, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: [Budget].self) { [weak self] response in
                switch response.result {
                case .success(let budgets):
                    DispatchQueue.main.async {
                        self?.budgets = budgets
                        self?.calculateTodayBudget()
                        self?.fetchTodayOutcomes()
                    }
                case .failure(let error):
                    print("❌ Failed to fetch budgets: \(error)")
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Response data: \(jsonString)")
                    }
                }
            }
    }
    
    private func calculateTodayBudget() {
        // Tính tổng budget limit của tất cả budgets
        todayBudget = budgets.reduce(Decimal(0)) { $0 + $1.budgetLimit }
    }
    
    private func fetchTodayOutcomes() {
        let outcomeViewModel = AddOutcomeViewModel()
        let today = Date()
        
        outcomeViewModel.getOutcomes(
            accountIds: [],
            categoryIds: budgets.map { $0.categoryId ?? "" },
            startDate: Calendar.current.startOfDay(for: today),
            endDate: today
        ) { [weak self] result in
            switch result {
            case .success(let outcomes):
                let totalOutcome = outcomes.reduce(Decimal(0)) { $0 + $1.amount }
                DispatchQueue.main.async {
                    self?.todayRemaining = (self?.todayBudget ?? 0) - totalOutcome
                }
            case .failure(let error):
                print("❌ Failed to fetch outcomes: \(error)")
            }
        }
    }
}
