import SwiftUI
import GoogleSignIn
import Alamofire

struct LoginView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var name = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedCategory: Category?
    
    // List of currencies fetched from the API
    @State private var currencies: [Currency] = []
    
    // List of categories (replace with your own data)
    @State private var categories: [Category] = [
        Category(id: 1, name: "Ăn uống"),
        Category(id: 2, name: "Hoá đơn"),
        Category(id: 3, name: "Di chuyển"),
        // Add other categories here...
    ]
    
    var body: some View {
        VStack {
            if isLoggedIn {
                Text("Welcome \(email)")
                    .padding()

                // Currency Selection
                if let selectedCurrency = selectedCurrency {
                    Text("Selected Currency: \(selectedCurrency.name)")
                        .padding()
                }

                List(currencies) { currency in
                    Button(action: {
                        self.selectedCurrency = currency
                    }) {
                        Text(currency.name)
                            .padding()
                            .background(self.selectedCurrency?.id == currency.id ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .frame(height: 200)
                .padding()
                
                Button("Select") {
                    handleSelect()
                }
                .padding()

                // Log Out Button
                Button("Log Out") {
                    handleLogOut()
                }
                .padding()
                .foregroundColor(.red)
            } else {
                Button("Sign in with Google") {
                    handleSignInButton()
                }
                .padding()
            }
        }
        .onAppear {
            // Check if user is already logged in
            if let user = GIDSignIn.sharedInstance.currentUser {
                self.email = user.profile?.email ?? "No email"
                self.name = user.profile?.name ?? "No email"
                self.isLoggedIn = true
            }

            // Fetch currencies when the view appears
            APIManager.shared.getCurrencies { result in
                switch result {
                case .success(let currencies):
                    self.currencies = currencies
                case .failure(let error):
                    print("Failed to fetch currencies: \(error.localizedDescription)")
                }
            }
        }
    }

    func handleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first?.rootViewController ?? UIViewController()) { authentication, error in
            if let error = error {
                print("Error signing in: \(error)")
                return
            }
            
            guard let user = authentication?.user else {
                print("Error: Missing User Information")
                return
            }

            let email = user.profile?.email ?? "Unknown"
            let name = user.profile?.name ?? "Unknown"
            self.email = email
            self.name = name
            self.isLoggedIn = true
        }
    }

    func handleLogOut() {
        // Set login state to false and clear selections
        isLoggedIn = false
        email = ""
        selectedCurrency = nil
        selectedCategory = nil

        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        print("User logged out")
    }
    
    func handleSelect() {
        // Check if a currency is selected
        guard let selectedCurrency = selectedCurrency else {
            print("No currency selected")
            return
        }
        print(name)
       print(email)
        let currencyId = selectedCurrency.id
        print(currencyId)
        APIManager.shared.googleLogin(email: email, currencyId: currencyId, name: name) { result in
            switch result {
            case .success:
                print("Currency selected successfully")
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}
