import Foundation
import Alamofire
import Combine

// Model for BudgetCreateDto
struct BudgetCreateDto: Codable {
    let name: String
    let startDate: String
    let period: Int
    let budgetLimit: Decimal
    let categoryId: String?
    let userId: String
}

// Model for Budget
struct Budget: Codable, Identifiable {
    let id: String
    let name: String
    let startDate: String
    let endDate: String
    let current: Decimal
    let budgetLimit: Decimal
    let period: Int
    let categoryId: String?

}

// Model cho response của User
struct UserResponse: Codable {
    let id: String
    let name: String?
    let email: String?
    let createdat: String?
    let updatedat: String?
    let currencyid: String?
}

// Model cho response của Category
struct CategoryResponse: Codable {
    let id: String
    let name: String?
}

// ViewModel for Budget
class BudgetViewModel: ObservableObject {
    private let baseUrl = "http://localhost:8080/api/budget"
    
    // Published properties to bind data
    @Published var budgets: [Budget] = []
    @Published var budgetcate: Budget? = nil
    @Published var selectedBudget: Budget? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func getBudgets() {
        isLoading = true
        errorMessage = nil
        
        
        AF.request(baseUrl, method: .get, headers: APIConfig.headers)
            .validate()
            .responseData { [weak self] response in
                self?.isLoading = false
                
                
                if let error = response.error {
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("🔴 Error response body: \(str)")
                    }
                    
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("🔴 Raw Response Data:")
                    print(responseString)
                    
                    if let json = try? JSONSerialization.jsonObject(with: data),
                       let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                       let prettyString = String(data: prettyData, encoding: .utf8) {
                        print("🔵 Pretty JSON structure:")
                        print(prettyString)
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let budgets = try decoder.decode([Budget].self, from: data)
                        print("✅ Successfully decoded \(budgets.count) budgets")
                        self?.budgets = budgets
                    } catch {
                        print("❌ Decoding error: \(error)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Missing key: \(key)")
                                print("Context: \(context)")
                            case .typeMismatch(let type, let context):
                                print("Type mismatch: expected \(type)")
                                print("Context: \(context)")
                            case .valueNotFound(let type, let context):
                                print("Value not found: expected \(type)")
                                print("Context: \(context)")
                            case .dataCorrupted(let context):
                                print("Data corrupted: \(context)")
                            @unknown default:
                                print("Unknown decoding error")
                            }
                        }
                        self?.errorMessage = "Error decoding budgets: \(error.localizedDescription)"
                    }
                } else {
                    print("❌ No response data received")
                    self?.errorMessage = "No data received from server"
                }
            }
    }
    
    func createBudget(budgetInfo: BudgetCreateDto, completion: @escaping () -> Void ) {
        isLoading = true
        errorMessage = nil
        
        let url = baseUrl
        
        print("🔵 Creating budget with payload:")
        print("Name: \(budgetInfo.name)")
        print("Start Date: \(budgetInfo.startDate)")
        print("Period: \(budgetInfo.period)")
        print("Budget Limit: \(budgetInfo.budgetLimit)")
        print("Category ID: \(budgetInfo.categoryId ?? "nil")")
        print("User ID: \(budgetInfo.userId)")
        print("URL: \(url)")
        
        AF.request(url, method: .post, parameters: budgetInfo, encoder: JSONParameterEncoder.default, headers: APIConfig.headers)
            .validate()
            .responseData { [weak self] response in
                self?.isLoading = false
                
                print("🔴 Response Status Code: \(response.response?.statusCode ?? -1)")
                
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("🔴 Response body:")
                    print(responseString)
                    
                    do {
                        let decoder = JSONDecoder()
                        let budget = try decoder.decode(Budget.self, from: data)
                        print("✅ Budget created successfully: \(budget)")
                        self?.budgets.append(budget)
                    } catch {
                        print("❌ Failed to decode budget:")
                        print("Error: \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Missing key: \(key)")
                                print("Context: \(context)")
                            case .typeMismatch(let type, let context):
                                print("Type mismatch: expected \(type)")
                                print("Context: \(context)")
                            case .valueNotFound(let type, let context):
                                print("Value not found: expected \(type)")
                                print("Context: \(context)")
                            case .dataCorrupted(let context):
                                print("Data corrupted: \(context)")
                            @unknown default:
                                print("Unknown decoding error")
                            }
                        }
                        self?.errorMessage = "Failed to create budget: \(error.localizedDescription)"
                    }
                }
                completion() 
            }
    }
    
    func getBudget(byId id: String) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .get, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: Budget.self) { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success(let budget):
                    self?.selectedBudget = budget
                case .failure(let error):
                    self?.errorMessage = "Error fetching budget: \(error.localizedDescription)"
                }
            }
    }
    
    func getBudget(bycategoryId categoryid: String, completion: @escaping (Result<Budget, Error>) -> Void) {
        isLoading = true
        errorMessage = nil

        let url = baseUrl
        let parameters: [String: Any] = ["categoryIds": [categoryid]]
        
        print("🔍 Fetching budget for category: \(categoryid)")
        print("URL: \(url)")
        print("Parameters: \(parameters)")

        AF.request(url, 
                  method: .get,
                  parameters: parameters,
                  headers: APIConfig.headers)
            
            .responseDecodable(of: [Budget].self) { response in
                self.isLoading = false
                
                // Log response for debugging
                print("Response status code: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let str = String(data: data, encoding: .utf8) {
                    print("Response data: \(str)")
                }
                
                switch response.result {
                case .success(let budgets):
                    if let firstBudget = budgets.first {
                        print("✅ Budget found: \(firstBudget)")
                        self.budgetcate = firstBudget
                        completion(.success(firstBudget))
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No budget found for category"])
                        print("❌ No budget found")
                        self.errorMessage = "No budget found for category"
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("❌ Error fetching budget: \(error)")
                    self.errorMessage = "Error budgets: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
    }
    
    func updateBudget(id: String, budgetInfo: BudgetCreateDto) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .put, parameters: budgetInfo, encoder: JSONParameterEncoder.default, headers: APIConfig.headers)
            .validate()
            .response { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success:
                    self?.getBudget(byId: id)
                    self?.getBudgets() // Refresh lại danh sách budget
                case .failure(let error):
                    self?.errorMessage = "Error updating budget: \(error.localizedDescription)"
                }
            }
    }
    
    
    func deleteBudget(id: String) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .delete, headers: APIConfig.headers)
            .validate()
            .response { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success:
                    self?.budgets.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = "Error deleting budget: \(error.localizedDescription)"
                }
            }
    }
    
    func updateBudgetCurrent(categoryId: String, amount: Decimal) {
        guard let budget = budgets.first(where: { $0.categoryId == categoryId }) else {
            print("❌ Không tìm thấy budget cho category: \(categoryId)")
            return
        }
        
        print("🔄 Cập nhật current cho budget: \(budget.id)")
        print("Amount: \(amount)")
        
        let budgetInfo = BudgetCreateDto(
            name: budget.name,
            startDate: budget.startDate,
            period: budget.period,
            budgetLimit: budget.budgetLimit,
            categoryId: budget.categoryId,
            userId: UserDefaults.standard.string(forKey: "userId") ?? ""
        )
        
        updateBudget(id: budget.id, budgetInfo: budgetInfo)
    }
    
}
