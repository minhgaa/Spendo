import SwiftUI
import Alamofire

struct AccountDetailView: View {
    @Binding var isPresented: Bool
    @State private var errorMessage: String? = nil
    @State private var showDeleteConfirmation = false
    @State private var totalIncome: Decimal = 0
    @State private var totalOutcome: Decimal = 0
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountSelectionManager: AccountSelectionManager
    @StateObject private var accountViewModel = AccountViewModel()
    @State private var incomes: [Income] = []
    @State private var outcomes: [Outcome] = []
    @State private var transfers: [Transfer] = []
    @State private var isLoading: Bool = false
    @StateObject private var addIncomeViewModel = AddIncomeViewModel()
    @StateObject private var addOutcomeViewModel = AddOutcomeViewModel()
    
    var body: some View {
        if let account = accountSelectionManager.selectedAccount {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)
                    .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                               bottomLeft: 40, bottomRight: 40)
                        .fill(Color.red))
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical)
                .padding(.top)
                
                Text(account.title)
                    .font(FontScheme.kWorkSansBold(size: 25))
                    .padding(.leading)
                
                HStack(alignment: .center) {
                    Text(String(format: "%.2f", NSDecimalNumber(decimal: account.balance).doubleValue))
                        .font(FontScheme.kWorkSansBold(size: 50))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("VND")
                        .font(FontScheme.kWorkSansBold(size: 20))
                        .foregroundColor(.black)
                }
                .padding()
                
                HStack(alignment: .center, spacing: 10) {
                    // Income Section
                    VStack(alignment: .center) {
                        Text("INCOME")
                            .font(FontScheme.kWorkSansBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.bottom,10)
                            .padding(.top,20)
                        VStack(alignment: .center) {
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: totalIncome).doubleValue))
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("VND")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        VStack(alignment: .center) {
                            Text("\(incomes.count)")
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("Transactions")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        Spacer()
                        
                    }
                    .frame(width: 170, height: 200)
                    .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                               bottomLeft: 40, bottomRight: 40)
                        .fill(Color(hex: "#DF835F")))
                    
                    // Outcome Section
                    VStack(alignment: .center) {
                        Text("OUTCOME")
                            .font(FontScheme.kWorkSansBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.bottom,10)
                            .padding(.top,20)
                        VStack(alignment: .center) {
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: totalOutcome).doubleValue))
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("VND")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        VStack(alignment: .center) {
                            Text("\(outcomes.count)")
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("Transactions")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        Spacer()
                    }
                    .frame(width: 170, height: 200)
                    .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                               bottomLeft: 40, bottomRight: 40)
                        .fill(Color(hex: "#3E2449")))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.red)
                }

                // Add Transaction History Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Transaction History")
                        .font(FontScheme.kWorkSansBold(size: 24))
                        .foregroundColor(Color(hex: "#3E2449"))
                        .padding(.top, 20)
                        .padding(.horizontal)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(incomes.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { income in
                                    TransactionItemView(
                                        title: income.title,
                                        amount: income.amount,
                                        date: formatDate(income.createdAt),
                                        isIncome: true
                                    )
                                }
                                
                                ForEach(outcomes.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { outcome in
                                    TransactionItemView(
                                        title: outcome.title,
                                        amount: outcome.amount,
                                        date: formatDate(outcome.createdAt),
                                        isIncome: false
                                    )
                                }

                                ForEach(transfers.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { transfer in
                                    TransactionItemView(
                                        title: "Transfer to \(transfer.toAccountName)",
                                        amount: transfer.amount,
                                        date: formatDate(transfer.createdAt),
                                        isTransfer: true
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 400)
                    }
                }
                .background(Color(hex: "#F6F6F6"))
                .cornerRadius(20)
                
            }
            .padding()
            .hideNavigationBar()
            .onAppear() {
                if let accountId = accountSelectionManager.selectedAccount?.id {
                    fetchIncomes(accountIds: [accountId])
                    fetchOutcomes(accountIds: [accountId])
                    fetchTransfers(accountId: accountId)
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Confirmation"),
                    message: Text("Are you sure you want to delete account \"\(account.title)\"?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAccount(id: account.id)
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }
    func fetchIncomes(accountIds: [String]) {
        isLoading = true
        errorMessage = ""
        let service = addIncomeViewModel
        
        service.getIncomes(
            accountIds: accountIds,
            categoryIds: [],
            startDate: nil,
            endDate: nil
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedIncomes):
                    self.incomes = fetchedIncomes
                    self.totalIncome = fetchedIncomes.reduce(Decimal(0)) { $0 + $1.amount }
                    print("Total Income: \(self.totalIncome)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    debugPrint(error)
                }
            }
        }
    }

    func fetchOutcomes(accountIds: [String]) {
        isLoading = true
        errorMessage = ""
        let service = addOutcomeViewModel
        
        service.getOutcomes(
            accountIds: accountIds,
            categoryIds: [],
            startDate: nil,
            endDate: nil
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedOutcomes):
                    self.outcomes = fetchedOutcomes
                    self.totalOutcome = fetchedOutcomes.reduce(Decimal(0)) { $0 + $1.amount }
                    print("Total Outcome: \(self.totalOutcome)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    debugPrint(error)
                }
            }
        }
    }

    func fetchTransfers(accountId: String) {
        isLoading = true
        let url = "http://localhost:8080/api/transfer"
        let parameters: [String: Any] = ["accountIds": [accountId]]
        
        AF.request(url, parameters: parameters, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: [Transfer].self) { response in
                DispatchQueue.main.async {
                    isLoading = false
                    switch response.result {
                    case .success(let fetchedTransfers):
                        self.transfers = fetchedTransfers
                    case .failure(let error):
                        print("Error fetching transfers: \(error)")
                        debugPrint(error)
                    }
                }
            }
    }

    func deleteAccount(id: String) {
        errorMessage = nil
        
        accountViewModel.deleteAccount(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Account deleted successfully")
                    isPresented = false
                case .failure(let error):
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    isPresented = false
                }
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct TransactionItemView: View {
    let title: String
    let amount: Decimal
    let date: String
    let isIncome: Bool
    let isTransfer: Bool
    
    init(title: String, amount: Decimal, date: String, isIncome: Bool, isTransfer: Bool = false) {
        self.title = title
        self.amount = amount
        self.date = date
        self.isIncome = isIncome
        self.isTransfer = isTransfer
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Circle()
                    .fill(isTransfer ? Color.blue : (isIncome ? Color(hex: "#DF835F") : Color(hex: "#3E2449")))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: isTransfer ? "arrow.right" : (isIncome ? "arrow.down" : "arrow.up"))
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    Text(date)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(formatAmount(amount))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isTransfer ? Color.blue : (isIncome ? Color(hex: "#DF835F") : Color(hex: "#3E2449")))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let amountString = formatter.string(from: NSDecimalNumber(decimal: abs(amount))) ?? "0.00"
        return isIncome ? "+\(amountString)" : "-\(amountString)"
    }
}
