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

    func testNavigateToAlbumsTab() {
        app.tabBars.buttons["Albums"].tap()
        XCTAssertTrue(app.navigationBars["Albums"].waitForExistence(timeout: 5))
    }

    func testSwitchBetweenAllTabs() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["People"].tap()
        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 5))
        tabBar.buttons["Albums"].tap()
        XCTAssertTrue(app.navigationBars["Albums"].waitForExistence(timeout: 5))
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

    // MARK: - Albums List

    func testAlbumsListLoads() {
        app.tabBars.buttons["Albums"].tap()

        let list = app.collectionViews[StoogeA11y.Albums.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        XCTAssertGreaterThan(list.cells.count, 0)
    }

    func testTappingAlbumNavigatesToPhotoGrid() {
        app.tabBars.buttons["Albums"].tap()

        let list = app.collectionViews[StoogeA11y.Albums.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let grid = app.scrollViews.matching(
            NSPredicate(format: "identifier BEGINSWITH '\(StoogeA11y.Albums.Detail.photosGridPrefix)'")
        ).firstMatch
        XCTAssertTrue(grid.waitForExistence(timeout: 10))
    }

    func testAlbumDetailShowsPhotos() {
        app.tabBars.buttons["Albums"].tap()

        let list = app.collectionViews[StoogeA11y.Albums.list]
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.cells.element(boundBy: 0).tap()

        let firstPhoto = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH '\(StoogeA11y.Albums.Detail.photoTilePrefix)'")
        ).firstMatch
        XCTAssertTrue(firstPhoto.waitForExistence(timeout: 15))
    }
}
