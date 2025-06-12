import Alamofire
import Foundation

struct User: Decodable, Encodable {
    var id: String?
    var email: String
    var name: String
    var createdat: String?
    var updatedat: String?
    var currencyId: String?
}

struct UserCreateDto: Encodable {
    let email: String
    let currencyId: String
    let name: String
}

struct Account: Decodable {
    let id: String
    let name: String
    let balance: Decimal
    var userId: String
}

struct Currency: Identifiable, Decodable {
    var id: String
    var name: String?
    var code: String?
    var sign: String?
}

struct Category: Identifiable, Hashable, Decodable {
    var id: String
    var name: String
}

struct LoginRequest: Codable {
    let email: String
}

struct LoginResponse: Codable {
    let token: String
}

struct APIConfig {
    static var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        if let token = UserDefaults.standard.string(forKey: "JWTToken") {
            headers.add(name: "Authorization", value: "Bearer \(token)")
            print("🔐 Token sent: Bearer \(token)")
        } else {
            print("⚠️ No JWT token found in UserDefaults")
        }
        return headers
    }
}

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:8080/api"
    
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
        let url = "\(baseURL)/currency"
        
        let request = AF.request(url, method: .get)

        request
            .validate()
            .responseDecodable(of: [Currency].self) { response in
                // 🔵 Log yêu cầu
                print("📤 [REQUEST]")
                print("🔗 URL: \(url)")
                print("🔧 Method: \(request.request?.httpMethod ?? "unknown")")
                print("📄 Headers: \(request.request?.allHTTPHeaderFields ?? [:])")
                if let body = request.request?.httpBody,
                   let bodyString = String(data: body, encoding: .utf8) {
                    print("📦 Body: \(bodyString)")
                }

                // 🔴 Log kết quả
                switch response.result {
                case .success(let currencies):
                    print("✅ [SUCCESS] Fetched \(currencies.count) currencies")
                    completion(.success(currencies))
                case .failure(let error):
                    print("❌ [FAILURE] Error fetching currencies")
                    print("📄 Status Code: \(response.response?.statusCode ?? -1)")
                    if let data = response.data,
                       let body = String(data: data, encoding: .utf8) {
                        print("📥 Response Body: \(body)")
                    }
                    print("⚠️ Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    func login(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/user/login"
        let parameters = LoginRequest(email: email)
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let loginResponse):
                    // Lưu token vào UserDefaults nếu muốn dùng sau
                    UserDefaults.standard.set(loginResponse.token, forKey: "JWTToken")
                    completion(.success(loginResponse.token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func registerUser(email: String, name: String, currencyid: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/user/signup"
        let userDto = UserCreateDto(email: email, currencyId: currencyid, name: name)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        print("🔵 Registering user with payload:")
        print("Email: \(email)")
        print("Name: \(name)")
        print("CurrencyID: \(currencyid)")
        print("URL: \(url)")
        
        AF.request(url, method: .post, parameters: userDto, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self) { response in
                debugPrint(response)
                
                if let statusCode = response.response?.statusCode {
                    print("🔴 HTTP Status Code: \(statusCode)")
                }
                
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("🔴 Response body:")
                    print(responseString)
                }
                
                switch response.result {
                case .success(let newUser):
                    print("✅ User registered successfully: \(newUser)")
                    completion(.success(newUser))
                case .failure(let error):
                    print("❌ Register error: \(error.localizedDescription)")
                    if let data = response.data,
                       let errorString = String(data: data, encoding: .utf8) {
                        print("Error response body: \(errorString)")
                    }
                    completion(.failure(error))
                }
            }
    }
}
