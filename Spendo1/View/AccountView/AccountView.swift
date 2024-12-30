import SwiftUI

struct AccountView: View {
    @StateObject var accountViewModel = AccountViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                Text("Spendo")
                    .font(FontScheme.kWorkSansBold(size: 20))
                    .foregroundColor(Color(hex: "#3E2449"))
                    .padding(.horizontal)
            
            VStack(alignment: .center) {
                Text("Your wallet")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                    .foregroundColor(Color(hex: "#3E2449"))
                HStack(spacing: 40) {
                    VStack {
                        Text("Total balance")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#3E2449"))
                        Text("$500")
                            .font(FontScheme.kInterRegular(size: 45))
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                    Spacer()
                    VStack {
                        Text("Total account")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#3E2449"))
                        Text("3")
                            .font(FontScheme.kInterRegular(size: 45))
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                }
                .padding(.horizontal,30)
                Divider()
                    .padding(.horizontal,30)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(accountViewModel.account) { account in
                            AccountCardView(
                                icon: account.icon,
                                title: account.title,
                                amount: account.amount,
                                income: account.income,
                                outcome: account.outcome,
                                backgroundColor: account.backgroundColor
                            )
                        }
                    }
                }
                .frame(height: 210)
                .padding(.leading,30)
            }
            .frame(width: UIScreen.main.bounds.width)
            Text("Account transactions")
                .font(FontScheme.kWorkSansRegular(size: 15))
                .padding()
                .foregroundColor(Color(hex: "#3E2449"))
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(accountViewModel.trans) { trans in
                        TransactionRow(title: trans.title, date: trans.date, amount: trans.amount, color: trans.color)}
                }
                .padding(.horizontal)
            }
        }
    }
}
struct AccountCardView: View {
    let icon: String
    let title: String
    let amount: Float
    let income: Float
    let outcome: Float
    let backgroundColor: Color
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            VStack(alignment: .center) {
                Text("\(amount, specifier: "%.1f")")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom,25)
                HStack {
                    VStack {
                        Text("INCOME")
                            .font(FontScheme.kWorkSansSemiBold(size: 10))
                            .foregroundColor(Color(hex: "#3E2449"))
                        Text("\(income, specifier: "%.1f")")
                            .font(FontScheme.kInterSemiBold(size: 24))
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                    Spacer()
                    if #available(iOS 15.0, *) {
                        Divider().frame(height: 50).background(.white)
                    }
                    Spacer()
                    VStack {
                        Text("OUTCOME")
                            .font(FontScheme.kWorkSansSemiBold(size: 10))
                            .foregroundColor(Color(hex: "#3E2449"))
                        Text("\(outcome, specifier: "%.1f")")
                            .font(FontScheme.kInterSemiBold(size: 24))
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                }
                .padding(.horizontal,40)
                .frame(width: 300,height: 75)
                .background(
                    RoundedCorners(topLeft: 0, topRight: 0,
                                           bottomLeft: 16.0, bottomRight: 16.0)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                   )
            }
        }
        .padding(.top,20)
        .frame(width:300, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
        Spacer()
    }
    
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
