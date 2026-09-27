import XCTest

final class week2UITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testComputerAddCheckAndCount() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add Computer"].tap()
        let save = app.buttons["saveComputer"]
        XCTAssertFalse(save.isEnabled)
        let name = app.textFields["computerName"]
        name.tap()
        name.typeText("PC06")
        save.tap()
        XCTAssertTrue(app.staticTexts["PC06"].waitForExistence(timeout: 5))
        app.swipeUp()
        XCTAssertEqual(app.staticTexts["computerTotal"].label, "Total computers: 6")
        app.buttons["Check Computer"].tap()
        let search = app.textFields["checkComputerName"]
        search.tap()
        search.typeText("pc06")
        app.buttons["Check"].tap()
        XCTAssertTrue(app.staticTexts["pc06 is in the lab!"].exists)
    }

    @MainActor
    func testStudentAddEditSearchAndRemove() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Students"].tap()
        app.buttons["Add Student"].tap()
        let id = app.textFields["studentID"]
        id.tap()
        id.typeText("S006")
        let name = app.textFields["studentName"]
        name.tap()
        name.typeText("Mai")
        let gpa = app.textFields["studentGPA"]
        gpa.tap()
        gpa.typeText("8.7")
        app.buttons["saveStudent"].tap()
        XCTAssertTrue(app.buttons["student-S006"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["studentTotal"].label, "Total students: 6")
        app.buttons["student-S006"].tap()
        let editGPA = app.textFields["studentGPA"]
        editGPA.tap()
        editGPA.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "9.5")
        app.buttons["saveStudent"].tap()
        XCTAssertTrue(app.staticTexts["GPA: 9.5"].exists)
        app.swipeDown()
        app.swipeDown()
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("S006")
        XCTAssertTrue(app.buttons["student-S006"].exists)
        XCTAssertFalse(app.buttons["student-S001"].exists)
        // Deleting a filtered result must remove S006, not the first source element.
        app.buttons["student-S006"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["No matching students."].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["studentTotal"].label, "Total students: 5")
    }
}
