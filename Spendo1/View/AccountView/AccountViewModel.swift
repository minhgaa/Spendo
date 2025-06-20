import Foundation
import SwiftUI
import Alamofire

class AccountViewModel: ObservableObject {
    struct Account: Identifiable, Decodable {
        let id: String
        let name: String
        let balance: Decimal
    }
    
    struct AccountItem: Identifiable {
        let id : String
        let icon: String
        let title: String
        let balance: Decimal
        let income: Decimal
        let outcome: Decimal
        let backgroundColor: Color
    }
    
    
    @Published var account: [AccountItem] = []
    
    private let baseURL = "http://localhost:8080/api/"
    
    func getAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)account"

        var headers: HTTPHeaders = []
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            headers.add(name: "Authorization", value: "Bearer \(token)")
            print("🔐 Token sent: Bearer \(token)")
        } else {
            print("⚠️ No JWT token found in UserDefaults")
        }

        AF.request(url, method: .get, headers: headers)
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
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ Raw error response: \(jsonString)")
                    }
                    print("❌ Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    func deleteAccount(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)account/\(id)"
        print("🔗 Attempting to delete account with URL: \(url)")
        print("🆔 Account ID: \(id)")
        
        AF.request(url, method: .delete, headers: APIConfig.headers)
            .validate()
            .response { response in
                print("📡 Response status code: \(response.response?.statusCode ?? -1)")
                print("📝 Response headers: \(response.response?.headers ?? HTTPHeaders())")
                
                if let data = response.data,
                   let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Response data: \(jsonString)")
                }
                
                switch response.result {
                case .success:
                    print("✅ Account deleted successfully")
                    DispatchQueue.main.async {
                        self.getAccount { _ in }  // Refresh account list after deletion
                        completion(.success(()))
                    }
                    
                case .failure(let error):
                    print("❌ Failed to delete account: \(error.localizedDescription)")
                    print("❌ Error details: \(error)")
                    if let underlyingError = error.underlyingError {
                        print("🔍 Underlying error: \(underlyingError)")
                    }
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }
    
}
