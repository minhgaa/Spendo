import Foundation
import SwiftUI
import Alamofire

class AddAccountViewModel: ObservableObject {
    
    struct AccountCreateDto: Encodable {
        let name: String
        let balance: Decimal
    }
    private let baseURL = "http://localhost:5178"
    func createAccount(accountName: String, balance: Decimal, completion: @escaping (Result<Account, Error>) -> Void) {
        let url = "\(baseURL)/Account"
        
        let accountInfo = AccountCreateDto(name: accountName, balance: balance)
        
        AF.request(url, method: .post, parameters: accountInfo, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: Account.self) { response in
                switch response.result {
                case .success(let account):
                    completion(.success(account))
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
}
