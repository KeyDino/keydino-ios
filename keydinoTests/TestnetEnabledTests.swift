//
//  TestnetEnabledTests.swift
//  keydino
//
//  Created by Brendan E. Mahon on 1/13/18.
//  Copyright © 2018 KeyDino LLC. All rights reserved.
//

import XCTest
@testable import breadwallet

class TouchIdEnabledTests : XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "istestnetenabled")
    }
    
    func testUserDefaultsStorage() {
        XCTAssertFalse(UserDefaults.isTestnetEnabled, "Default value is false")
        UserDefaults.isTestnetEnabled = true
        XCTAssertTrue(UserDefaults.isTestnetEnabled, "Should be true after being set to true")
        UserDefaults.isTestnetEnabled = false
        XCTAssertFalse(UserDefaults.isTestnetEnabled, "Should be false after being set to false")
    }
    
    func testInitialState() {
        UserDefaults.isTestnetEnabled = true
        let state = State.initial
        XCTAssertTrue(state.isTestnetEnabled, "Initial state should be same as stored value")
        
        UserDefaults.isTestnetEnabled = false
        let state2 = State.initial
        XCTAssertFalse(state2.isTestnetEnabled, "Initial state should be same as stored value")
    }
    
    func testTestnetAction() {
        UserDefaults.isTestnetEnabled = true
        let store = Store()
        store.perform(action: Testnet.setIsEnabled(false))
        XCTAssertFalse(UserDefaults.isTestnetEnabled, "Actions should persist new value")
    }
    
}

