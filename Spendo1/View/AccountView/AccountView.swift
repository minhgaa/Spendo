import SwiftUI
import Alamofire

struct AccountView: View {
    @StateObject var accountViewModel = AccountViewModel()
    @State private var error: Error? = nil
    @State private var showPopup = false
    @State private var showPopup1 = false
    @State private var incomes: [Income] = []
    @State private var outcomes: [Outcome] = []
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var accountTotals: [String: (income: Decimal, outcome: Decimal)] = [:]
    @StateObject private var addIncomeViewModel = AddIncomeViewModel()
    @StateObject private var addOutcomeViewModel = AddOutcomeViewModel()
    @StateObject private var accountSelectionManager = AccountSelectionManager()
    
    private var startDate: Date {
        // Lấy ngày đầu tiên của tháng hiện tại
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    private var endDate: Date {
        // Lấy ngày cuối cùng của tháng hiện tại
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startDate) ?? Date()
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? Date()
        return endOfMonth
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func fetchAccountTransactions(for accountId: String) {
        // Fetch incomes
        let url = "http://localhost:8080/api/income"
        let parameters: [String: Any] = ["accountIds": [accountId]]
        
        AF.request(url, parameters: parameters, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: [Income].self) { response in
                switch response.result {
                case .success(let incomes):
                    let totalIncome = incomes.reduce(Decimal(0)) { $0 + $1.amount }
                    DispatchQueue.main.async {
                        if var current = self.accountTotals[accountId] {
                            current.income = totalIncome
                            self.accountTotals[accountId] = current
                        } else {
                            self.accountTotals[accountId] = (income: totalIncome, outcome: 0)
                        }
                    }
                case .failure(let error):
                    print("❌ Error fetching incomes: \(error)")
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Response data: \(jsonString)")
                    }
                }
            }

        // Fetch outcomes
        let outcomeUrl = "http://localhost:8080/api/expense"
        
        AF.request(outcomeUrl, parameters: parameters, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: [Outcome].self) { response in
                switch response.result {
                case .success(let outcomes):
                    let totalOutcome = outcomes.reduce(Decimal(0)) { $0 + $1.amount }
                    DispatchQueue.main.async {
                        if var current = self.accountTotals[accountId] {
                            current.outcome = totalOutcome
                            self.accountTotals[accountId] = current
                        } else {
                            self.accountTotals[accountId] = (income: 0, outcome: totalOutcome)
                        }
                    }
                case .failure(let error):
                    print("❌ Error fetching outcomes: \(error)")
                    if let data = response.data,
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Response data: \(jsonString)")
                    }
                }
            }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    Text("Spendo")
                        .font(FontScheme.kWorkSansBold(size: 20))
                        .foregroundColor(Color(hex: "#3E2449"))
                        .padding(.horizontal)
                    Spacer()
                    Button(action: { showPopup.toggle() }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                    .padding()
                }
                VStack(alignment: .center) {
                    Text("Your wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .foregroundColor(Color(hex: "#3E2449"))
                    
                    HStack(spacing: 40) {
                        let totalBalance = accountViewModel.account.reduce(0) { $0 + $1.balance }
                        VStack {
                            Text("Total balance")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#3E2449"))
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: totalBalance).doubleValue))
                                .font(FontScheme.kInterRegular(size: 45))
                                .foregroundColor(Color(hex: "#3E2449"))
                        }
                        Spacer()
                        VStack {
                            Text("Total account")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#3E2449"))
                            Text("\(accountViewModel.account.count)")
                                .font(FontScheme.kInterRegular(size: 45))
                                .foregroundColor(Color(hex: "#3E2449"))
                        }
                    }
                    .padding(.horizontal, 30)
                    Divider()
                        .padding(.horizontal, 30)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(accountViewModel.account) { account in
                                Button(action: {
                                    accountSelectionManager.selectedAccount = account
                                    showPopup1.toggle()
                                }) {
                                    AccountCardView(
                                        icon: account.icon,
                                        title: account.title,
                                        balance: account.balance,
                                        income: accountTotals[account.id]?.income ?? account.income,
                                        outcome: accountTotals[account.id]?.outcome ?? account.outcome,
                                        backgroundColor: account.backgroundColor
                                    )
                                }
                                .onAppear {
                                    fetchAccountTransactions(for: account.id)
                                }
                            }
                        }
                    }
                    .frame(height: 210)
                    .padding(.leading, 30)
                }
                .frame(width: UIScreen.main.bounds.width)
                
                Text("Account transactions")
                    .font(FontScheme.kWorkSansRegular(size: 15))
                    .padding()
                    .foregroundColor(Color(hex: "#3E2449"))
                if let accountId = accountSelectionManager.selectedAccount?.id {
                    TransHisView(accountIds: [accountId], startDate: startDate, endDate: endDate)
                } else {
                    TransHisView(accountIds: [], startDate: startDate, endDate: endDate)
                }
            }
            .sheet(isPresented: $showPopup) {
                AddAccountView(isPresented: $showPopup)
            }
            .sheet(isPresented: $showPopup1) {
                if let account = accountSelectionManager.selectedAccount {
                    AccountDetailView( isPresented: $showPopup1)
                        .environmentObject(accountSelectionManager)
                }
            }
            .onAppear {
                accountViewModel.getAccount { result in
                    if case let .failure(error) = result {
                    }
                }
            }
            .hideNavigationBar()
            .navigationBarBackButtonHidden(true)
            
        }
    }
    struct AccountCardView: View {
        let icon: String
        let title: String
        let balance: Decimal
        let income: Decimal
        let outcome: Decimal
        let backgroundColor: Color
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                VStack(alignment: .center) {
                    Text(String(format: "%.2f", NSDecimalNumber(decimal: balance).doubleValue))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 25)
                    HStack {
                        VStack {
                            Text("INCOME")
                                .font(FontScheme.kWorkSansSemiBold(size: 10))
                                .foregroundColor(Color(hex: "#3E2449"))
                            Text(String(format: "%.1f", NSDecimalNumber(decimal: income).doubleValue))
                                .font(FontScheme.kInterSemiBold(size: 24))
                                .foregroundColor(Color(hex: "#3E2449"))
                        }
                        Spacer()
                        if #available(iOS 15.0, *) {
                            Divider().frame(height: 50).background(.white)
                        }
                        Spacer()
                        VStack {
                            Text("OUTCOME")
                                .font(FontScheme.kWorkSansSemiBold(size: 10))
                                .foregroundColor(Color(hex: "#3E2449"))
                            Text(String(format: "%.1f", NSDecimalNumber(decimal: outcome).doubleValue))
                                .font(FontScheme.kInterSemiBold(size: 24))
                                .foregroundColor(Color(hex: "#3E2449"))
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(width: 300, height: 75)
                    .background(
                        RoundedCorners(topLeft: 0, topRight: 0,
                                       bottomLeft: 16.0, bottomRight: 16.0)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                    )
                }
            }
            .padding(.top, 20)
            .frame(width: 300, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            Spacer()
        }
    }

    
}
