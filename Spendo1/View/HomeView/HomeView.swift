import SwiftUI

struct HomeView: View {
    @StateObject var homeViewModel = HomeViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedButton: String = "Today"
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spendo")
                        .font(FontScheme.kWorkSansBold(size: 20))
                        .foregroundColor(Color(hex: "#3E2449"))
                    Text("Welcome,")
                        .font(FontScheme.kWorkSansSemiBold(size: 36))
                        .foregroundColor(Color(hex: "#DF835F"))
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Today remaining")
                        .font(FontScheme.kWorkSansRegular(size: 15))
                        .foregroundColor(Color(hex: "#3E2449"))
                    Text("$50")
                        .font(FontScheme.kInterRegular(size: 45))
                        .foregroundColor(Color(hex: "#3E2449"))
                }
            }
            .padding(.horizontal)
            VStack(alignment: .center) {
                HStack() {
                    Spacer()
                    Button(action: {
                        selectedButton = "Today"
                    }) {
                        SwiftUI.Text("Today")
                            .padding()
                            .frame(width:100,height: 50)
                            .foregroundColor(selectedButton == "Today" ? .black : .gray)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedButton == "Today" ? Color.white : Color.clear)
                                    .shadow(color: selectedButton == "Today" ? .gray.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                            )
                    }
                    Spacer()
                    Button(action: {
                        selectedButton = "Month"
                    }) {
                        SwiftUI.Text("Month")
                            .padding()
                            .frame(width:100,height: 50)
                            .foregroundColor(selectedButton == "Month" ? .black : .gray)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedButton == "Month" ? Color.white : Color.clear)
                                    .shadow(color: selectedButton == "Month" ? .gray.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                            )
                    }
                    Spacer()
                    Button(action: {
                        selectedButton = "Year"
                    }) {
                        SwiftUI.Text("Year")
                            .padding()
                            .frame(width:100,height: 50)
                            .foregroundColor(selectedButton == "Year" ? .black : .gray)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedButton == "Year" ? Color.white : Color.clear)
                                    .shadow(color: selectedButton == "Year" ? .gray.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                            )
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width*0.85, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#F3F1F4")))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Text("Upcoming Bills")
                .font(FontScheme.kWorkSansRegular(size: 15))
                .padding(.horizontal)
                .padding(.top)
                .padding(.vertical)
                .foregroundColor(Color(hex: "#3E2449"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(homeViewModel.cards) { card in
                        CardView(
                            date: card.date,
                            textColor: card.textColor,
                            title: card.title,
                            amount: card.amount,
                            backgroundColor: card.backgroundColor,
                            buttonColor: card.buttonColor,
                            frameColor: card.frameColor
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 170)
            
            Text("Today Transactions")
                .font(FontScheme.kWorkSansRegular(size: 15))
                .padding(.horizontal)
                .padding(.vertical)
                .foregroundColor(Color(hex: "#3E2449"))
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(homeViewModel.trans) { trans in
                        TransactionRow(title: trans.title, date: trans.date, amount: trans.amount, color: trans.color)}
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.white))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TransactionRow: View {
    var title: String
    var date: String
    var amount: Float
    var color: Color
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.2))
                .frame(width: 45, height: 45)
                .cornerRadius(10)
                .overlay(
                    Image(systemName: color == .green ? "arrow.up" : "arrow.down")
                        .foregroundColor(color)
                )
            VStack(alignment: .leading) {
                Text(title)
                    .font(FontScheme.kWorkSansMedium(size: 16))
                Text(date)
                    .font(FontScheme.kInterRegular(size: 12))
                    .foregroundColor(Color(hex: "#B5B3B3"))
            }
            Spacer()
            Text(String(format: "%.0f", amount))
                .font(.subheadline)
                .foregroundColor(color)
        }
        .onAppear {
                        print("HomeView appeared on screen")
                    }
                    .onDisappear {
                        print("HomeView disappeared from screen")
                    }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}