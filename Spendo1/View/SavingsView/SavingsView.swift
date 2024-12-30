import SwiftUI

struct SavingsView: View {
    @State private var selectedTab: String = "Effective"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spendo")
                .font(FontScheme.kWorkSansBold(size: 20))
                .foregroundColor(Color(hex: "#3E2449"))
                .padding(.horizontal)
            VStack(alignment: .center) {
                Text("Your savings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                    .foregroundColor(Color(hex: "#3E2449"))
                HStack(spacing: 20) {
                    ForEach(["Effective", "Completed"], id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab)
                                .padding()
                                .frame(width: 120, height: 40)
                                .foregroundColor(selectedTab == tab ? .white : Color(hex: "#3E2449"))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTab == tab ? Color(hex: "#3E2449") : Color.clear)
                                        .shadow(color: selectedTab == tab ? .gray.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .frame(width: 280,height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#F3F1F4"))
                )
            }
            .frame(width: UIScreen.main.bounds.width)
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SavingsViewModel().saving) { item in
                        SavingCardView(item: item)
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {
            }) {
                Text("ADD SAVINGS")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: "#3E2449"))
                    )
            }
            .padding(.horizontal)
        }
        .background(Color.white)
    }
}


struct SavingCardView: View {
    let item: SavingsViewModel.SavingItem
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#3E2449"))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Text(item.date)
                        .font(.subheadline)
                        .foregroundColor(.pink)
                }
                HStack {
                    Text("Savings: \(item.savings)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Goals: \(item.goal)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                ProgressView(value: item.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#3E2449")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}

struct SavingsView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsView()
    }
}
