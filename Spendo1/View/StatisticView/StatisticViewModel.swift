import Foundation
import SwiftUI

class StatisticViewModel: ObservableObject {
    struct CardItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let amount: String
        let backgroundColor: Color
        let textColor: Color
    }
    let card: [CardItem]
    init() {
        let rawCard = [
            ("fork.knife", "Food", "$200"),
            ("doc.text", "Bill", "$100"),
            ("fork.knife", "Food", "$200"),
            ("doc.text", "Bill", "$100"),
            ("fork.knife", "Food", "$200"),
            ("doc.text", "Bill", "$100"),
            ("fork.knife", "Food", "$200"),
            ("doc.text", "Bill", "$100"),
        ]
        self.card = rawCard.enumerated().map { index, item in
            let isGroupOne = (index / 2) % 2 == 0
            return CardItem(
                icon: item.0,
                title: item.1,
                amount: item.2,
                backgroundColor: isGroupOne ? Color(hex: "#3E2449") : Color(hex: "#DF835F"),
                textColor: isGroupOne ? Color(hex: "#B284C6") : Color(hex: "#EEC0AE")
            )
        }
    }
}
