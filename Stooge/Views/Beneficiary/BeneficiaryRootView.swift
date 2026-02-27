import SwiftUI

struct BeneficiaryRootView: View {
    @StateObject private var vm = BeneficiaryViewModel()

    var body: some View {
        NavigationStack(path: $vm.path) {
            BeneficiaryStep1View()
                .navigationDestination(for: BeneficiaryRoute.self) { route in
                    switch route {
                    case .step2:
                        BeneficiaryStep2View()
                    case .confirmation:
                        BeneficiaryConfirmationView()
                    }
                }
        }
        .environmentObject(vm)
        .accessibilityIdentifier(StoogeA11y.Beneficiary.flowRoot)
    }
}
