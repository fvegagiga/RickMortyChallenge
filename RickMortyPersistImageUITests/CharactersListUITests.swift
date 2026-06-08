import XCTest

final class CharactersListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Verifies that the Characters tab is the default selected tab and its
    /// navigation title appears on screen, confirming the root view is rendered.
    func testCharactersTab_isDefaultSelectedAndShowsTitle() throws {
        let charactersTab = app.tabBars.buttons["Characters"]
        XCTAssertTrue(
            charactersTab.waitForExistence(timeout: 5),
            "Characters tab should exist in the tab bar"
        )
        XCTAssertTrue(
            charactersTab.isSelected,
            "Characters tab should be selected by default"
        )

        let navTitle = app.navigationBars["Characters"]
        XCTAssertTrue(
            navTitle.waitForExistence(timeout: 10),
            "Navigation title 'Characters' should be visible"
        )
    }

    /// Verifies that tapping a character card navigates to the detail screen,
    /// confirming the NavigationStack and routing are wired correctly.
    func testTappingCharacterCard_navigatesToDetail() throws {
        let navTitle = app.navigationBars["Characters"]
        XCTAssertTrue(
            navTitle.waitForExistence(timeout: 10),
            "Characters list must load before interacting"
        )

        let firstCard = app.buttons["character-card"].firstMatch
        XCTAssertTrue(
            firstCard.waitForExistence(timeout: 15),
            "At least one character card should appear after loading"
        )

        firstCard.tap()

        // After navigation, a Back button should appear in the nav bar
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5),
            "Back button should appear after navigating to character detail"
        )
    }
}
