import SwiftUI

struct HomeView: View {
    @StateObject var homeViewModel = HomeViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedButton: String = "Today"
    
    private var startDate: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let now = Date()
        
        switch selectedButton {
        case "Today":
            // Lấy đầu ngày hôm nay (00:00:00)
            return calendar.startOfDay(for: now)
            
        case "Month":
            // Lấy ngày đầu tiên của tháng này
            let components = calendar.dateComponents([.year, .month], from: now)
            return calendar.date(from: components) ?? now
            
        case "Year":
            // Lấy ngày đầu tiên của năm này
            let components = calendar.dateComponents([.year], from: now)
            return calendar.date(from: components) ?? now
            
        default:
            return calendar.startOfDay(for: now)
        }
    }
    
    private var endDate: Date {
        return Date()
    }
    
    private func formatDebugDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
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
                    Text("Today Budget")
                        .font(FontScheme.kWorkSansRegular(size: 15))
                        .foregroundColor(Color(hex: "#3E2449"))
                    Text("$\(String(format: "%.2f", NSDecimalNumber(decimal: homeViewModel.todayBudget).doubleValue))")
                        .font(FontScheme.kInterRegular(size: 20))
                        .foregroundColor(Color(hex: "#3E2449"))
                    Text("Remaining")
                        .font(FontScheme.kWorkSansRegular(size: 15))
                        .foregroundColor(Color(hex: "#3E2449"))
                        .padding(.top, 5)
                    Text("$\(String(format: "%.2f", NSDecimalNumber(decimal: homeViewModel.todayRemaining).doubleValue))")
                        .font(FontScheme.kInterRegular(size: 20))
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

            // Dynamically change the title and pass selected button value to TransHisView
            Text("\(selectedButton) Transactions")
                .font(FontScheme.kWorkSansRegular(size: 15))
                .padding(.horizontal)
                .padding(.vertical)
                .foregroundColor(Color(hex: "#3E2449"))

            TransHisView(accountIds: [], startDate: startDate, endDate: endDate)
            
            Spacer()
        }
        .background(Color(.white))
        .edgesIgnoringSafeArea(.bottom)
        .hideNavigationBar()
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedButton) { newValue in
            print("🔄 Changed to \(newValue)")
            print("📅 Start date: \(formatDebugDate(startDate))")
            print("📅 End date: \(formatDebugDate(endDate))")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
