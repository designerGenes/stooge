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

    func testTabBar_navigateToAlbums() {
        app.tabBars.buttons["Albums"].tap()
        XCTAssertTrue(app.navigationBars["Albums"].waitForExistence(timeout: 5))
    }

    func testTabBar_cycleAllTabs() {
        app.tabBars.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Albums"].tap()
        XCTAssertTrue(app.navigationBars["Albums"].waitForExistence(timeout: 5))
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

    // MARK: - Albums List

    func testAlbumsList_loads() {
        let list = albumsList()
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testAlbumsList_firstRowHasContent() {
        let firstCell = albumsList().cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertFalse(firstCell.label.isEmpty)
    }

    // MARK: - Album Detail

    func testAlbumDetail_opensOnRowTap() {
        albumsList().cells.element(boundBy: 0).tap()
        let grid = app.scrollViews.matching(
            beginsWith: StoogeA11y.Albums.Detail.photosGridPrefix
        ).firstMatch
        XCTAssertTrue(grid.waitForExistence(timeout: 10))
    }

    func testAlbumDetail_showsPhotoTiles() {
        albumsList().cells.element(boundBy: 0).tap()
        let firstTile = app.otherElements.matching(
            beginsWith: StoogeA11y.Albums.Detail.photoTilePrefix
        ).firstMatch
        XCTAssertTrue(firstTile.waitForExistence(timeout: 15))
    }

    func testAlbumDetail_backNavigationReturnsToAlbums() {
        albumsList().cells.element(boundBy: 0).tap()
        let grid = app.scrollViews.matching(
            beginsWith: StoogeA11y.Albums.Detail.photosGridPrefix
        ).firstMatch
        XCTAssertTrue(grid.waitForExistence(timeout: 10))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Albums"].waitForExistence(timeout: 5))
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

    /// Navigate to Albums tab and wait for the albums list to appear.
    @discardableResult
    func albumsList() -> XCUIElement {
        app.tabBars.buttons["Albums"].tap()
        let list = app.collectionViews[StoogeA11y.Albums.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15), "Albums list did not appear")
        return list
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
}

// MARK: - XCUIElementQuery Helpers

private extension XCUIElementQuery {

    /// Matches elements whose accessibility identifier begins with the given prefix.
    func matching(beginsWith prefix: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "identifier BEGINSWITH '\(prefix)'"))
    }
}
