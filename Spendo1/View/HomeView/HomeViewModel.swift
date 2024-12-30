import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    struct TransItem: Identifiable {
        let id = UUID()
        let title: String
        let date: String
        let amount: Float
        let color: Color
    }
    struct CardItem: Identifiable {
        let id = UUID()
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
            ("16 November 2024", "Electric", "$100"),
            ("16 November 2024", "Spaylater", "$100"),
            ("16 November 2024", "Electric", "$100"),
            ("16 November 2024", "Spaylater", "$100"),
            ("16 November 2024", "Electric", "$100"),
            ("16 November 2024", "Spaylater", "$100"),
        ]
        let rawTrans = [
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
            ("Mama Bank", "16.11.2024", 1000),
            ("Dinner", "16.11.2024", -100),
        ]
        self.cards = rawCard.enumerated().map { index, item in
            let isEven = index % 2 == 0
            return CardItem(
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
                title: item.0,
                date: item.1,
                amount: Float(item.2),
                color: isRed ? .red : .green)}
    }
}
