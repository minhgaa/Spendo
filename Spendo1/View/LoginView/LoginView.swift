import SwiftUI
import GoogleSignIn
import Alamofire

struct LoginView: View {
    
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var name = ""
    @State private var token = ""
    @State private var user: User? = nil
    @State private var selectedCurrency: Currency? = nil
    @State private var currencies: [Currency] = []
    @State private var isSelectingCurrency = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("BG")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                Group {
                    
                    if isLoggedIn {
                        VStack {
                            VStack {
                                Text("Spendo")
                                    .foregroundColor(Color(hex: "#DF835F"))
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                    .padding()
                                Text("Welcome, \(name)")
                                    .font(.system(size: 25))
                                Button("Log out") {
                                    handleLogOut()
                                }
                            }
                            .padding(.vertical,200)
                                NavigationLink(destination: ContentView()) {
                                    Text("Next")
                                        .foregroundColor(Color(hex:"#3E2449"))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            Spacer()
                        }
                        .padding()
                    } else if isSelectingCurrency {
                        VStack {
                            Text("Select your preferred currency")
                                .font(.headline)
                                .padding()
                            
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
                            
                            Button("Register") {
                                if let selectedCurrency = selectedCurrency {
                                    handleRegister()
                                } else {
                                    print("Please select a currency")
                                }
                            }
                            .padding()
                            .disabled(selectedCurrency == nil)
                        }
                    } else {
                        VStack {
                            Text("Spendo")
                                .foregroundColor(Color(hex: "#DF835F"))
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                                .padding(.vertical,280)
                            Button(action: {
                                handleSignInButton()
                            }) {
                                HStack {
                                    Image(systemName: "logo.google")
                                        .foregroundColor(.white)
                                    Text("Sign in with Google")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex:"#3E2449"))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .onAppear {
                    fetchInitialData()
                }
            }
        }
        .hideNavigationBar()
        .navigationBarBackButtonHidden(true)
    }

    private func fetchInitialData() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.email = user.profile?.email ?? "No email"
            self.name = user.profile?.name ?? "No email"
            self.isLoggedIn = true
        }
        APIManager.shared.getCurrencies { result in
            DispatchQueue.main.async {
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
            
            self.email = user.profile?.email ?? "Unknown"
            self.name = user.profile?.name ?? "Unknown"
            APIManager.shared.login(email: email) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        self.token = token
                        UserDefaults.standard.set(token, forKey: "JWTToken")
                        self.isLoggedIn = true
                        if let token1 = UserDefaults.standard.string(forKey: "JWTToken") {
                            print("Token found: \(token1)")
                        } else {
                            print("No token found in UserDefaults")
                        }

                    case .failure:
                        self.isSelectingCurrency = true
                    }
                }
            }
        }
    }
    func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "JWTToken")
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())  // Set LoginView as root view
                window.makeKeyAndVisible()
            }
        }
    }

    private func handleRegister() {
        guard let selectedCurrency = selectedCurrency else {
            print("No currency selected")
            return
        }
        let currencyid = selectedCurrency.id
        print(name)
        APIManager.shared.registerUser(email: email, name: name, currencyid: currencyid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newUser):
                    self.user = newUser
                    self.isLoggedIn = true
                    self.isSelectingCurrency = false
                    print("User Registered: \(newUser)")
                case .failure(let error):
                    print("Failed to register user: \(error)")
                }
            }
        }
    }



    
    func handleLogOut() {
        isLoggedIn = false
        email = ""
        name = ""
        user = nil
        selectedCurrency = nil
        isSelectingCurrency = false
        UserDefaults.standard.removeObject(forKey: "JWTToken")
        GIDSignIn.sharedInstance.signOut()
        print("User logged out")
    }
}
#Preview {
    LoginView()
}
