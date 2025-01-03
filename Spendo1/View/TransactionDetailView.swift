
import SwiftUI

struct TransactionDetailView: View {
    @State private var showPopup = false
    var transaction: Transaction
    private var backgroundColor: Color {
            return transaction.type == .income ? Color(hex: "#DF835F") : Color(hex: "#3E2449")
        }
    var body: some View {
        
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                VStack(alignment: .center) {
                    
                        Text("Transaction Details")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top,30)
                    Image(systemName:transaction.type == .income ? "square.and.arrow.down" : "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                    
                    Text("$ \(transaction.amount)")
                        .font(FontScheme.kWorkSansBold(size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack (alignment: .center) {
                        HStack(alignment: .center) {
                            Text(transaction.createdat)
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        HStack(alignment: .center) {
                            
                            Image(systemName:  "checkmark.seal.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            Text("Successful")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal,30)
                .padding(.vertical, 50)
                VStack(alignment: .center) {
                    HStack {
                        Text("Detail")
                            .font(.title3)
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical,20)
                    .padding(.top,50)
                    HStack {
                        Text("Title")
                            .font(.system(size:20))
                        Spacer()
                        Text(transaction.title)
                            .font(.system(size:20))
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical,10)
                    Divider()
                        .padding(.horizontal,30)
                        .foregroundColor(.black)
                    HStack {
                        Text("Category")
                            .font(.system(size:20))
                        Spacer()
                        Text("Food")
                            .font(.system(size:20))
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical,10)
                    Divider()
                        .padding(.horizontal,30)
                        .foregroundColor(.black)
                    HStack {
                        Text("From")
                            .font(.system(size:20))
                        Spacer()
                        Text("VCB")
                            .font(.system(size:20))
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical,10)
                    Divider()
                        .padding(.horizontal,30)
                        .foregroundColor(.black)
                    HStack {
                        Text("Description")
                            .font(.system(size:20))
                        Spacer()
                        Text(transaction.description ?? "")
                            .font(.system(size:20))
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical,10)
                    Divider()
                        .padding(.horizontal,30)
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height * 0.55
                )
                .background(Color.white)
                .cornerRadius(30)
            }
            .padding(.horizontal,30)
        }
    }
}
