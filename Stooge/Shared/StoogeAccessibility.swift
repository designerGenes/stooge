/// Single source of truth for Stooge's accessibility identifiers.
///
/// This file is compiled directly into the main app target, `StoogeUITests`,
/// and `ShadowTests`. Any rename or removal of a case produces a compile error
/// in every consumer — making drift between the app and its external test suite
/// immediately visible rather than silently failing at runtime.
enum StoogeA11y {

    enum TabBar {
        static let root        = "main-tab-bar"
        static let feed        = "tab-feed"
        static let people      = "tab-people"
        static let beneficiary = "tab-beneficiary"
    }

    enum Posts {
        static let list             = "posts-list"
        static let loadingIndicator = "posts-loading-indicator"
        static let errorView        = "posts-error-view"

        /// Prefix for dynamic per-row identifiers. Use when building NSPredicates.
        static let rowPrefix = "post-row-"
        static func row(_ id: Int) -> String { "\(rowPrefix)\(id)" }

        enum Detail {
            static let loadingIndicator = "post-detail-loading-indicator"
            static let title            = "post-title"
            static let authorLink       = "post-author-link"
            static let body             = "post-body"
            static let commentsList     = "comments-list"

            static let containerPrefix  = "post-detail-"
            static func container(_ id: Int) -> String { "\(containerPrefix)\(id)" }

            static let commentRowPrefix = "comment-row-"
            static func commentRow(_ id: Int) -> String { "\(commentRowPrefix)\(id)" }
        }
    }

    enum Users {
        static let list             = "users-list"
        static let loadingIndicator = "users-loading-indicator"
        static let errorView        = "users-error-view"

        static let rowPrefix = "user-row-"
        static func row(_ id: Int) -> String { "\(rowPrefix)\(id)" }

        enum Detail {
            static let loadingIndicator = "user-detail-loading-indicator"
            static let name             = "user-name"
            static let username         = "user-username"
            static let email            = "user-email"
            static let phone            = "user-phone"
            static let website          = "user-website"
            static let companyName      = "user-company-name"
            static let postsSection     = "user-posts-section"

            static let containerPrefix  = "user-detail-"
            static func container(_ id: Int) -> String { "\(containerPrefix)\(id)" }

            static let postRowPrefix    = "user-post-row-"
            static func postRow(_ id: Int) -> String { "\(postRowPrefix)\(id)" }
        }
    }

    enum Albums {
        static let list             = "albums-list"
        static let loadingIndicator = "albums-loading-indicator"
        static let errorView        = "albums-error-view"

        static let rowPrefix = "album-row-"
        static func row(_ id: Int) -> String { "\(rowPrefix)\(id)" }

        enum Detail {
            static let loadingIndicator = "album-detail-loading-indicator"

            static let photosGridPrefix = "album-photos-grid-"
            static func photosGrid(_ id: Int) -> String { "\(photosGridPrefix)\(id)" }

            static let photoTilePrefix  = "photo-tile-"
            static func photoTile(_ id: Int) -> String { "\(photoTilePrefix)\(id)" }
        }
    }

    enum Beneficiary {
        static let flowRoot = "beneficiary-flow-root"

        enum Step1 {
            static let screen             = "beneficiary-step1-screen"
            static let firstNameField     = "beneficiary-firstname-field"
            static let lastNameField      = "beneficiary-lastname-field"
            static let dobPicker          = "beneficiary-dob-picker"
            static let relationshipPicker = "beneficiary-relationship-picker"
            static let continueButton     = "beneficiary-continue-button"
        }

        enum Step2 {
            static let screen               = "beneficiary-step2-screen"
            static let allocationSlider     = "beneficiary-allocation-slider"
            static let allocationValueLabel = "beneficiary-allocation-value-label"
            static let phoneField           = "beneficiary-phone-field"
            static let notesField           = "beneficiary-notes-field"
            static let submitButton         = "beneficiary-submit-button"
        }

        enum Confirmation {
            static let screen           = "beneficiary-confirmation-screen"
            static let nameLabel        = "beneficiary-confirmation-name"
            static let allocationLabel  = "beneficiary-confirmation-allocation"
            static let doneButton       = "beneficiary-done-button"
            static let addAnotherButton = "beneficiary-add-another-button"
        }
    }

    enum Components {
        static let errorRetryButton = "error-retry-button"
    }
}
