import Foundation
import Combine
import Alamofire


struct OutcomeCreateDto: Codable {
    var title: String
    var description: String?
    var amount: Decimal
    var accountId: String
    var categoryId: String
}
struct Outcome: Codable {
    let id: String
    let title: String
    let description: String?
    let amount: Decimal
    let createdAt: String
    let updatedAt: String
    let accountId: String
    let accountName: String?
    let categoryId: String?
    let categoryName: String?
}


class AddOutcomeViewModel: ObservableObject {
    
    private let baseURL = "http://localhost:8080/api"
    func createOutcome(outcome: OutcomeCreateDto, completion: @escaping (Result<Outcome, Error>) -> Void) {
        let url = "\(baseURL)/expense"
        
        let parameters: [String: Any] = [
                    "title": outcome.title ?? "",
                    "description": outcome.description ?? "",
                    "amount": outcome.amount,
                    "accountId": outcome.accountId,
                    "categoryId": outcome.categoryId ?? NSNull()
                ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:APIConfig.headers)
            .validate()
            .responseDecodable(of: Outcome.self) { response in
                switch response.result {
                case .success(let outcome):
                    completion(.success(outcome))
                case .failure(let error):
                    if let data = response.data {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw response data: \(jsonString)")
                        }
                    }
                    completion(.failure(error))
                }
            }
    }
    func getOutcomes(
        accountIds: [String],
        categoryIds: [String],
        startDate: Date?,
        endDate: Date?,
        completion: @escaping (Result<[Outcome], Error>) -> Void
    ) {
        var parameters: [String: Any] = [:]

        if !accountIds.isEmpty {
            parameters["accountids"] = accountIds.map { String($0) }
        }

        if !categoryIds.isEmpty {
            parameters["categoryIds"] = categoryIds.map { String($0) }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        if let startDate = startDate {
            parameters["startDate"] = formatter.string(from: startDate)
        }

        if let endDate = endDate {
            parameters["endDate"] = formatter.string(from: endDate)
        }

        let url = "\(baseURL)/expense"
        AF.request(url, method: .get, parameters: parameters, headers: APIConfig.headers).responseData { response in
            switch response.result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Raw response data: \(jsonString)")
                }
                do {
                    let outcomes = try JSONDecoder().decode([Outcome].self, from: data)
                    completion(.success(outcomes))
                } catch {
                    print("❌ Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
