import SwiftUI
import Alamofire

struct TransHisView: View {
    @StateObject private var viewModel = TransHisViewModel()
    var accountIds: [String]
    var startDate: Date
    var endDate: Date
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.fetchTransactions(accountIds: accountIds, startDate: startDate, endDate: endDate)
        }
        .onChange(of: startDate) { _ in
            viewModel.fetchTransactions(accountIds: accountIds, startDate: startDate, endDate: endDate)
        }
        .onChange(of: endDate) { _ in
            viewModel.fetchTransactions(accountIds: accountIds, startDate: startDate, endDate: endDate)
        }
    }
}

class TransHisViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let incomeViewModel = AddIncomeViewModel()
    private let outcomeViewModel = AddOutcomeViewModel()
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func fetchTransactions(accountIds: [String], startDate: Date, endDate: Date) {
        isLoading = true
        transactions = []
        
        let group = DispatchGroup()
        var allTransactions: [Transaction] = []
        
        let formattedStartDate = formatDateForAPI(startDate)
        let formattedEndDate = formatDateForAPI(endDate)
        
        print("🔍 Fetching transactions")
        print("📅 API start date: \(formattedStartDate)")
        print("📅 API end date: \(formattedEndDate)")
        
        group.enter()
        incomeViewModel.getIncomes(
            accountIds: accountIds,
            categoryIds: [],
            startDate: startDate,
            endDate: endDate
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let incomes):
                print("✅ Fetched \(incomes.count) incomes")
                if !incomes.isEmpty {
                    allTransactions.append(contentsOf: incomes.map { income in
                        Transaction(
                            id: income.id,
                            title: income.title,
                            description: income.description,
                            amount: income.amount,
                            createdat: self.formatDate(income.createdAt),
                            type: .income
                        )
                    })
                }
            case .failure(let error):
                print("❌ Failed to fetch incomes: \(error)")
                if let afError = error.asAFError {
                    switch afError {
                    case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                        print("ℹ️ No incomes found for this period")
                    case .responseValidationFailed(reason: let reason):
                        print("🚫 Validation failed: \(reason)")
                    case .responseSerializationFailed(reason: let reason):
                        print("🚫 Serialization failed: \(reason)")
                    default:
                        if let underlyingError = afError.underlyingError as? URLError {
                            print("🌐 URL Error: \(underlyingError.localizedDescription)")
                        }
                        print("❌ Other error: \(afError.localizedDescription)")
                    }
                }
            }
            group.leave()
        }
        
        group.enter()
        outcomeViewModel.getOutcomes(
            accountIds: accountIds,
            categoryIds: [],
            startDate: startDate,
            endDate: endDate
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let outcomes):
                print("✅ Fetched \(outcomes.count) outcomes")
                if !outcomes.isEmpty {
                    allTransactions.append(contentsOf: outcomes.map { outcome in
                        Transaction(
                            id: outcome.id,
                            title: outcome.title,
                            description: outcome.description,
                            amount: outcome.amount,
                            createdat: self.formatDate(outcome.createdAt),
                            type: .outcome
                        )
                    })
                }
            case .failure(let error):
                print("❌ Failed to fetch outcomes: \(error)")
                if let afError = error.asAFError {
                    switch afError {
                    case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                        print("ℹ️ No outcomes found for this period")
                    case .responseValidationFailed(reason: let reason):
                        print("🚫 Validation failed: \(reason)")
                    case .responseSerializationFailed(reason: let reason):
                        print("🚫 Serialization failed: \(reason)")
                    default:
                        if let underlyingError = afError.underlyingError as? URLError {
                            print("🌐 URL Error: \(underlyingError.localizedDescription)")
                        }
                        print("❌ Other error: \(afError.localizedDescription)")
                    }
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.transactions = allTransactions.sorted { $0.createdat > $1.createdat }
            print("📊 Total transactions loaded: \(self.transactions.count)")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(transaction.createdat)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatAmount(transaction.amount))
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .green : .red)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .sheet(isPresented: $showDetail) {
            TransactionDetailView(transaction: transaction)
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

struct Transaction: Identifiable {
    let id: String
    let title: String
    let description: String?
    let amount: Decimal
    let createdat: String
    let type: TransactionType
}

enum TransactionType {
    case income
    case outcome
}
