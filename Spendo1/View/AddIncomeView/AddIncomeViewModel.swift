import Foundation
import Combine
import Alamofire

struct IncomeCreateDto: Codable {
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: Int
    var categoryid: Int
}
struct Income: Codable {
    var id: Int
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: Int
    var categoryid: Int
    var createdat: String
}


class AddIncomeViewModel: ObservableObject {
    private let baseURL = "http://localhost:5178"
    func createIncome(income: IncomeCreateDto, completion: @escaping (Result<Income, Error>) -> Void) {
        let url = "\(baseURL)/Income"
        
        let parameters: [String: Any] = [
            "title": income.title ?? "",
            "description": income.description ?? "",
            "amount": income.amount,
            "accountId": income.accountid,
            "categoryId": income.categoryid ?? NSNull()
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: Income.self) { response in
                switch response.result {
                case .success(let Income):
                    completion(.success(Income))
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
    func getIncomes(
        accountIds: [Int],
        categoryIds: [Int],
        startDate: Date?,
        endDate: Date?,
        completion: @escaping (Result<[Income], Error>) -> Void
    ) {
        var parameters: [String: Any] = [:]

        // Kiểm tra và thêm accountIds vào parameters nếu mảng không rỗng
        if !accountIds.isEmpty {
            parameters["accountIds"] = accountIds.map { String($0) }
        }

        // Kiểm tra và thêm categoryIds vào parameters nếu mảng không rỗng
        if !categoryIds.isEmpty {
            parameters["categoryIds"] = categoryIds.map { String($0) }
        }

        let formatter = ISO8601DateFormatter()

        // Chỉ thêm startDate vào nếu có giá trị
        if let startDate = startDate {
            parameters["startDate"] = formatter.string(from: startDate)
        }

        // Chỉ thêm endDate vào nếu có giá trị
        if let endDate = endDate {
            parameters["endDate"] = formatter.string(from: endDate)
        }


        let url = "\(baseURL)/Income"
        AF.request(url, method: .get, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                }
                do {
                    let incomes = try JSONDecoder().decode([Income].self, from: data)
                    completion(.success(incomes))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
