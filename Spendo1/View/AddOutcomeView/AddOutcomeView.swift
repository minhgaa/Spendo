import SwiftUI
import Alamofire

struct AddOutcomeView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var createdOn: Date = Date()
    @State private var isEditing: Bool = false
    @State private var showPopup = false
    @State private var showPopup1 = false
    @State private var selectedAmount: Double = 0
    @State private var limit: Decimal = 0
    @State private var cur: Decimal = 0
    @State private var inputAmount: String = ""
    @State private var accountId: String? = nil
    @State private var selectedCategory: String? = nil
    @State private var categories: [Category] = []
    @State private var createdOutcome: Outcome? = nil
    @State private var outcomeDto: OutcomeCreateDto? = nil
    @State private var budget: Budget? = nil
    @State private var showWarning: Bool = false
    @State private var accountBalance: Decimal = 0
    @State private var showBalanceWarning: Bool = false
    @StateObject private var accountViewModel = AccountViewModel()
    @StateObject private var viewModel = AddOutcomeViewModel()
    @StateObject private var budgetViewModel = BudgetViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var hasBudget: Bool = false
    
    // MARK: - Category Data
    struct Category: Identifiable, Hashable, Decodable {
        let id: String
        let name: String
    }
    @State private var categoryList: [Category] = []
    
    private func formatDecimal(_ value: Decimal) -> String {
        return String(format: "%.2f", NSDecimalNumber(decimal: value).doubleValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spendo")
                    .font(FontScheme.kWorkSansBold(size: 20))
                    .foregroundColor(Color(hex: "#3E2449"))
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color(hex: "#3E2449"))
                Text("Outcome")
                    .font(FontScheme.kWorkSansBold(size: 15))
                    .foregroundColor(Color(hex: "#3E2449"))
                    .padding(.top,2)
            }
            TextField("Outcome Title", text: $title)
                .font(FontScheme.kWorkSansBold(size: 32))
                .foregroundColor(.black)

            Divider()
            VStack {
                Button(action: {
                    showPopup.toggle()
                }) {
                    HStack {
                        Text(selectedAmount > 0 ? "$\(String(format: "%.2f", selectedAmount))" : "+ Add Money")
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                    .frame(maxWidth: 150)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: "#3E2449"), lineWidth: 1)
                    )
                }
            }
            .sheet(isPresented: $showPopup) {
                VStack {
                    HStack {
                        Text("Deduct money from")
                            .font(FontScheme.kWorkSansBold(size: 20))
                            .padding()
                        Spacer()
                        Button(action: {
                            showPopup.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .padding()
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    HStack{
                        if !accountViewModel.account.isEmpty {
                            Picker("Account", selection: $accountId) {
                                ForEach(accountViewModel.account, id: \.id) { account in
                                    Text(account.title).tag(account.id as String?)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: accountId) { newValue in
                                if let id = newValue,
                                   let account = accountViewModel.account.first(where: { $0.id == id }) {
                                    accountBalance = account.balance
                                    checkBalanceWarning()
                                }
                            }
                        } else {
                            Text("Loading accounts...")
                        }
                    }
                    .padding()
                    
                    if let selectedAccountId = accountId,
                       let account = accountViewModel.account.first(where: { $0.id == selectedAccountId }) {
                        Text("Available balance: $\(formatDecimal(account.balance))")
                            .font(FontScheme.kWorkSansRegular(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    if showBalanceWarning {
                        Text("Warning: Amount exceeds account balance!")
                            .font(FontScheme.kWorkSansRegular(size: 14))
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    HStack{
                        Text(inputAmount.isEmpty ? "$0.00" : "$\(inputAmount)")
                            .font(FontScheme.kWorkSansSemiBold(size: 36))
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            CalculatorButton(title: "7", action: { appendNumber("7") })
                            CalculatorButton(title: "8", action: { appendNumber("8") })
                            CalculatorButton(title: "9", action: { appendNumber("9") })
                        }
                        HStack {
                            CalculatorButton(title: "4", action: { appendNumber("4") })
                            CalculatorButton(title: "5", action: { appendNumber("5") })
                            CalculatorButton(title: "6", action: { appendNumber("6") })
                        }
                        HStack {
                            CalculatorButton(title: "1", action: { appendNumber("1") })
                            CalculatorButton(title: "2", action: { appendNumber("2") })
                            CalculatorButton(title: "3", action: { appendNumber("3") })
                        }
                        HStack {
                            CalculatorButton(title: "0", action: { appendNumber("0") })
                            CalculatorButton(title: ".", action: { appendDot() })
                            Button(action: {
                                inputAmount = ""
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30))
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        }
                    }
                    .padding(.bottom,20)
                    
                    Button("Deduct") {
                        if let amount = Double(inputAmount) {
                            selectedAmount = amount
                        }
                        showPopup = false
                    }
                    .frame(width: 100, height: 45)
                    .background(Color(hex: "#3E2449"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
            }

            Button(action: {
                showPopup1.toggle()
            }) {
                HStack {
                    Text(selectedCategory != nil ? getCategoryName(by: selectedCategory) : "+ Add Category")
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#3E2449"))
                }
                .frame(maxWidth: 167)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(hex: "#3E2449"), lineWidth: 1)
                )
            }
            .sheet(isPresented: $showPopup1) {
                VStack(alignment: .leading) {
                    Text("Choose category")
                        .font(FontScheme.kWorkSansBold(size: 20))
                        .padding()

                    HStack{
                        if !categoryList.isEmpty {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categoryList, id: \.id) { category in
                                    Text(category.name).tag(category.id as String?)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .onChange(of: selectedCategory) { newValue in
                                print("🔄 Category changed to: \(String(describing: newValue))")
                                if let categoryId = newValue {
                                    fetchBudgetForCategory()
                                }
                            }
                        } else {
                            Text("Loading categories...")
                        }
                    }
                    .padding()

                    Button("Done") {
                        showPopup1 = false
                        print("🔍 Checking budget after Done")
                        print("Selected Category: \(String(describing: selectedCategory))")
                        print("HasBudget: \(hasBudget), Limit: \(limit), Current: \(cur)")
                        fetchBudgetForCategory()
                    }
                    .frame(width: 100, height: 45)
                    .background(Color(hex: "#3E2449"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.top)
                }
                .padding()
                .onAppear {
                    print("📱 Category picker appeared")
                    if let categoryId = selectedCategory {
                        print("Fetching budget for category: \(categoryId)")
                        fetchBudgetForCategory()
                    }
                }
            }

            if showWarning && hasBudget {
                Text("Warning: The amount exceeds the budget limit! (Limit: $\(formatDecimal(limit)), Current: $\(formatDecimal(cur)))")
                    .foregroundColor(.red)
                    .padding()
            }

            if showBalanceWarning {
                Text("Warning: The amount exceeds the account balance! (Balance: $\(formatDecimal(accountBalance)))")
                    .foregroundColor(.red)
                    .padding()
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text("Created on")
                    .foregroundColor(.gray)
                    .font(FontScheme.kWorkSansMedium(size: 14))
                Spacer()
                DatePicker(
                        "",
                        selection: $createdOn,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Spacer()
                Button(action: {
                    handleAddOutcome()
                }) {
                    Text("Add Outcome")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color(hex: "#3E2449"))
                        .cornerRadius(40)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Transfer Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .onAppear {
            accountViewModel.getAccount { result in
                if case .failure(let error) = result {
                    print("Failed to load accounts: \(error)")
                }
            }
            fetchCategories()
        }
    }

    private func fetchCategories() {
        let url = "http://localhost:8080/api/category"
        AF.request(url, method: .get, headers: APIConfig.headers)
            .validate()
            .responseDecodable(of: [Category].self) { response in
                switch response.result {
                case .success(let categories):
                    self.categoryList = categories
                case .failure(let error):
                    print("Failed to load categories: \(error)")
                }
            }
    }

    private func fetchBudgetForCategory() {
        guard let categoryId = selectedCategory else { 
            print("⚠️ No category selected")
            hasBudget = false
            return 
        }
        
        print("🎯 Fetching budget for category: \(categoryId)")
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let budgetVM = BudgetViewModel()
        
        budgetVM.getBudget(bycategoryId: categoryId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let budget):
                    self.limit = budget.budgetLimit
                    self.cur = budget.current
                    self.hasBudget = true
                    print("🔵 Budget fetched - Limit: \(self.limit), Current: \(self.cur), HasBudget set to true")
                    
                    // Kiểm tra lại với số tiền hiện tại
                    if let amount = Double(self.inputAmount) {
                        let newTotal = self.cur + Decimal(amount)
                        self.showWarning = newTotal > self.limit
                        print("🔄 Checking budget - Amount: \(amount), NewTotal: \(newTotal), Exceeds Limit: \(self.showWarning)")
                    }
                case .failure(let error):
                    print("⚠️ Error fetching budget: \(error)")
                    self.hasBudget = false
                    self.showWarning = false
                }
            }
        }
    }
    
    private func appendNumber(_ number: String) {
        inputAmount += number
        if let amount = Double(inputAmount) {
            selectedAmount = amount
            if hasBudget {
                let newTotal = cur + Decimal(amount)
                showWarning = newTotal > limit
                print("💰 Input changed - Current: \(cur), Amount: \(amount), NewTotal: \(newTotal), Limit: \(limit), ShowWarning: \(showWarning)")
            }
            showBalanceWarning = Decimal(amount) > accountBalance
        }
    }

    private func appendDot() {
        if !inputAmount.contains(".") {
            inputAmount += "."
        }
    }

    private func checkBalanceWarning() {
        if let amount = Double(inputAmount) {
            showBalanceWarning = Decimal(amount) > accountBalance
        }
    }

    func handleAddOutcome() {
        print("📝 Starting handleAddOutcome")
        print("HasBudget: \(hasBudget), Limit: \(limit), Current: \(cur)")
        
        if Decimal(selectedAmount) > accountBalance {
            alertMessage = "You don't have enough balance in your account. (Balance: $\(formatDecimal(accountBalance)))"
            showAlert = true
            return
        }

        outcomeDto = OutcomeCreateDto(
            title: title,
            description: description,
            amount: Decimal(selectedAmount),
            accountId: accountId ?? "",
            categoryId: selectedCategory ?? ""
        )
        
        guard let outcomeDto = outcomeDto else {
            print("❌ Outcome data is incomplete")
            return
        }
        
        print("✅ Creating outcome with amount: \(selectedAmount)")
        viewModel.createOutcome(outcome: outcomeDto) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outcome):
                    self.createdOutcome = outcome
                    self.alertMessage = "Outcome created successfully."
                    self.showAlert.toggle()
                    
                    if let categoryId = self.selectedCategory {
                        self.budgetViewModel.updateBudgetCurrent(categoryId: categoryId, amount: Decimal(self.selectedAmount))
                    }
                    
                case .failure(let error):
                    self.alertMessage = "Failed to create outcome: \(error.localizedDescription)"
                    self.showAlert.toggle()
                }
            }
        }
    }

    func getCategoryName(by id: String?) -> String {
        if let id = id, let category = categoryList.first(where: { $0.id == id }) {
            return category.name
        }
        return ""
    }
}

#Preview {
    AddOutcomeView()
}
