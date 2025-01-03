import SwiftUI

class TabViewModel: ObservableObject {
    @Published var selectedTab: String = "Home"
    
    let tabs: [TabItem] = [
        TabItem(title: "Home", icon: "house", tag: "Home"),
        TabItem(title: "Stats", icon: "chart.bar", tag: "Stats"),
        TabItem(title: "Add", icon: "plus.circle", tag: "Add"),
        TabItem(title: "Wallet", icon: "creditcard", tag: "Wallet"),
        TabItem(title: "Budget", icon: "person.crop.circle", tag: "Budget")
    ]
}
