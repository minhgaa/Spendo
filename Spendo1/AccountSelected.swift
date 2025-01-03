import SwiftUI
import Combine

class AccountSelectionManager: ObservableObject {
    @Published var selectedAccount: AccountViewModel.AccountItem? = nil
}
