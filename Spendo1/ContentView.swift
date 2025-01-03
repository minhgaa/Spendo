import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = TabViewModel()
    @State private var showAddIncome = false
    @State private var showAddOutcome = false
    @State private var showTransferMoney = false
    var body: some View {
        ZStack {
            Color(hex: "#FFFFFF")
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $viewModel.selectedTab) {
                ForEach(viewModel.tabs) { tab in
                    getView(for: tab.tag)
                        .tabItem {
                            VStack {
                                Image(systemName: tab.icon)
                                    .renderingMode(.template)
                                if viewModel.selectedTab == tab.tag {
                                    Text(tab.title)
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .tag(tab.tag)
                }
            }
            .accentColor(.black)
            
            if viewModel.selectedTab == "Add" {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(.easeInOut)
                
                VStack(alignment: .center) {
                    Spacer()
                    HStack {
                        Button(action: {
                            showAddIncome = true
                        }) {
                            ActionButton(icon: "arrow.down.circle.fill", title: "ADD\nINCOME", backgroundColor: Color(hex: "#DF835F"))
                        }
                    }
                    .padding(.bottom, 20)
                    HStack {
                        Button(action: {
                            showAddOutcome = true
                        }) {
                            ActionButton(icon: "arrow.up.circle.fill", title: "ADD\nOUTCOME", backgroundColor: Color(hex: "#3E2449"))
                        }
                        Spacer()
                        Button(action: {
                            showTransferMoney = true
                        }) {
                            ActionButton(icon: "arrow.left.arrow.right", title: "ACCOUNT\nTRANSFER", backgroundColor: Color.black)
                        }
                    }
                    .padding(.bottom, 100)
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        withAnimation {
                            viewModel.selectedTab = "Home"
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Circle().fill(Color.white))
                    }
                    .padding(.bottom, 50)
                }
                .padding(30)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
        }
        .background(
            Group {
                NavigationLink(
                    destination: AddIncomeView(),
                    isActive: $showAddIncome,
                    label: { EmptyView() }
                )
                .hidden()
                
                NavigationLink(
                    destination: AddOutcomeView(),
                    isActive: $showAddOutcome,
                    label: { EmptyView() }
                )
                .hidden()
                
                NavigationLink(
                    destination: TransferView(),
                    isActive: $showTransferMoney,
                    label: { EmptyView() }
                )
                .hidden()
            }
        )
    }

    @ViewBuilder
    private func getView(for tag: String) -> some View {
        switch tag {
        case "Home":
            HomeView()
        case "Stats":
            StatisticView()
        case "Wallet":
            AccountView()
        case "Budget":
            BudgetListView()
        default:
            Text("Page not found")
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(backgroundColor))

            Text(title)
                .font(FontScheme.kWorkSansBold(size: 15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 120)
    }
}
