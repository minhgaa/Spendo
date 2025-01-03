import SwiftUI
import Charts
struct StatisticView: View {
    @StateObject var statsViewModel = StatisticViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedTab: String = "Week"
    @State private var categories: [StatisticViewModel.Category] = []
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8) 
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spendo")
                .font(FontScheme.kWorkSansBold(size: 20))
                .foregroundColor(Color(hex: "#3E2449"))
                .padding(.horizontal)
            VStack {
                HStack(spacing: 20) {
                    ForEach(["Week", "Month", "Year"], id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab)
                                .padding()
                                .frame(width: 100, height: 50)
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTab == tab ? Color(hex: "#3E2449") : Color.clear)
                                        .shadow(color: selectedTab == tab ? .gray.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#F3F1F4"))
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
            VStack(alignment: .leading) {
                HStack {
                    Text("WEEK SPENDING")
                        .font(FontScheme.kWorkSansSemiBold(size: 15))
                        .foregroundColor(Color(hex: "#9375A0"))
                    Spacer()
                    Text("$200")
                        .font(FontScheme.kWorkSansSemiBold(size: 20))
                        .foregroundColor(Color(hex: "#3E2449"))
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                if #available(iOS 16.0, *) {
                    Chart(DevTechieCourses.data) { course in
                        BarMark(
                            x: .value("Time", course.time.rawValue), y: .value("Money", course.money)
                        )
                        .foregroundStyle(
                            course.category == .Income ? Color(hex: "#DF835F") :
                                course.category == .Outcome ? Color(hex : "#9462A9"): Color.gray
                        )
                        
                        .cornerRadius(8)
                        .annotation(position: .overlay) {
                            Text(course.money.formatted())
                                .font(.caption.bold())
                        }
                    }
                    .frame(height: 320)
                    HStack {
                        Label("Income", systemImage: "circle.fill")
                            .foregroundColor(Color(hex : "#DF835F"))
                        Label("Outcome", systemImage: "circle.fill")
                            .foregroundColor(Color(hex: "#9462A9"))
                        
                    }
                    .font(.caption)
                    .padding(.leading)
                    .padding(.bottom)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
            
            Text("Main Spending")
                .font(FontScheme.kWorkSansRegular(size: 15))
                .padding(.horizontal)
                .foregroundColor(Color(hex: "#3E2449"))
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8){
                    ForEach(statsViewModel.cards) { card in
                        SpendingCardView(icon: card.icon, title: card.title, amount: card.amount, backgroundColor: card.backgroundColor)}
                }
                .padding(.horizontal)
                
                
            }
        }
        .background(Color(.white))
        .hideNavigationBar()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            statsViewModel.fetchCategories { result in
                if case let .failure(error) = result {
                }
            }
        }

    }

}
struct SpendingCardView: View {
    let icon: String
    let title: String
    let amount: Decimal
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
            VStack {
                Text(title)
                    .font(FontScheme.kWorkSansMedium(size: 15))
                    .foregroundColor(.white)
                Text(String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue))
                    .font(FontScheme.kInterMedium(size: 24))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 170, height: 100)
        .background(backgroundColor)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
