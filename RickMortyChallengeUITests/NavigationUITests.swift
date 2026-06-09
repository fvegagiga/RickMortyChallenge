import XCTest

final class NavigationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Verifies that all three tabs — Characters, Locations, Episodes — are
    /// present and can be tapped, confirming the TabView routing is complete.
    func testTabBar_containsAllThreeTabs() throws {
        let tabBar = app.tabBars

        let charactersTab = tabBar.buttons["Characters"]
        let locationsTab  = tabBar.buttons["Locations"]
        let episodesTab   = tabBar.buttons["Episodes"]

        XCTAssertTrue(
            charactersTab.waitForExistence(timeout: 5),
            "Characters tab must exist"
        )
        XCTAssertTrue(
            locationsTab.exists,
            "Locations tab must exist"
        )
        XCTAssertTrue(
            episodesTab.exists,
            "Episodes tab must exist"
        )
    }

    /// Verifies switching between tabs navigates to the correct screen by
    /// confirming the respective navigation bar title is shown.
    func testSwitchingTabs_showsCorrectNavigationTitle() throws {
        // First confirm Characters is visible
        XCTAssertTrue(
            app.navigationBars["Characters"].waitForExistence(timeout: 10),
            "Characters nav title should be visible on launch"
        )

        // Switch to Locations
        app.tabBars.buttons["Locations"].tap()
        XCTAssertTrue(
            app.navigationBars["Locations"].waitForExistence(timeout: 10),
            "Locations nav title should be visible after switching"
        )

        // Switch to Episodes
        app.tabBars.buttons["Episodes"].tap()
        XCTAssertTrue(
            app.navigationBars["Episodes"].waitForExistence(timeout: 10),
            "Episodes nav title should be visible after switching"
        )

        // Switch back to Characters
        app.tabBars.buttons["Characters"].tap()
        XCTAssertTrue(
            app.navigationBars["Characters"].waitForExistence(timeout: 5),
            "Characters nav title should be visible after switching back"
        )
    }
}
