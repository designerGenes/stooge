import SwiftUI

/// Confirmation screen shown after a beneficiary is successfully added.
struct BeneficiaryConfirmationView: View {
    @EnvironmentObject private var vm: BeneficiaryViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: 10) {
                Text("Beneficiary Added")
                    .font(.title.bold())

                Text(vm.form.fullName)
                    .font(.title2)
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Confirmation.nameLabel)

                Text("\(Int(vm.form.allocationPercent))% allocation · \(vm.form.relationship.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Confirmation.allocationLabel)
            }

            Spacer()

            VStack(spacing: 14) {
                Button("Done") {
                    vm.reset()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Confirmation.doneButton)

                Button("Add Another") {
                    vm.reset()
                }
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Confirmation.addAnotherButton)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Success")
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(StoogeA11y.Beneficiary.Confirmation.screen)
    }
}
