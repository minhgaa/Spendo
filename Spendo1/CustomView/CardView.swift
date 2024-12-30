import SwiftUI

struct CardView: View {
    let date: String
    let textColor: Color
    let title: String
    let amount: String
    let backgroundColor: Color
    let buttonColor: Color
    let frameColor: Color
    
    var body: some View {
        VStack(alignment: .center) {
            Text(date)
                .font(FontScheme.kWorkSansRegular(size: 15))
                .foregroundColor(textColor)
                .padding(.top)
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(FontScheme.kWorkSansRegular(size: 13))
                        .foregroundColor(.white)
                    Text(amount)
                        .font(FontScheme.kWorkSansSemiBold(size: 20))
                        .foregroundColor(.white)
                }
                .padding()
                Spacer()
                Button(action: {}) {
                    Image(systemName: "arrow.up.right")
                        .padding()
                        .background(Circle().fill(Color.white))
                        .foregroundColor(buttonColor)
                }
                .padding()
            }
            .frame(width: 180, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(frameColor))
            
        }
        .padding()
        .frame(width: 220, height: 170)
        .background(backgroundColor)
        .cornerRadius(30)
    }
}

