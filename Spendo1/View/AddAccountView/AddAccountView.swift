import SwiftUI

struct AddAccountView: View {
    @Binding var isPresented: Bool
    @State private var accountName = ""
    @State private var balance: Decimal = 0.0
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var createdAccount: Account? = nil
    @State private var inputAmount = "0"
    @StateObject private var addaccountViewModel = AddAccountViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "#F8F9FA")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Create New Account")
                        .font(FontScheme.kWorkSansBold(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#3E2449"))
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(spacing: 15) {
                    TextField("Account name", text: $accountName)
                        .font(FontScheme.kWorkSansBold(size: 32))
                        .foregroundColor(.black)
                    
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .font(FontScheme.kWorkSansBold(size: 20))
                    }
                    HStack {
                        Text(inputAmount.isEmpty ? "0" : inputAmount)
                            .font(FontScheme.kWorkSansSemiBold(size: 36))
                        
                        Text("$")
                            .font(FontScheme.kWorkSansRegular(size: 36))
                    }
                    .padding()
                    
                    VStack {
                        ForEach(0..<3) { row in
                            HStack {
                                ForEach(1...3, id: \.self) { col in
                                    let number = "\(3 * row + col)"
                                    CalculatorButton(title: number, action: { appendNumber(number) })
                                }
                            }
                        }
                        
                        HStack {
                            CalculatorButton(title: "0", action: { appendNumber("0") })
                            CalculatorButton(title: ".", action: { appendDot() })
                            Button(action: {
                                inputAmount = "0"
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
                    .padding(.bottom, 20)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Button(action: {
                    if let decimalValue = Decimal(string: inputAmount) {
                        balance = decimalValue
                        createNewAccount()
                    } else {
                        errorMessage = "Invalid amount entered."
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Create Account")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#3E2449"))
                    .cornerRadius(200)
                }
                .disabled(isLoading || accountName.isEmpty || inputAmount == "0")
            }
            .padding()
        }
    }
    
    func createNewAccount() {
        isLoading = true
        addaccountViewModel.createAccount(accountName: accountName, balance: balance) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let account):
                    createdAccount = account
                    isPresented = false
                case .failure(let error):
                    isPresented = false
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
}
struct CalculatorButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.black, lineWidth: 1)
                )
        }



    }
}
#Preview {
    @State var showPopup = true
    return AddAccountView(isPresented: $showPopup)
}
