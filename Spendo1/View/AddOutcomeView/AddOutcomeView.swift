import SwiftUI

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
    @StateObject private var accountViewModel = AccountViewModel()
    @StateObject private var statisticViewModel = StatisticViewModel()
    @StateObject private var viewModel = AddOutcomeViewModel()
    @State private var showAlert = false // Để hiển thị Alert
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    

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
                        Text(selectedAmount > 0 ? "\(selectedAmount, specifier: "%.2f")$" : "+ Add Money")
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
                        } else {
                            Text("Loading accounts...")
                        }
                    }
                    .padding()
                    HStack{
                        Text(inputAmount.isEmpty ? "0" : inputAmount)
                            .font(FontScheme.kWorkSansSemiBold(size: 36))
                            
                        Text("$")
                            .font(FontScheme.kWorkSansRegular(size: 36))
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
                        if !statisticViewModel.categories.isEmpty {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(statisticViewModel.categories, id: \.id) { category in
                                    Text(category.name).tag(category.id as String?)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        } else {
                            Text("Loading categories...")
                        }
                    }
                    .padding()

                    Button("Done") {
                        showPopup1 = false
                        fetchBudgetForCategory()
                    }
                    .frame(width: 100, height: 45)
                    .background(Color(hex: "#3E2449"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.top)
                }
                .padding()
            }

            // Warning Text
            if showWarning {
                Text("Warning: The amount exceeds the budget limit!")
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
                        // Quay lại trang trước khi nhấn OK
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
            statisticViewModel.fetchCategories {
                result in
                    if case .failure(let error) = result {
                        print("Failed to load categories: \(error)")
                    }
            }
        }
    }

    private func fetchBudgetForCategory() {
        guard let categoryId = selectedCategory else { return }
        print(BudgetViewModel().budgetcate)
        BudgetViewModel().getBudget(bycategoryId: categoryId)
        self.limit = BudgetViewModel().budgetcate?.budgetLimit ?? 0
        print(limit)
        self.cur = BudgetViewModel().budgetcate?.current ?? 0
    }
    
    private func appendNumber(_ number: String) {
        inputAmount += number
    }

    private func appendDot() {
        if !inputAmount.contains(".") {
            inputAmount += "."
        }
    }

    func handleAddOutcome() {
        outcomeDto = OutcomeCreateDto(
            title: title,
            description: description,
            amount: Decimal(selectedAmount),
            accountid: accountId ?? "",
            categoryid: selectedCategory ?? ""
        )
        
        guard let outcomeDto = outcomeDto else {
            print("Outcome data is incomplete")
            return
        }
        
        viewModel.createOutcome(outcome: outcomeDto) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outcome):
                    createdOutcome = outcome
                    alertMessage = "Outcome created successfully."
                    showAlert.toggle()
                case .failure(let error):
                    alertMessage = "Outcome created successfully."
                    showAlert.toggle()
                }
            }
        }
    }


    func getCategoryName(by id: String?) -> String {
        if let id = id, let category = statisticViewModel.categories.first(where: { $0.id == id }) {
            return category.name
        }
        return ""
    }
}

#Preview {
    AddOutcomeView()
}
