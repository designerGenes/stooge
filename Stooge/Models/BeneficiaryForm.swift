import Foundation

struct BeneficiaryForm {
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    var relationship: Relationship = .spouse
    var allocationPercent: Double = 100
    var phone: String = ""
    var notes: String = ""

    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }

    enum Relationship: String, CaseIterable, Identifiable {
        case spouse  = "Spouse"
        case child   = "Child"
        case parent  = "Parent"
        case sibling = "Sibling"
        case other   = "Other"

        var id: String { rawValue }
    }
}
