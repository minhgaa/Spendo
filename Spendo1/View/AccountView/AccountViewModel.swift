import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    struct AccountItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let amount: Float
        let income: Float
        let outcome: Float
        let backgroundColor: Color
    }
    struct TransItem: Identifiable {
        let id = UUID()
        let title: String
        let date: String
        let amount: Float
        let color: Color
    }
    let trans: [TransItem]
    let account: [AccountItem]

    init() {
        let rawTrans = [
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
        ]
        let rawAccount = [
            ( "dollarsign.circle.fill" ,"CASH", 1000, 1200, 200),
            ( "creditcard.fill" ,"VCB", 1000, 1200, 200),
            ( "dollarsign.circle.fill" ,"CASH", 1000, 1200, 200),
            ( "creditcard.fill" ,"VCB", 1000, 1200, 200),
            
        ]
        self.account = rawAccount.enumerated().map { index, item in
            let isEven = index % 2 == 0
            return AccountItem(
                icon: item.0,
                title: item.1,
                amount: Float(item.2),
                income: Float(item.3),
                outcome: Float(item.4),
                backgroundColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F")
            )
        }
        self.trans = rawTrans.enumerated().map { index, item in
            let isRed = Float(item.2) < 0
            return TransItem(
                title: item.0,
                date: item.1,
                amount: Float(item.2),
                color: isRed ? .red : .green)}
    }
}
