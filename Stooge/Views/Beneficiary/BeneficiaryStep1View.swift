import SwiftUI

/// Screen 1 of the "Add a Beneficiary" flow.
/// Collects personal information: name, date of birth, and relationship to the policyholder.
struct BeneficiaryStep1View: View {
    @EnvironmentObject private var vm: BeneficiaryViewModel

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("First Name", text: $vm.form.firstName)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.firstNameField)

                TextField("Last Name", text: $vm.form.lastName)
                    .textContentType(.familyName)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.lastNameField)

                DatePicker(
                    "Date of Birth",
                    selection: $vm.form.dateOfBirth,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.dobPicker)

                Picker("Relationship", selection: $vm.form.relationship) {
                    ForEach(BeneficiaryForm.Relationship.allCases) { rel in
                        Text(rel.rawValue).tag(rel)
                    }
                }
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.relationshipPicker)
            }

            Section {
                Button {
                    vm.continueToStep2()
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .font(.headline)
                        Spacer()
                    }
                }
                .disabled(!vm.canContinue)
                .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.continueButton)
            } footer: {
                if !vm.canContinue {
                    Text("First and last name are required to continue.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Add Beneficiary")
        .accessibilityIdentifier(StoogeA11y.Beneficiary.Step1.screen)
    }
}
