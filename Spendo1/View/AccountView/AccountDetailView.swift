import SwiftUI
import Alamofire

struct AccountDetailView: View {
    @Binding var isPresented: Bool
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountSelectionManager: AccountSelectionManager
    @StateObject private var accountViewModel = AccountViewModel()
    @State private var incomes: [Income] = []
    @State private var outcomes: [Outcome] = []
    @State private var isLoading: Bool = false
    @StateObject private var addIncomeViewModel = AddIncomeViewModel()
    @StateObject private var addOutcomeViewModel = AddOutcomeViewModel()
    
    var body: some View {
        if let account = accountSelectionManager.selectedAccount {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: {
                        deleteAccount(id: account.id) 
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
                .padding()
                
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
                            .padding(.bottom,20)
                            .padding(.top,30)
                        VStack(alignment: .center) {
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: account.income).doubleValue))
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("VND")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        VStack(alignment: .center) {
                            Text("1")
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("Transactions")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        Spacer()
                        Button(action:{} ) {
                            Text("Add Income")
                                .foregroundColor(Color(hex: "#DF835F"))
                        }
                        .frame(width: 150, height: 50)
                        .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                                   bottomLeft: 40, bottomRight: 40)
                            .fill(Color.white))
                        .padding(.bottom)
                    }
                    .frame(width: 170, height: 300)
                    .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                               bottomLeft: 40, bottomRight: 40)
                        .fill(Color(hex: "#DF835F")))
                    
                    // Outcome Section
                    VStack(alignment: .center) {
                        Text("OUTCOME")
                            .font(FontScheme.kWorkSansBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.bottom,20)
                            .padding(.top,30)
                        VStack(alignment: .center) {
                            Text(String(format: "%.2f", NSDecimalNumber(decimal: account.outcome).doubleValue))                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("VND")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        VStack(alignment: .center) {
                            Text("1")
                                .font(FontScheme.kWorkSansBold(size: 32))
                                .foregroundColor(.white)
                            Text("Transactions")
                                .font(FontScheme.kWorkSansBold(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,10)
                        Spacer()
                        Button(action:{} ) {
                            Text("Add Outcome")
                                .foregroundColor(Color(hex: "#3E2449"))
                        }
                        .frame(width: 150, height: 50)
                        .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                                   bottomLeft: 40, bottomRight: 40)
                            .fill(Color.white))
                        .padding(.bottom)
                    }
                    .frame(width: 170, height: 300)
                    .background(RoundedCorners(topLeft: 40.0, topRight: 40.0,
                                               bottomLeft: 40, bottomRight: 40)
                        .fill(Color(hex: "#3E2449")))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
            }
            .padding()
            .hideNavigationBar()
            .onAppear() {
                if let accountId = accountSelectionManager.selectedAccount?.id {
                    fetchIncomes(accountIds: [accountId])
                    fetchOutcomes(accountIds: [accountId])
                } else {
                    TransHisView(accountIds: [])
                }
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
                    incomes = fetchedIncomes
                    let totalIncome = incomes.reduce(0) { $0 + $1.amount }
                    print("Total Income: \(totalIncome)")
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
                    let totalOutcome = outcomes.reduce(0) { $0 + $1.amount }
                    print("Total Outcome: \(totalOutcome)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
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

}
