import Alamofire
import Foundation

// Your structs
struct User: Decodable, Encodable {
    var email: String
    var currencyId: Int
    var name: String
}

struct Currency: Identifiable, Decodable {
    var id: Int
    var name: String
    var code: String
    var sign: String
    var users: [String]
}

struct Category: Identifiable, Decodable {
    var id: Int
    var name: String
}


class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:5178"
    
    // Fetch all users
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
    
    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let url = "\(baseURL)/Currency"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [Currency].self) { response in
                switch response.result {
                case .success(let currencies):
                    completion(.success(currencies))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func googleLogin(email: String, currencyId: Int, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/User"
        let loginRequest = User(email: email, currencyId: currencyId, name: name)
        
        AF.request(url, method: .post, parameters: loginRequest, encoder: JSONParameterEncoder.default)
            .validate()
            .responseJSON { response in
                print("Response: \(response)")  // In ra phản hồi để kiểm tra
                switch response.result {
                case .success(let data):
                    if let jsonResponse = data as? [String: Any] {
                        if let id = jsonResponse["id"] as? Int,
                           let name = jsonResponse["name"] as? String,
                           let email = jsonResponse["email"] as? String {
                            // Lấy thông tin người dùng thay vì token
                            let userInfo = "ID: \(id), Name: \(name), Email: \(email)"
                            completion(.success(userInfo))
                        } else {
                            // Nếu không có dữ liệu mong đợi trong phản hồi
                            completion(.failure(NSError(domain: "InvalidResponse", code: 1, userInfo: nil)))
                        }
                    }
                case .failure(let error):
                    // Trả về lỗi khi yêu cầu thất bại
                    completion(.failure(error))
                }
            }
    }


}
