import SwiftUI

/// Screen 2 of the "Add a Beneficiary" flow.
/// Collects coverage allocation percentage, a contact phone number, and optional notes.
struct BeneficiaryStep2View: View {
    @EnvironmentObject private var vm: BeneficiaryViewModel

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Allocation")
                        Spacer()
                        Text("\(Int(vm.form.allocationPercent))%")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.allocationValueLabel)
                    }
                    Slider(value: $vm.form.allocationPercent, in: 1...100, step: 1)
                        .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.allocationSlider)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Coverage Allocation")
            } footer: {
                Text("Percentage of the policy benefit \(vm.form.firstName) will receive.")
            }

            Section("Contact") {
                TextField("Phone Number", text: $vm.form.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.phoneField)
            }

            Section("Notes (Optional)") {
                TextField("Any additional notes…", text: $vm.form.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.notesField)
            }

            Section {
                Button {
                    vm.submit()
                } label: {
                    HStack {
                        Spacer()
                        Text("Add Beneficiary")
                            .font(.headline)
                        Spacer()
                    }
                }
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.submitButton)
            }
        }
        .navigationTitle("Coverage Details")
        .accessibilityIdentifier(StoogeA11y.Beneficiary.Step2.screen)
    }
}
