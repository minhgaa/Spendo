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
    
    // Lấy ngân sách theo ID
    func getBudget(byId id: String) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .get)
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
    
    func getBudget(bycategoryId categoryid: String) {
        isLoading = true
        errorMessage = nil

        let url = "\(baseUrl)/category/\(categoryid)"

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: Budget.self) { response in
                self.isLoading = false
                switch response.result {
                case .success(let budget):
                    self.budgetcate = budget
                case .failure(let error):
                    self.errorMessage = "Error budgets: \(error.localizedDescription)"
                }
            }
    }
    func getBudgets() {
        isLoading = true
        errorMessage = nil
        
        let userId = 1
        
        let url = "\(baseUrl)?userId=\(userId)"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [Budget].self) { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success(let budgets):
                    self?.budgets = budgets
                case .failure(let error):
                    self?.errorMessage = "Error fetching budgets: \(error.localizedDescription)"
                }
            }
    }
    
    func createBudget(budgetInfo: BudgetCreateDto, completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        
        let url = baseUrl
        
        AF.request(url, method: .post, parameters: budgetInfo, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: Budget.self) { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success(let budget):
                    self?.budgets.append(budget)
                    print("Budget created successfully.")
                case .failure(let error):
                    print("Failed to create budget: \(error.localizedDescription)")
                }
                completion() 
            }
    }

    
    func updateBudget(id: String, budgetInfo: BudgetCreateDto) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .put, parameters: budgetInfo, encoder: JSONParameterEncoder.default)
            .validate()
            .response { [weak self] response in
                self?.isLoading = false
                switch response.result {
                case .success:
                    self?.getBudget(byId: id) // Cập nhật lại ngân sách sau khi thay đổi
                case .failure(let error):
                    self?.errorMessage = "Error updating budget: \(error.localizedDescription)"
                }
            }
    }
    
    // Xóa ngân sách
    func deleteBudget(id: String) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(baseUrl)/\(id)"
        
        AF.request(url, method: .delete)
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
}
