//
//  SCLAlertViewTests.swift
//  SCLAlertViewTests
//
//  Created by Alexey Poimtsev on 22/05/15.
//  Copyright (c) 2015 Alexey Poimtsev. All rights reserved.
//

@testable import SCLAlertView

import UIKit
import XCTest

class SCLAlertViewStyleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSCLAlertViewStyleColorSuccess() {
        let style = SCLAlertViewStyle.success
        XCTAssertTrue(style.defaultColor == UIColorFromRGB(0x22B573))
    }
    
    func testSCLAlertViewStyleColorError() {
        let style = SCLAlertViewStyle.error
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
            .red
        )
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
            UIColorFromRGB(0xC1272D)
        )
    }
    
    func testSCLAlertViewStyleColorNotice() {
        let style = SCLAlertViewStyle.notice
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
            UIColorFromRGB(0xC6C6C6)
        )
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
            UIColorFromRGB(0x727375)
        )
    }
    
    func testSCLAlertViewStyleColorWarning() {
        let style = SCLAlertViewStyle.warning
        XCTAssertTrue(style.defaultColor == UIColorFromRGB(0xFFD110))
    }
    
    func testSCLAlertViewStyleColorInfo() {
        let style = SCLAlertViewStyle.info
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
            UIColorFromRGB(0x6ABCE7)
        )
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
            UIColorFromRGB(0x2866BF)
        )
    }
    
    func testSCLAlertViewStyleColorEdit() {
        let style = SCLAlertViewStyle.edit
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
            UIColorFromRGB(0xD194FF)
        )
        XCTAssertEqual(
            style.defaultColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
            UIColorFromRGB(0xA429FF)
        )
    }
    
    func testSCLAlertViewStyleColorWait() {
        let style = SCLAlertViewStyle.wait
        XCTAssertTrue(style.defaultColor == UIColorFromRGB(0xD62DA5))
    }
    
    func testSCLButtonTypeOnCreate() {
        let button = SCLButton()
        XCTAssertTrue(button.actionType == SCLActionType.none)
    }
 
}

fileprivate extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}
