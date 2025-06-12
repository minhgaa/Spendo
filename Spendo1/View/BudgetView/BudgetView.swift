import SwiftUI
import Alamofire

struct BudgetListView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var isShowingCreateBudget = false
    @State private var selectedBudget: Budget? = nil
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Budget list")
                        .font(.title)
                        .fontWeight(.bold)
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.budgets, id: \.id) { budget in
                                VStack {
                                    VStack {
                                        Text(budget.name)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 5)
                                            .foregroundColor(.white)
                                            .padding(.bottom,20)
                                        Text("\(String(format: "%.0f", NSDecimalNumber(decimal: budget.current).doubleValue))$")
                                            .font(.system(size: 40))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 5)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Text("Limit: \(String(format: "%.0f", NSDecimalNumber(decimal: budget.budgetLimit).doubleValue))$")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                }
                                .padding()
                                .frame(width: 150, height: 200)
                                .background(
                                    RoundedCorners(topLeft: 30.0, topRight: 30.0,
                                                   bottomLeft: 30, bottomRight: 30)
                                    .fill(budget.budgetLimit == budget.current ? Color(hex: "#DF835F") : budget.budgetLimit < budget.current ? Color.red : Color.gray)
                                )
                                .onTapGesture {
                                    selectedBudget = budget
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                        Button("Add Budget") {
                            isShowingCreateBudget = true
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        .sheet(isPresented: $isShowingCreateBudget) {
                            CreateBudgetView(viewModel: viewModel)
                        }
                    }
                    
                }
            }
            .onAppear {
                viewModel.getBudgets()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.getBudgets()
            }
            .alert(item: $selectedBudget) { budget in
                Alert(
                    title: Text("Delete Confirmation"),
                    message: Text("Are you sure you want to delete budget \"\(budget.name)\"?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteBudget(budget)
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }
    
    func updateBudget(_ budget: Budget) {
        // Remove this unused function
    }
    
    func deleteBudget(_ budget: Budget) {
        viewModel.deleteBudget(id: budget.id)
    }
}

struct CreateBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BudgetViewModel
    @State private var name = ""
    @State private var startDate = Date()
    @State private var period = 3
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var createdOn: Date = Date()
    @State private var showPopup = false
    @State private var showPopup1 = false
    @State private var selectedAmount: Double = 0
    @State private var inputAmount: String = ""
    @State private var selectedCategory: String? = nil
    @StateObject private var accountViewModel = AccountViewModel()

    // MARK: - Category Data
    struct Category: Identifiable, Hashable, Decodable {
        let id: String
        let name: String
    }
    @State private var categoryList: [Category] = []

    let periods = [1,2,3,4,5,6,7]

    var body: some View {
        NavigationView {
            Form() {
                Section(header: Text("Budget Details")) {
                    TextField("Budget Name", text: $name)
                        .frame(height: 50)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Picker("Period (in days)", selection: $period) {
                        ForEach(periods, id: \.self) { period in
                            Text("\(period) days")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(height: 50)
                    
                    VStack {
                        Button(action: {
                            showPopup.toggle()
                        }) {
                            HStack {
                                Text(selectedAmount > 0 ? "\(selectedAmount, specifier: "%.2f")$" : "+ Add Budget limit")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "#DF835F"))
                            }
                            .frame(maxWidth: 150)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color(hex: "#DF835F"), lineWidth: 1)
                            )
                        }
                    }
                    .sheet(isPresented: $showPopup) {
                        VStack {
                            HStack {
                                Text("Add money to")
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
                            
                            Button("Add") {
                                if let amount = Double(inputAmount) {
                                    selectedAmount = amount
                                }
                                showPopup = false
                            }
                            .frame(width: 100, height: 45)
                            .background(Color(hex: "#DF835F"))
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
                                .foregroundColor(Color(hex: "#DF835F"))

                        }
                        .frame(maxWidth: 167)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(hex: "#DF835F"), lineWidth: 1)
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
                                } else {
                                    Text("Loading categories...")
                                }
                            }
                            .padding()

                            Button("Done") {
                                showPopup1 = false
                            }
                            .frame(width: 100, height: 45)
                            .background(Color(hex: "#DF835F"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.top)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical,5)
                
                Section {
                    Button("Create Budget") {
                        createBudget()
                    }
                }
                .padding(.horizontal,100)
            }
            .navigationTitle("Add Budget")
            .onAppear() {
                fetchCategories()
            }
        }
    }
    private func appendNumber(_ number: String) {
            inputAmount += number
        }
        private func appendDot() {
            if !inputAmount.contains(".") {
                inputAmount += "."
            }
        }
    func getCategoryName(by id: String?) -> String {
        if let id = id, let category = categoryList.first(where: { $0.id == id }) {
            return category.name
        }
        return ""
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
    private func createBudget() {
        print("🔵 Validating budget data:")
        print("Name: \(name)")
        print("Start Date: \(formatDate(startDate))")
        print("Period: \(period)")
        print("Amount: \(selectedAmount)")
        print("Selected Category: \(selectedCategory ?? "nil")")
        
        guard !name.isEmpty else {
            print("❌ Budget name is empty")
            return
        }
        
        guard selectedAmount > 0 else {
            print("❌ Budget limit must be greater than 0")
            return
        }
        
        let budgetInfo = BudgetCreateDto(
            name: name,
            startDate: formatDate(startDate),
            period: period,
            budgetLimit: Decimal(selectedAmount),
            categoryId: selectedCategory,
            userId: UserDefaults.standard.string(forKey: "userId") ?? ""
        )
        
        viewModel.createBudget(budgetInfo: budgetInfo) {
            dismiss()
        }
    }
}

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListView()
    }
}
