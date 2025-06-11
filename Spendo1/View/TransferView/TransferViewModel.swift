import Foundation
import Alamofire

struct Transfer: Codable {
    var id: String
    var title: String
    var description: String
    var amount: Decimal
    var accountId: String
    var targetAccountId: String
    var categoryId: String?
}

struct TransferCreateDto: Codable {
    let title: String?
    let description: String?
    let amount: Decimal
    let accountId: String
    let targetAccountId: String
    let categoryId: String?
}
class TransferViewModel: ObservableObject {
    private let baseUrl = "http://localhost:8080/api/transfer"
        
    func createTransfer(transferInfo: TransferCreateDto, completion: @escaping (Result<Transfer, Error>) -> Void) {
        let url = "\(baseUrl)"
        let parameters: [String: Any] = [
            "title": transferInfo.title ?? "",
            "description": transferInfo.description ?? "",
            "amount": transferInfo.amount,
            "accountId": transferInfo.accountId,
            "targetAccountId": transferInfo.targetAccountId,
            "categoryId": transferInfo.categoryId ?? NSNull()
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()  // Kiểm tra mã trạng thái HTTP là 200-299
            .responseDecodable(of: Transfer.self) { response in
                switch response.result {
                case .success(let transfer):
                    completion(.success(transfer))
                case .failure(let error):
                    completion(.failure(error))  // Trả về lỗi
                }
            }
        
    }
}
