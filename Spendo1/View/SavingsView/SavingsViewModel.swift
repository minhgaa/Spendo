import Foundation
import SwiftUI

class SavingsViewModel: ObservableObject {
    struct SavingItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let date: String
        let savings: String
        let goal: String
        let progress: Double
    }
    let saving: [SavingItem] = [
        SavingItem(icon: "umbrella.fill", title: "Holiday", date: "January, 01 2025", savings: "$500", goal: "$5000", progress: 0.1),
        SavingItem(icon: "iphone", title: "Smartphone", date: "January, 01 2025", savings: "$1000", goal: "$1500", progress: 0.67),
        SavingItem(icon: "heart.fill", title: "Wedding", date: "January, 01 2025", savings: "$800", goal: "$10,000", progress: 0.08)
    ]
    init() {
    }
}
