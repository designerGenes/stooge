import XCTest

/// External test suite that drives Stooge entirely through its bundle identifier.
///
/// This target has no compile-time dependency on the Stooge module. Instead, it
/// references accessibility identifiers through `StoogeA11y`, which is compiled
/// directly into this target from `Stooge/Shared/StoogeAccessibility.swift`.
///
/// **Why this matters for synchronization:**
/// Because both the app's views and these tests reference the same Swift symbols —
/// not raw strings — any structural change to `StoogeA11y` (rename, removal) produces
/// a compile error here immediately. There is no window where a silent string mismatch
/// can slip through undetected.
final class ShadowStoogeTests: XCTestCase {

    /// Targeting by bundle identifier is what makes this an "external" driver.
    /// In a real multi-app test orchestration setup, this test bundle would live
    /// in an entirely separate Xcode project, and this one line is all that's
    /// needed to point it at the app under test.
    private let bundleID = "com.designerGenes.Stooge"

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: bundleID)
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Tab Bar

    func testTabBar_isPresent() {
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testTabBar_feedIsSelectedOnLaunch() {
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    func testTabBar_navigateToPeople() {
        app.tabBars.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
    }

    func testTabBar_navigateToBeneficiary() {
        app.tabBars.buttons["Add Beneficiary"].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testTabBar_cycleAllTabs() {
        app.tabBars.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Add Beneficiary"].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Feed"].tap()
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    // MARK: - Posts List

    func testPostsList_loads() {
        let list = postsList()
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testPostsList_firstRowHasContent() {
        let firstCell = postsList().cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertFalse(firstCell.label.isEmpty)
    }

    func testPostsList_canScrollDown() {
        let list = postsList()
        list.swipeUp()
        XCTAssertTrue(list.exists)
    }

    func testPostsList_canPullToRefresh() {
        let list = postsList()
        list.cells.element(boundBy: 0).swipeDown()
        XCTAssertTrue(list.waitForExistence(timeout: 15))
    }

    // MARK: - Post Detail

    func testPostDetail_opensOnRowTap() {
        postsList().cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
    }

    func testPostDetail_showsTitle() {
        openFirstPost()
        let title = app.staticTexts[StoogeA11y.Posts.Detail.title]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertFalse(title.label.isEmpty)
    }

    func testPostDetail_showsBody() {
        openFirstPost()
        let body = app.staticTexts[StoogeA11y.Posts.Detail.body]
        XCTAssertTrue(body.waitForExistence(timeout: 10))
        XCTAssertFalse(body.label.isEmpty)
    }

    func testPostDetail_showsAuthorLink() {
        openFirstPost()
        let authorLink = app.buttons[StoogeA11y.Posts.Detail.authorLink]
        XCTAssertTrue(authorLink.waitForExistence(timeout: 10))
    }

    func testPostDetail_showsCommentsList() {
        openFirstPost()
        let comments = app.otherElements[StoogeA11y.Posts.Detail.commentsList]
        XCTAssertTrue(comments.waitForExistence(timeout: 10))
    }

    func testPostDetail_commentsListHasRows() {
        openFirstPost()
        XCTAssertTrue(app.otherElements[StoogeA11y.Posts.Detail.commentsList].waitForExistence(timeout: 10))

        let firstComment = app.otherElements.matching(
            beginsWith: StoogeA11y.Posts.Detail.commentRowPrefix
        ).firstMatch
        XCTAssertTrue(firstComment.waitForExistence(timeout: 10))
    }

    func testPostDetail_backNavigationReturnsToFeed() {
        openFirstPost()
        XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    // MARK: - Users List

    func testUsersList_loads() {
        let list = usersList()
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testUsersList_firstRowHasContent() {
        let firstCell = usersList().cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertFalse(firstCell.label.isEmpty)
    }

    func testUsersList_canScrollDown() {
        let list = usersList()
        list.swipeUp()
        XCTAssertTrue(list.exists)
    }

    // MARK: - User Detail

    func testUserDetail_opensOnRowTap() {
        usersList().cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testUserDetail_showsName() {
        openFirstUser()
        let name = app.staticTexts[StoogeA11y.Users.Detail.name]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        XCTAssertFalse(name.label.isEmpty)
    }

    func testUserDetail_showsUsername_withAtPrefix() {
        openFirstUser()
        let username = app.staticTexts[StoogeA11y.Users.Detail.username]
        XCTAssertTrue(username.waitForExistence(timeout: 10))
        XCTAssertTrue(username.label.hasPrefix("@"),
                      "Expected username to start with '@', got: \(username.label)")
    }

    func testUserDetail_showsEmail() {
        openFirstUser()
        XCTAssertTrue(app.otherElements[StoogeA11y.Users.Detail.email].waitForExistence(timeout: 10))
    }

    func testUserDetail_showsPhone() {
        openFirstUser()
        XCTAssertTrue(app.otherElements[StoogeA11y.Users.Detail.phone].waitForExistence(timeout: 10))
    }

    func testUserDetail_showsWebsite() {
        openFirstUser()
        XCTAssertTrue(app.otherElements[StoogeA11y.Users.Detail.website].waitForExistence(timeout: 10))
    }

    func testUserDetail_showsCompanyName() {
        openFirstUser()
        XCTAssertTrue(app.otherElements[StoogeA11y.Users.Detail.companyName].waitForExistence(timeout: 10))
    }

    func testUserDetail_showsPostsSection() {
        openFirstUser()
        let postsSection = app.otherElements[StoogeA11y.Users.Detail.postsSection]
        XCTAssertTrue(postsSection.waitForExistence(timeout: 10))
    }

    func testUserDetail_backNavigationReturnsToPeople() {
        openFirstUser()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Tab Entry

    func testBeneficiary_tabNavigatesToStep1() {
        beneficiaryTab()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Step 1 — Personal Info

    func testBeneficiaryStep1_firstNameFieldIsPresent() {
        beneficiaryTab()
        XCTAssertTrue(
            app.textFields[StoogeA11y.Beneficiary.Step1.firstNameField].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep1_lastNameFieldIsPresent() {
        beneficiaryTab()
        XCTAssertTrue(
            app.textFields[StoogeA11y.Beneficiary.Step1.lastNameField].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep1_dobPickerIsPresent() {
        beneficiaryTab()
        XCTAssertTrue(
            app.datePickers[StoogeA11y.Beneficiary.Step1.dobPicker].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep1_continueDisabledWhenEmpty() {
        beneficiaryTab()
        let btn = app.buttons[StoogeA11y.Beneficiary.Step1.continueButton]
        XCTAssertTrue(btn.waitForExistence(timeout: 5))
        XCTAssertFalse(btn.isEnabled)
    }

    func testBeneficiaryStep1_continueEnabledAfterNames() {
        beneficiaryTab()
        typeField(StoogeA11y.Beneficiary.Step1.firstNameField, text: "Jane")
        typeField(StoogeA11y.Beneficiary.Step1.lastNameField, text: "Doe")
        let btn = app.buttons[StoogeA11y.Beneficiary.Step1.continueButton]
        XCTAssertTrue(btn.waitForExistence(timeout: 5))
        XCTAssertTrue(btn.isEnabled)
    }

    func testBeneficiaryStep1_continueNavigatesToStep2() {
        fillStep1AndContinue()
        XCTAssertTrue(app.navigationBars["Coverage Details"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Step 2 — Coverage Details

    func testBeneficiaryStep2_allocationSliderIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(
            app.sliders[StoogeA11y.Beneficiary.Step2.allocationSlider].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep2_allocationValueLabelShowsPercent() {
        fillStep1AndContinue()
        let label = app.staticTexts[StoogeA11y.Beneficiary.Step2.allocationValueLabel]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertTrue(label.label.hasSuffix("%"),
                      "Expected allocation label to end with '%', got: \(label.label)")
    }

    func testBeneficiaryStep2_phoneFieldIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(
            app.textFields[StoogeA11y.Beneficiary.Step2.phoneField].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep2_notesFieldIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(
            app.textFields[StoogeA11y.Beneficiary.Step2.notesField].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryStep2_submitNavigatesToConfirmation() {
        fillStep1AndContinue()
        app.buttons[StoogeA11y.Beneficiary.Step2.submitButton].tap()
        XCTAssertTrue(app.navigationBars["Success"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Confirmation

    func testBeneficiaryConfirmation_showsNameLabel() {
        fillAndSubmit()
        let label = app.staticTexts[StoogeA11y.Beneficiary.Confirmation.nameLabel]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertTrue(label.label.contains("Jane"),
                      "Expected confirmation name to contain 'Jane', got: \(label.label)")
    }

    func testBeneficiaryConfirmation_showsAllocationLabel() {
        fillAndSubmit()
        let label = app.staticTexts[StoogeA11y.Beneficiary.Confirmation.allocationLabel]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertTrue(label.label.contains("%"),
                      "Expected allocation label to contain '%', got: \(label.label)")
    }

    func testBeneficiaryConfirmation_doneReturnsToStep1() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.doneButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testBeneficiaryConfirmation_addAnotherReturnsToStep1() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.addAnotherButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testBeneficiaryConfirmation_formIsResetAfterDone() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.doneButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
        let firstNameField = app.textFields[StoogeA11y.Beneficiary.Step1.firstNameField]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 5))
        XCTAssertEqual(firstNameField.value as? String ?? "", "")
    }

    // MARK: - Cross-Screen Navigation

    func testCrossNav_postAuthorLinkToUserProfile() {
        openFirstPost()
        let authorLink = app.buttons[StoogeA11y.Posts.Detail.authorLink]
        XCTAssertTrue(authorLink.waitForExistence(timeout: 10))
        authorLink.tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[StoogeA11y.Users.Detail.name].waitForExistence(timeout: 10))
    }

    func testCrossNav_userDetailPostToPostDetail() {
        openFirstUser()

        // Scroll down to reveal the Posts section
        let userDetailList = app.collectionViews.matching(
            beginsWith: StoogeA11y.Users.Detail.containerPrefix
        ).firstMatch
        XCTAssertTrue(userDetailList.waitForExistence(timeout: 10))
        userDetailList.swipeUp()

        let firstPostRow = app.buttons.matching(
            beginsWith: StoogeA11y.Users.Detail.postRowPrefix
        ).firstMatch
        if firstPostRow.waitForExistence(timeout: 5) {
            firstPostRow.tap()
            XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts[StoogeA11y.Posts.Detail.title].waitForExistence(timeout: 10))
        }
    }
}

// MARK: - Navigation Helpers

private extension ShadowStoogeTests {

    /// Navigate to Feed tab and wait for the posts list to appear.
    @discardableResult
    func postsList() -> XCUIElement {
        app.tabBars.buttons["Feed"].tap()
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15), "Posts list did not appear")
        return list
    }

    /// Navigate to People tab and wait for the users list to appear.
    @discardableResult
    func usersList() -> XCUIElement {
        app.tabBars.buttons["People"].tap()
        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15), "Users list did not appear")
        return list
    }

    /// Navigate to Add Beneficiary tab and wait for Step 1 to appear.
    @discardableResult
    func beneficiaryTab() -> XCUIElement {
        app.tabBars.buttons["Add Beneficiary"].tap()
        let screen = app.navigationBars["Add Beneficiary"]
        XCTAssertTrue(screen.waitForExistence(timeout: 5), "Beneficiary Step 1 did not appear")
        return screen
    }

    /// Open the first post and wait for the detail navigation bar.
    func openFirstPost() {
        postsList().cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
    }

    /// Open the first user and wait for the profile navigation bar.
    func openFirstUser() {
        usersList().cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    /// Type text into a form TextField by accessibility identifier.
    func typeField(_ identifier: String, text: String) {
        let field = app.textFields[identifier]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    /// Fill Step 1 with "Jane Doe" and tap Continue.
    func fillStep1AndContinue() {
        beneficiaryTab()
        typeField(StoogeA11y.Beneficiary.Step1.firstNameField, text: "Jane")
        typeField(StoogeA11y.Beneficiary.Step1.lastNameField, text: "Doe")
        let continueBtn = app.buttons[StoogeA11y.Beneficiary.Step1.continueButton]
        XCTAssertTrue(continueBtn.waitForExistence(timeout: 5))
        continueBtn.tap()
        XCTAssertTrue(app.navigationBars["Coverage Details"].waitForExistence(timeout: 5))
    }

    /// Fill Step 1, advance to Step 2, and tap Submit.
    func fillAndSubmit() {
        fillStep1AndContinue()
        let submitBtn = app.buttons[StoogeA11y.Beneficiary.Step2.submitButton]
        XCTAssertTrue(submitBtn.waitForExistence(timeout: 5))
        submitBtn.tap()
        XCTAssertTrue(app.navigationBars["Success"].waitForExistence(timeout: 5))
    }
}

// MARK: - XCUIElementQuery Helpers

private extension XCUIElementQuery {

    /// Matches elements whose accessibility identifier begins with the given prefix.
    func matching(beginsWith prefix: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "identifier BEGINSWITH '\(prefix)'"))
    }
}
