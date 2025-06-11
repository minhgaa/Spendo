import Foundation
import SwiftUI
import Alamofire

class AddAccountViewModel: ObservableObject {
    
    struct AccountCreateDto: Encodable {
        let name: String
        let balance: Decimal
    }
    private let baseURL = "http://localhost:8080/api"
    func createAccount(accountName: String, balance: Decimal, completion: @escaping (Result<Account, Error>) -> Void) {
        let url = "\(baseURL)/account"
        let accountInfo = AccountCreateDto(name: accountName, balance: balance)

        var headers: HTTPHeaders = []
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        AF.request(url, method: .post, parameters: accountInfo, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: Account.self) { response in
                switch response.result {
                case .success(let account):
                    completion(.success(account))
                case .failure(let error):
                    if let data = response.data, let json = String(data: data, encoding: .utf8) {
                        print("🚨 Raw response: \(json)")
                    }
                    completion(.failure(error))
                }
            }
    }
}
