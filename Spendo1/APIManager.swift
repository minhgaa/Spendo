import Alamofire
import Foundation

// Your structs
struct User: Decodable, Encodable {
    var email: String
    var currencyid: Int
    var name: String
}
struct Account: Decodable {
    let id: Int
    let name: String
    let balance: Decimal
    var userId: Int
}

struct Currency: Identifiable, Decodable {
    var id: Int
    var name: String
    var code: String
    var sign: String
    var users: [String]
}



struct Category: Identifiable, Hashable, Decodable {
    var id: Int
    var name: String
}


class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:5178"
    
    func sendAPIRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Lấy JWT token từ UserDefaults
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Gửi request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 500, userInfo: nil)))
                return
            }
            
            // Giải mã JSON
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
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
    
    
    
    func login(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        // URL API login
        let url = "\(baseURL)/User/login"
        
        
        let parameters: String = email
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let token):
                    completion(.success(token))
                case .failure(let error):
                    
                    completion(.failure(error))
                }
            }
    }
    
    func registerUser(email: String, name: String, currencyid: Int, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/User"
        let user = User(email: email, currencyid: currencyid, name: name)
        AF.request(url, method: .post, parameters: user, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: User.self) { response in
                debugPrint(response)
                switch response.result {
                case .success(let newUser):
                    completion(.success(newUser))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
