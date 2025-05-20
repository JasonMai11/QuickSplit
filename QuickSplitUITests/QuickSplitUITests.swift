//
//  QuickSplitUITests.swift
//  QuickSplitUITests
//
//  Created by Jason Mai on 5/20/25.
//

import XCTest

final class QuickSplitUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testWelcomeScreen() throws {
        // Verify welcome screen elements
        XCTAssertTrue(app.images["receipt"].exists)
        XCTAssertTrue(app.staticTexts["Welcome to QuickSplit"].exists)
        XCTAssertTrue(app.staticTexts["Scan a receipt to get started"].exists)
        XCTAssertTrue(app.buttons["Scan Receipt"].exists)
        XCTAssertTrue(app.buttons["Enter Manually"].exists)
    }
    
    func testManualEntry() throws {
        // Navigate to manual entry
        app.buttons["Enter Manually"].tap()
        
        // Enter item details
        let itemNameTextField = app.textFields["Item Name"]
        let priceTextField = app.textFields["Price"]
        let quantityStepper = app.steppers["Quantity"]
        let addButton = app.buttons["Add Item"]
        
        XCTAssertTrue(itemNameTextField.exists)
        XCTAssertTrue(priceTextField.exists)
        XCTAssertTrue(quantityStepper.exists)
        XCTAssertTrue(addButton.exists)
        
        itemNameTextField.tap()
        itemNameTextField.typeText("Test Item")
        
        priceTextField.tap()
        priceTextField.typeText("10.00")
        
        addButton.tap()
        
        // Verify item was added
        XCTAssertTrue(app.staticTexts["Test Item"].exists)
        XCTAssertTrue(app.staticTexts["$10.00"].exists)
    }
    
    func testTipAdjustment() throws {
        // Add an item first
        app.buttons["Enter Manually"].tap()
        
        let itemNameTextField = app.textFields["Item Name"]
        let priceTextField = app.textFields["Price"]
        
        itemNameTextField.tap()
        itemNameTextField.typeText("Test Item")
        
        priceTextField.tap()
        priceTextField.typeText("10.00")
        
        app.buttons["Add Item"].tap()
        
        // Adjust tip percentage
        let tipSlider = app.sliders["Tip Percentage"]
        tipSlider.adjust(toNormalizedSliderPosition: 0.5) // Set to 15%
        
        // Verify tip calculation
        XCTAssertTrue(app.staticTexts["Tip Amount"].exists)
        let tipAmount = app.staticTexts["Tip Amount"].label
        XCTAssertTrue(tipAmount.contains("$1.50")) // 15% of $10.00
    }
    
    func testTaxToggle() throws {
        // Add an item first
        app.buttons["Enter Manually"].tap()
        
        let itemNameTextField = app.textFields["Item Name"]
        let priceTextField = app.textFields["Price"]
        
        itemNameTextField.tap()
        itemNameTextField.typeText("Test Item")
        
        priceTextField.tap()
        priceTextField.typeText("10.00")
        
        app.buttons["Add Item"].tap()
        
        // Toggle tax
        let taxToggle = app.switches["Include Tax"]
        taxToggle.tap()
        
        // Verify tax is removed
        XCTAssertFalse(app.staticTexts["Tax Label"].exists)
        
        taxToggle.tap()
        
        // Verify tax is added back
        XCTAssertTrue(app.staticTexts["Tax Label"].exists)
        XCTAssertTrue(app.staticTexts["Tax Amount"].exists)
    }
    
    func testShareFunctionality() throws {
        // Add an item first
        app.buttons["Enter Manually"].tap()
        
        let itemNameTextField = app.textFields["Item Name"]
        let priceTextField = app.textFields["Price"]
        
        itemNameTextField.tap()
        itemNameTextField.typeText("Test Item")
        
        priceTextField.tap()
        priceTextField.typeText("10.00")
        
        app.buttons["Add Item"].tap()
        
        // Try to share
        let shareButton = app.buttons["Share Split"]
        XCTAssertTrue(shareButton.exists)
        
        shareButton.tap()
        
        // Verify share sheet appears
        XCTAssertTrue(app.sheets["Share Sheet"].exists)
        
        // Note: We can't test the actual share sheet actions as they're system UI
        // But we can verify the share sheet appeared
    }
}
