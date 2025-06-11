import Foundation
import Combine
import Alamofire

struct IncomeCreateDto: Codable {
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: String
    var categoryid: String
}
struct Income: Codable {
    var id: String
    var title: String
    var description: String?
    var amount: Decimal
    var accountid: String
    var categoryid: String
    var createdat: String
}


class AddIncomeViewModel: ObservableObject {
    private let baseURL = "http://localhost:8080/api"
    func createIncome(income: IncomeCreateDto, completion: @escaping (Result<Income, Error>) -> Void) {
        let url = "\(baseURL)/income"
        var headers: HTTPHeaders = []
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            headers.add(name: "Authorization", value: "Bearer \(token)")
            print("🔐 Token sent: Bearer \(token)")
        } else {
            print("⚠️ No JWT token found in UserDefaults")
        }

        let parameters: [String: Any] = [
            "title": income.title ?? "",
            "description": income.description ?? "",
            "amount": income.amount,
            "accountId": income.accountid,
            "categoryId": income.categoryid ?? NSNull()
        ]

        print("📤 Sending parameters: \(parameters)")

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Income.self) { response in
                switch response.result {
                case .success(let income):
                    print("✅ Income created: \(income)")
                    completion(.success(income))

                case .failure(let error):
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ Raw response data: \(jsonString)")
                    }
                    if let httpResponse = response.response {
                        print("❌ HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    print("❌ Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    func getIncomes(
        accountIds: [String],
        categoryIds: [String],
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
        var headers: HTTPHeaders = []
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            headers.add(name: "Authorization", value: "Bearer \(token)")
            print("🔐 Token sent: Bearer \(token)")
        } else {
            print("⚠️ No JWT token found in UserDefaults")
        }


        let url = "\(baseURL)/income"
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseData { response in
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
