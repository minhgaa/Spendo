import SwiftUI
import Alamofire

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var createdOn: Date = Date()
    @State private var isEditing: Bool = false
    @State private var showPopup = false
    @State private var showPopup1 = false
    @State private var selectedAmount: Double = 0
    @State private var inputAmount: String = ""
    @State private var accountId: String? = nil
    @State private var selectedCategory: String? = nil
    @State private var createdIncome: Income? = nil
    @State private var IncomeDto: IncomeCreateDto? = nil
    @StateObject private var accountViewModel = AccountViewModel()
    @StateObject private var viewModel = AddIncomeViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Category Data
    struct Category: Identifiable, Hashable, Decodable {
        let id: String
        let name: String
    }
    @State private var categoryList: [Category] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spendo")
                    .font(FontScheme.kWorkSansBold(size: 20))
                    .foregroundColor(Color(hex: "#3E2449"))
                Spacer()
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(Color(hex: "#DF835F"))
                Text("Income")
                    .font(FontScheme.kWorkSansBold(size: 15))
                    .foregroundColor(Color(hex: "#DF835F"))
                    .padding(.top,2)
            }
            Button(action: {
                            dismiss()
            }) {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
            }
            .frame(width: 30, height: 30)
            
            TextField("Income Title", text: $title)
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
                .padding()
            }
            HStack(alignment: .top) {
                Image(systemName: "text.justify")
                    .foregroundColor(.gray)
                    .padding(.top, isEditing ? 8 : 0)
                
                ZStack(alignment: .topLeading) {
                    if description.isEmpty && !isEditing {
                        Text("Add description")
                            .foregroundColor(.gray)
                            .font(FontScheme.kWorkSansMedium(size: 14))
                            .padding(.top, isEditing ? 8 : 0)
                            .padding(.leading, 4)
                            .onTapGesture {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                    }
                    if isEditing {
                        if #available(iOS 16.0, *) {
                            TextEditor(text: $description)
                                .foregroundColor(.black)
                                .font(FontScheme.kWorkSansMedium(size: 14))
                                .padding(.leading, -4)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .frame(height: isEditing ? 120 : 30)
                                .onTapGesture {
                                    withAnimation {
                                        isEditing = false
                                    }
                                }
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .animation(.easeInOut, value: isEditing)


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
                    handleAddIncome()
                }) {
                    Text("Add Income")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color(hex: "#DF835F"))
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
            fetchCategories()
        }
        .hideNavigationBar()
        .navigationBarBackButtonHidden(true)
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

    private func appendNumber(_ number: String) {
            inputAmount += number
        }

        private func appendDot() {
            if !inputAmount.contains(".") {
                inputAmount += "."
            }
        }

    func handleAddIncome() {
        IncomeDto = IncomeCreateDto(
            title: title,
            description: description,
            amount: Decimal(selectedAmount),
            accountId: accountId ?? "",
            categoryId: selectedCategory ?? ""
        )
        
        guard let IncomeDto = IncomeDto else {
            print("Income data is incomplete")
            return
        }
        
        viewModel.createIncome(income: IncomeDto) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let Income):
                    createdIncome = Income
                    alertMessage = "Income created successfully."
                    showAlert.toggle()
                case .failure(let error):
                    print("Failed to add Income: \(error)")
                    alertMessage = "Income created successfully."
                    showAlert.toggle()
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
    AddIncomeView()
}

