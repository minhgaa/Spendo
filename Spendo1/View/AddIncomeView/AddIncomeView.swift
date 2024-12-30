import SwiftUI

struct AddIncomeView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var createdOn: Date = Date()
    @State private var isEditing: Bool = false
    @State private var showPopup = true
    @State private var selectedAmount: Double = 0
    @State private var inputAmount: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Spendo")
                    .font(FontScheme.kWorkSansBold(size: 20))
                    .foregroundColor(Color(hex: "#3E2449"))
                Spacer()
                Image(systemName: "square.and.arrow.down")
                Text("Income")
                    .font(FontScheme.kWorkSansBold(size: 15))
                    .foregroundColor(Color(hex: "#3E2449"))
                    .padding(.top,2)
            }
            TextField("Income Title", text: $title)
                .font(FontScheme.kWorkSansBold(size: 32))
                .foregroundColor(.black)

            Divider()
            VStack {
                Button(action: {
                    showPopup.toggle()
                }) {
                    HStack {
                        Text("+ Add Money")
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#3E2449"))
                    }
                    .frame(maxWidth: 150)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: "#3E2449"), lineWidth: 1)
                    )
                }
            }
            .sheet(isPresented: $showPopup) {
                VStack {
                    HStack {
                        Text("Add money to")
                            .font(FontScheme.kWorkSansBold(size: 20))
                            .padding()
                        Spacer()
                        Button(action: {
                            showPopup.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .padding()
                                .foregroundColor(.black)
                                
                        }
                    }
                    .padding()
                    HStack{
                        
                    }
                    HStack{
                        Text(inputAmount.isEmpty ? "0" : inputAmount)
                            .font(FontScheme.kWorkSansSemiBold(size: 36))
                            
                        Text("$")
                            .font(FontScheme.kWorkSansRegular(size: 36))
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            CalculatorButton(title: "7", action: { appendNumber("7") })
                            CalculatorButton(title: "8", action: { appendNumber("8") })
                            CalculatorButton(title: "9", action: { appendNumber("9") })
                        }
                        HStack {
                            CalculatorButton(title: "4", action: { appendNumber("4") })
                            CalculatorButton(title: "5", action: { appendNumber("5") })
                            CalculatorButton(title: "6", action: { appendNumber("6") })
                        }
                        HStack {
                            CalculatorButton(title: "1", action: { appendNumber("1") })
                            CalculatorButton(title: "2", action: { appendNumber("2") })
                            CalculatorButton(title: "3", action: { appendNumber("3") })
                        }
                        HStack {
                            CalculatorButton(title: "0", action: { appendNumber("0") })
                            CalculatorButton(title: ".", action: { appendDot() })
                            Button(action: {
                                inputAmount = ""
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30))
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        }
                    }
                    .padding(.bottom,20)
                    
                    Button("Add") {
                        if let amount = Double(inputAmount) {
                            selectedAmount = amount
                        }
                        showPopup = false
                    }
                    .frame(width: 100, height: 45)
                    .background(Color(hex: "#DF835F"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
            }
            
                
            Button(action: {
            }) {
                HStack {
                    Text("+ Add category")
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#3E2449"))
                }
                .frame(maxWidth: 167)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(hex: "#3E2449"), lineWidth: 1)
                )
            }
            HStack(alignment: .top) {
                Image(systemName: "text.justify")
                    .foregroundColor(.gray)
                    .padding(.top, isEditing ? 8 : 0)
                
                ZStack(alignment: .topLeading) {
                    if description.isEmpty && !isEditing {
                        Text("Add description")
                            .foregroundColor(.gray)
                            .font(FontScheme.kWorkSansMedium(size: 14))
                            .padding(.top, isEditing ? 8 : 0)
                            .padding(.leading, 4)
                            .onTapGesture {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                    }
                    if isEditing {
                        if #available(iOS 16.0, *) {
                            TextEditor(text: $description)
                                .foregroundColor(.black)
                                .font(FontScheme.kWorkSansMedium(size: 14))
                                .padding(.leading, -4)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .frame(height: isEditing ? 120 : 30)
                                .onTapGesture {
                                    withAnimation {
                                        isEditing = false
                                    }
                                }
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .animation(.easeInOut, value: isEditing)


            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text("Created on")
                    .foregroundColor(.gray)
                    .font(FontScheme.kWorkSansMedium(size: 14))
                Spacer()
                DatePicker(
                        "",
                        selection: $createdOn,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack {
                Spacer()
                Button(action: {
                }) {
                    Text("Add Income")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color(hex: "#DF835F"))
                        .cornerRadius(40)
                }
            }
            Spacer()
        }
        .padding()
        .padding(.horizontal)
    }
    private func appendNumber(_ number: String) {
            inputAmount += number
        }
        private func appendDot() {
            if !inputAmount.contains(".") {
                inputAmount += "."
            }
        }
}
struct CalculatorButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.black, lineWidth: 1)
                )
        }

        
        
    }
}
struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        AddIncomeView()
    }
}
