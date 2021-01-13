//
//  EmojiArtDocumentChooserTest.swift
//  EmojiArtDocumentChooserTest
//
//  Created by Roger Kreienbuehl on 13.01.21.
//  Copyright © 2021 fhnw. All rights reserved.
//

import XCTest

class EmojiArtDocumentChooserTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testTitleEdit(){
        let app = XCUIApplication()
        app.launch()
        let documentsNavigationBar = app.navigationBars["Documents"]
        documentsNavigationBar.buttons["Edit"].tap()
        app.tables.children(matching: .cell).element(boundBy: 0).children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        
        //app.buttons["Keyboard"].tap()
        app.popovers.scrollViews.otherElements.buttons["Show Keyboard"].tap()
        app/*@START_MENU_TOKEN@*/.keys["delete"].press(forDuration: 1.6);/*[[".keyboards",".keys[\"Löschen\"]",".tap()",".press(forDuration: 1.6);",".keys[\"delete\"]"],[[[-1,4,2],[-1,1,2],[-1,0,1]],[[-1,4,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/
        
        let tKey = app/*@START_MENU_TOKEN@*/.keys["t"]/*[[".keyboards.keys[\"t\"]",".keys[\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tKey.tap()
        tKey.tap()
        
        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        eKey.tap()
        eKey.tap()
        
        let sKey = app/*@START_MENU_TOKEN@*/.keys["s"]/*[[".keyboards.keys[\"s\"]",".keys[\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sKey.tap()
        sKey.tap()
        tKey.tap()
        tKey.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Hide keyboard"]/*[[".keyboards.buttons[\"Hide keyboard\"]",".buttons[\"Hide keyboard\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        documentsNavigationBar.buttons["Done"].tap()
      
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
