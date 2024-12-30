import Alamofire
import Foundation

struct User: Identifiable, Decodable {
    var id: Int
    var fullName: String
    var email: String
    var password: String
}
struct Account: Identifiable, Codable {
    var id: Int
    var balance: Decimal
    var userID: Int
    var createdAt: Date
    var updatedAt: Date
}


class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:5003" 
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = "\(baseURL)/User"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [User].self) { response in
                switch response.result {
                case .success(let users):
                    completion(.success(users))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func googleLogin(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/User" // Thay URL phù hợp với Backend

        let parameters = ["email": email]

        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    
}
