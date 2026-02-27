import Foundation
import SwiftUI

enum BeneficiaryRoute: Hashable {
    case step2
    case confirmation
}

@MainActor
final class BeneficiaryViewModel: ObservableObject {
    @Published var form = BeneficiaryForm()
    @Published var path = NavigationPath()

    var canContinue: Bool {
        !form.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !form.lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func continueToStep2() {
        path.append(BeneficiaryRoute.step2)
    }

    func submit() {
        path.append(BeneficiaryRoute.confirmation)
    }

    func reset() {
        form = BeneficiaryForm()
        path = NavigationPath()
    }
}
