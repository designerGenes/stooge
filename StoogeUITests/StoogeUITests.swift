import XCTest

final class StoogeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Bar

    func testTabBarIsPresent() {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    func testFeedTabIsSelectedOnLaunch() {
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    func testNavigateToPeopleTab() {
        app.tabBars.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
    }

    func testNavigateToBeneficiaryTab() {
        app.tabBars.buttons["Add Beneficiary"].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testSwitchBetweenAllTabs() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
        tabBar.buttons["Add Beneficiary"].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
        tabBar.buttons["Feed"].tap()
        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    // MARK: - Posts List

    func testPostsListLoads() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testPostsListContainsExpectedFirstRow() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))

        let firstCell = list.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertFalse(firstCell.label.isEmpty)
    }

    func testPostsListCanScrollDown() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.swipeUp()
        XCTAssertTrue(list.cells.count > 0)
    }

    func testPostsListCanPullToRefresh() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))

        let firstCell = list.cells.element(boundBy: 0)
        firstCell.swipeDown()

        XCTAssertTrue(list.waitForExistence(timeout: 15))
    }

    // MARK: - Post Detail

    func testTappingPostNavigatesToDetail() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))

        list.cells.element(boundBy: 0).tap()

        XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
    }

    func testPostDetailShowsTitle() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let title = app.staticTexts[StoogeA11y.Posts.Detail.title]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertFalse(title.label.isEmpty)
    }

    func testPostDetailShowsBody() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let body = app.staticTexts[StoogeA11y.Posts.Detail.body]
        XCTAssertTrue(body.waitForExistence(timeout: 10))
        XCTAssertFalse(body.label.isEmpty)
    }

    func testPostDetailShowsComments() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let comments = app.otherElements[StoogeA11y.Posts.Detail.commentsList]
        XCTAssertTrue(comments.waitForExistence(timeout: 10))
    }

    func testPostDetailAuthorLinkNavigatesToUserProfile() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let authorLink = app.buttons[StoogeA11y.Posts.Detail.authorLink]
        XCTAssertTrue(authorLink.waitForExistence(timeout: 10))
        authorLink.tap()

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testBackNavigationFromPostDetail() {
        let list = app.collectionViews[StoogeA11y.Posts.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()

        XCTAssertTrue(app.navigationBars["Feed"].waitForExistence(timeout: 5))
    }

    // MARK: - Users List

    func testUsersListLoads() {
        app.tabBars.buttons["People"].tap()

        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testTappingUserNavigatesToProfile() {
        app.tabBars.buttons["People"].tap()

        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testUserDetailShowsName() {
        app.tabBars.buttons["People"].tap()

        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let name = app.staticTexts[StoogeA11y.Users.Detail.name]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        XCTAssertFalse(name.label.isEmpty)
    }

    func testUserDetailShowsUsername() {
        app.tabBars.buttons["People"].tap()

        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let username = app.staticTexts[StoogeA11y.Users.Detail.username]
        XCTAssertTrue(username.waitForExistence(timeout: 10))
        XCTAssertTrue(username.label.hasPrefix("@"))
    }

    func testUserDetailPostsNavigateToPostDetail() {
        app.tabBars.buttons["People"].tap()

        let list = app.collectionViews[StoogeA11y.Users.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let userDetail = app.collectionViews.matching(
            NSPredicate(format: "identifier BEGINSWITH '\(StoogeA11y.Users.Detail.containerPrefix)'")
        ).firstMatch
        XCTAssertTrue(userDetail.waitForExistence(timeout: 10))

        let firstPostRow = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH '\(StoogeA11y.Users.Detail.postRowPrefix)'")
        ).firstMatch
        if firstPostRow.waitForExistence(timeout: 5) {
            firstPostRow.tap()
            XCTAssertTrue(app.navigationBars["Post"].waitForExistence(timeout: 5))
        }
    }

    // MARK: - Beneficiary Flow: Tab Entry

    func testBeneficiaryTab_step1AppearsOnTap() {
        navigateToBeneficiaryTab()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Step 1 — Personal Info

    func testBeneficiaryStep1_firstNameFieldIsPresent() {
        navigateToBeneficiaryTab()
        XCTAssertTrue(app.textFields[StoogeA11y.Beneficiary.Step1.firstNameField].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep1_lastNameFieldIsPresent() {
        navigateToBeneficiaryTab()
        XCTAssertTrue(app.textFields[StoogeA11y.Beneficiary.Step1.lastNameField].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep1_dobPickerIsPresent() {
        navigateToBeneficiaryTab()
        XCTAssertTrue(app.datePickers[StoogeA11y.Beneficiary.Step1.dobPicker].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep1_continueButtonIsDisabledWhenNamesEmpty() {
        navigateToBeneficiaryTab()
        let btn = app.buttons[StoogeA11y.Beneficiary.Step1.continueButton]
        XCTAssertTrue(btn.waitForExistence(timeout: 5))
        XCTAssertFalse(btn.isEnabled)
    }

    func testBeneficiaryStep1_continueButtonEnabledAfterFillingNames() {
        navigateToBeneficiaryTab()
        typeIntoField(StoogeA11y.Beneficiary.Step1.firstNameField, text: "Jane")
        typeIntoField(StoogeA11y.Beneficiary.Step1.lastNameField, text: "Doe")
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
        XCTAssertTrue(app.sliders[StoogeA11y.Beneficiary.Step2.allocationSlider].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep2_allocationValueLabelIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(app.staticTexts[StoogeA11y.Beneficiary.Step2.allocationValueLabel].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep2_phoneFieldIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(app.textFields[StoogeA11y.Beneficiary.Step2.phoneField].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep2_notesFieldIsPresent() {
        fillStep1AndContinue()
        XCTAssertTrue(app.textFields[StoogeA11y.Beneficiary.Step2.notesField].waitForExistence(timeout: 5))
    }

    func testBeneficiaryStep2_submitButtonNavigatesToConfirmation() {
        fillStep1AndContinue()
        app.buttons[StoogeA11y.Beneficiary.Step2.submitButton].tap()
        XCTAssertTrue(app.navigationBars["Success"].waitForExistence(timeout: 5))
    }

    // MARK: - Beneficiary Flow: Confirmation

    func testBeneficiaryConfirmation_showsNameLabel() {
        fillAndSubmit()
        let label = app.staticTexts[StoogeA11y.Beneficiary.Confirmation.nameLabel]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertTrue(label.label.contains("Jane"))
    }

    func testBeneficiaryConfirmation_showsAllocationLabel() {
        fillAndSubmit()
        XCTAssertTrue(
            app.staticTexts[StoogeA11y.Beneficiary.Confirmation.allocationLabel].waitForExistence(timeout: 5)
        )
    }

    func testBeneficiaryConfirmation_doneButtonReturnsToStep1() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.doneButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testBeneficiaryConfirmation_addAnotherButtonReturnsToStep1() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.addAnotherButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func testBeneficiaryConfirmation_formIsResetAfterDone() {
        fillAndSubmit()
        app.buttons[StoogeA11y.Beneficiary.Confirmation.doneButton].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
        // After reset, First Name field should be empty
        let firstNameField = app.textFields[StoogeA11y.Beneficiary.Step1.firstNameField]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 5))
        XCTAssertEqual(firstNameField.value as? String ?? "", "")
    }
}

// MARK: - Helpers

private extension StoogeUITests {

    func navigateToBeneficiaryTab() {
        app.tabBars.buttons["Add Beneficiary"].tap()
        XCTAssertTrue(app.navigationBars["Add Beneficiary"].waitForExistence(timeout: 5))
    }

    func typeIntoField(_ identifier: String, text: String) {
        let field = app.textFields[identifier]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    func fillStep1AndContinue() {
        navigateToBeneficiaryTab()
        typeIntoField(StoogeA11y.Beneficiary.Step1.firstNameField, text: "Jane")
        typeIntoField(StoogeA11y.Beneficiary.Step1.lastNameField, text: "Doe")
        let continueBtn = app.buttons[StoogeA11y.Beneficiary.Step1.continueButton]
        XCTAssertTrue(continueBtn.waitForExistence(timeout: 5))
        continueBtn.tap()
        XCTAssertTrue(app.navigationBars["Coverage Details"].waitForExistence(timeout: 5))
    }

    func fillAndSubmit() {
        fillStep1AndContinue()
        let submitBtn = app.buttons[StoogeA11y.Beneficiary.Step2.submitButton]
        XCTAssertTrue(submitBtn.waitForExistence(timeout: 5))
        submitBtn.tap()
        XCTAssertTrue(app.navigationBars["Success"].waitForExistence(timeout: 5))
    }
}
