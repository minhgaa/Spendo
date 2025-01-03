import Foundation
import Combine
import Alamofire

struct OutcomeCreateDto: Codable {
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: Int
    var categoryid: Int
}
struct Outcome: Codable {
    var id: Int
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: Int
    var categoryid: Int
    var createdat: String
}

class AddOutcomeViewModel: ObservableObject {
    
    private let baseURL = "http://localhost:5178"
    func createOutcome(outcome: OutcomeCreateDto, completion: @escaping (Result<Outcome, Error>) -> Void) {
        let url = "\(baseURL)/Expense"
        
        let parameters: [String: Any] = [
                    "title": outcome.title ?? "",
                    "description": outcome.description ?? "",
                    "amount": outcome.amount,
                    "accountid": outcome.accountid,
                    "categoryid": outcome.categoryid ?? NSNull()
                ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
        accountids: [Int],
        categoryids: [Int],
        startDate: Date?,
        endDate: Date?,
        completion: @escaping (Result<[Outcome], Error>) -> Void
    ) {
        var parameters: [String: Any] = [:]

        if !accountids.isEmpty {
            parameters["accountids"] = accountids.map { String($0) }
        }

        if !categoryids.isEmpty {
            parameters["categoryids"] = categoryids.map { String($0) }
        }

        let formatter = ISO8601DateFormatter()

        if let startDate = startDate {
            parameters["startDate"] = formatter.string(from: startDate)
        }

        if let endDate = endDate {
            parameters["endDate"] = formatter.string(from: endDate)
        }


        let url = "\(baseURL)/Expense"
        AF.request(url, method: .get, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                }
                do {
                    let outcomes = try JSONDecoder().decode([Outcome].self, from: data)
                    completion(.success(outcomes))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
