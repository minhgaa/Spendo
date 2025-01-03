import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    struct TransItem: Identifiable {
        let id: Int
        let title: String
        let date: String
        let amount: Decimal
        let color: Color
    }
    struct CardItem: Identifiable {
        let id: Int
        let date: String
        let textColor: Color
        let title: String
        let amount: String
        let backgroundColor: Color
        let buttonColor: Color
        let frameColor: Color
    }

    let cards: [CardItem]
    let trans: [TransItem]
    init() {
        let rawCard = [
            ("16 November 2024", "Electric", "$100",1),
            ("16 November 2024", "Spaylater", "$100",2),
            ("16 November 2024", "Electric", "$100",3),
            ("16 November 2024", "Spaylater", "$100",4),
            ("16 November 2024", "Electric", "$100",5),
            ("16 November 2024", "Spaylater", "$100",6),
        ]
        let rawTrans = [
            ("Mama Bank", "16.11.2024", 1000,1),
            ("Dinner", "16.11.2024", -100,2),
            ("Mama Bank", "16.11.2024", 1000,3),
            ("Dinner", "16.11.2024", -100,4),
            ("Mama Bank", "16.11.2024", 1000,5),
            ("Dinner", "16.11.2024", -100,6),
        ]
        self.cards = rawCard.enumerated().map { index, item in
            let isEven = index % 2 == 0
            return CardItem(
                id: item.3,
                date: item.0,
                textColor: isEven ? Color(hex: "#B284C6") : Color(hex: "#EEC0AE"),
                title: item.1,
                amount: item.2,
                backgroundColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F"),
                buttonColor: isEven ? Color(hex: "#3E2449") : Color(hex: "#DF835F"),
                frameColor: isEven ? Color(hex: "#926EA1") : Color(hex: "#F1BE7B")
            )
        }
        self.trans = rawTrans.enumerated().map { index, item in
            let isRed = Float(item.2) < 0
            return TransItem(
                id: item.3,
                title: item.0,
                date: item.1,
                amount: Decimal(item.2),
                color: isRed ? .red : .green)}
    }
}
