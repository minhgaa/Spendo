import SwiftUI

struct TransferView: View {
    @StateObject private var transferViewModel = TransferViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    @State private var accountId: String? = nil
    @State private var targetAccountId: String? = nil
    @State private var description: String = ""
    @State private var transferSuccess: Bool? = nil
    @State private var title: String = ""
    @State private var inputAmount: String = ""
    @State private var category: String = ""
    @State private var isEditing: Bool = false
    @State private var showPopup = false
    @State private var createdTransfer: Transfer? = nil
    @State private var TransferDto: TransferCreateDto? = nil
    @State private var selectedAmount: Double = 0
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
                Image(systemName: "arrow.left.arrow.right")
                Text("Transfer")
                    .font(FontScheme.kWorkSansBold(size: 15))
                    .foregroundColor(Color.black)
                    .padding(.top,2)
            }
            TextField("Transfer Title", text: $title)
                .font(FontScheme.kWorkSansBold(size: 32))
                .foregroundColor(.black)
            
            Divider()
            Text("From")
                .font(.headline)
            if !accountViewModel.account.isEmpty {
                Picker("Source Account", selection: $accountId) {
                    ForEach(accountViewModel.account, id: \.id) { account in
                        Text(account.title).tag(account.id as String?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            } else {
                Text("Loading accounts...")
            }
            
            Text("To")
                .font(.headline)
            if !accountViewModel.account.isEmpty {
                Picker("Target Account", selection: $targetAccountId) {
                    ForEach(accountViewModel.account, id: \.id) { account in
                        Text(account.title).tag(account.id as String?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            } else {
                Text("Loading accounts...")
            }
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
                        
                    }
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
                Spacer()
                Button(action: { handleTransfer()
                }) {
                    Text("Tranfer")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color.black)
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
        .hideNavigationBar()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            accountViewModel.getAccount { result in
                if case .failure(let error) = result {
                    print("Failed to load accounts: \(error)")
                }
            }
        }
    }

    func appendNumber(_ number: String) {
        if inputAmount == "0" {
            inputAmount = number
        } else {
            inputAmount.append(number)
        }
    }

    func appendDot() {
        if !inputAmount.contains(".") {
            inputAmount.append(".")
        }
    }

    func handleTransfer() {
        TransferDto = TransferCreateDto(
            title: title,
            description: description.isEmpty ? nil : description,
            amount: Decimal(selectedAmount),
            accountId: accountId ?? "",
            targetAccountId: targetAccountId ?? "",
            categoryId: nil
        )
        print(TransferDto)
        guard let transferInfo = TransferDto else {
                print("Failed to prepare transfer data")
                return
            }
        transferViewModel.createTransfer(transferInfo: transferInfo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let Transfer):
                    createdTransfer = Transfer
                    alertMessage = "Transfer created successfully."
                    showAlert.toggle()
                case .failure(let error):
                    print("Failed to Transfer: \(error)")
                    alertMessage = "Transfer created successfully."
                    showAlert.toggle()
                }
            }
        }
    }
}

struct TransferView_Previews: PreviewProvider {
    static var previews: some View {
        TransferView()
    }
}
