import Foundation
import SwiftUI
import Alamofire

class StatisticViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var cards: [CardItem] = []
    @Published private var outcomes: [Outcome] = []
    struct Category: Identifiable, Hashable, Decodable {
        let id: String
        let name: String
    }
    
    struct CardItem: Identifiable {
        let id: String
        let icon: String
        let title: String
        let amount: Decimal
        let backgroundColor: Color
    }
    
    struct CategoryWithAmount {
        let id: String
        let name: String
        let amount: Decimal
    }
    
    private let baseURL = "http://localhost:8080/api"
    
    func fetchAmount(categoryIds: [String], completion: @escaping (Result<Decimal, Error>) -> Void) {
        let service = AddOutcomeViewModel()
        
        service.getOutcomes(
            accountids: [],
            categoryids: categoryIds,
            startDate: nil,
            endDate: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedOutcomes):
                    self.outcomes = fetchedOutcomes
                    let totalAmount = fetchedOutcomes.reduce(Decimal(0)) { partialResult, outcome in
                        partialResult + outcome.amount
                    }
                    
                    completion(.success(totalAmount))
                    
                case .failure(let error):
                    // Trả về lỗi nếu có
                    completion(.failure(error))
                    
                    print("Error: \(error.localizedDescription)")
                    debugPrint(error)
                }
            }
        }
    }

    
    func fetchCategories(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/category"
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [Category].self) { response in
                switch response.result {
                case .success(let fetchedCategories):
                    DispatchQueue.main.async {
                        self.categories = fetchedCategories
                        let categoriesWithAmounts = fetchedCategories.map { category in
                            var total: Decimal = 0
                            self.fetchAmount(categoryIds: [category.id]) { result in
                                switch result {
                                case .success(let totalAmount):
                                    total = totalAmount
                                case .failure(let error):
                                    print("Lỗi khi lấy dữ liệu: \(error.localizedDescription)")
                                }
                            }
                            return CategoryWithAmount(
                                id: category.id,
                                name: category.name,
                                amount: total
                            )
                        }
                        
                        self.cards = categoriesWithAmounts.enumerated().map { index, item in
                            let isEven = index % 2 == 0
                            return CardItem(
                                id: item.id,
                                icon: "dollarsign.circle.fill",
                                title: item.name,
                                amount: item.amount,
                                backgroundColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F")
                            )
                        }
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
