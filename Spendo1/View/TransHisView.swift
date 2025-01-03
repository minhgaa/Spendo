import SwiftUI

struct TransHisView: View {
    @State private var incomes: [Income] = []
    @State private var outcomes: [Outcome] = []
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showPopup = false
    @StateObject private var addIncomeViewModel = AddIncomeViewModel()
    @StateObject private var addOutcomeViewModel = AddOutcomeViewModel()
    
    @State private var selectedTransaction: Transaction? // State to hold the selected transaction
    var accountIds: [Int]

    var body: some View {
        VStack {
            let transactions = (incomes.map { Transaction(income: $0) } + outcomes.map { Transaction(outcome: $0) })
                .sorted {
                    guard let incomeDate = $0.createdat.dateFromISO,
                          let outcomeDate = $1.createdat.dateFromISO else { return false }
                    return incomeDate > outcomeDate // Sort by most recent first
                }
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionRow(
                            title: transaction.title,
                            date: transaction.createdat,
                            amount: transaction.amount,
                            description: transaction.description,
                            category: transaction.category,
                            accountid: transaction.accountid,
                            color: transaction.type == .income ? .green : .red
                        )
                        .onTapGesture {
                            showPopup.toggle()
                            selectedTransaction = transaction
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .onAppear() {
            fetchIncomes(accountIds: accountIds)
            fetchOutcomes(accountIds: accountIds)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }

    func fetchIncomes(accountIds: [Int]) {
        isLoading = true
        errorMessage = ""
        let service = addIncomeViewModel
        
        service.getIncomes(
            accountIds: accountIds, // Truyền mảng `accountIds`
            categoryIds: [],
            startDate: nil,
            endDate: nil
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedIncomes):
                    incomes = fetchedIncomes
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    debugPrint(error)
                }
            }
        }
    }

    func fetchOutcomes(accountIds: [Int]) {
        isLoading = true
        errorMessage = ""
        let service = addOutcomeViewModel
        
        service.getOutcomes(
            accountids: accountIds,
            categoryids: [],
            startDate: nil,
            endDate: nil
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedOutcomes):
                    outcomes = fetchedOutcomes
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    debugPrint(error)
                }
            }
        }
    }
}


extension String {
    var dateFromISO: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}

struct TransactionRow: View {
    var title: String
    var date: String
    var amount: Decimal
    var description: String?
    var category: Int
    var accountid: Int
    var color: Color

    private var formattedTime: String {
        if date.count >= 16 {
            return String(date.dropFirst(11).prefix(5)) // Extract from index 12 to 16
        }
        return date
    }

    var body: some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.2))
                .frame(width: 45, height: 45)
                .cornerRadius(10)
                .overlay(
                    Image(systemName: color == .green ? "arrow.up" : "arrow.down")
                        .foregroundColor(color)
                )
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(formattedTime)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            HStack(alignment: .center, spacing: 2) {
                Text(color == .green ? "+" : "-")
                    .foregroundColor(color)
                Text(String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue))
                    .font(.subheadline)
                    .foregroundColor(color)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

enum TransactionType {
    case income
    case outcome
}

struct Transaction: Identifiable {
    var id: Int
    var title: String
    var description: String?
    var category: Int
    var accountid: Int
    var createdat: String
    var amount: Decimal
    var type: TransactionType
    
    init(income: Income) {
        self.id = income.id
        self.title = income.title
        self.description = income.description
        self.category = income.categoryid
        self.accountid = income.accountid
        self.createdat = income.createdat
        self.amount = income.amount
        self.type = .income
    }
    
    init(outcome: Outcome) {
        self.id = outcome.id
        self.title = outcome.title
        self.description = outcome.description
        self.category = outcome.categoryid
        self.accountid = outcome.accountid
        self.createdat = outcome.createdat
        self.amount = outcome.amount
        self.type = .outcome
    }
}
