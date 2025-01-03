import Foundation
import Alamofire

struct Transfer: Codable {
    var id: Int
    var title: String
    var description: String
    var amount: Decimal
    var sourceAccountId: Int
    var targetAccountId: Int
    var categoryId: Int?
}

struct TransferCreateDto: Codable {
    let title: String?
    let description: String?
    let amount: Decimal
    let sourceAccountId: Int
    let targetAccountId: Int
    let categoryId: Int?
}
class TransferViewModel: ObservableObject {
    private let baseUrl = "http://localhost:5178/Transfer"
        
    func createTransfer(transferInfo: TransferCreateDto, completion: @escaping (Result<Transfer, Error>) -> Void) {
        let url = "\(baseUrl)"
        let parameters: [String: Any] = [
            "title": transferInfo.title ?? "",
            "description": transferInfo.description ?? "",
            "amount": transferInfo.amount,
            "sourceAccountId": transferInfo.sourceAccountId,
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
