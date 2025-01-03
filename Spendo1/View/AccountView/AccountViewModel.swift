import Foundation
import SwiftUI
import Alamofire

class AccountViewModel: ObservableObject {
    struct Account: Identifiable, Decodable {
        let id: Int
        let name: String
        let balance: Decimal
    }
    
    struct AccountItem: Identifiable {
        let id : Int
        let icon: String
        let title: String
        let balance: Decimal
        let income: Decimal
        let outcome: Decimal
        let backgroundColor: Color
    }
    
    
    @Published var account: [AccountItem] = []
    
    private let baseURL = "http://localhost:5178"
    
    func getAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/Account"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [Account].self) { response in
                switch response.result {
                case .success(let accounts):
                    DispatchQueue.main.async {
                        self.account = accounts.enumerated().map { index, item in
                            let isEven = index % 2 == 0
                            return AccountItem(
                                id: item.id,
                                icon: "dollarsign.circle.fill",
                                title: item.name,
                                balance: item.balance,
                                income: item.balance,
                                outcome: 0, 
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
    func deleteAccount(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/Account/\(id)"
        AF.request(url, method: .delete)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Account deleted successfully")
                    completion(.success(()))
                    
                case .failure(let error):
                    print("Failed to delete account: \(error.localizedDescription)")
                    completion(.failure(error))  // Lỗi
                }
            }
    }
    struct AccountCreateDto: Encodable {
        let name: String
        let balance: Decimal
    }
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
