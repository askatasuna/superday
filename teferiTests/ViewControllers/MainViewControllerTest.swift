//
//  MainViewControllerTest.swift
//  teferi
//
//  Created by Olga Nesterenko on 10/27/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import Nimble
import XCTest
@testable import teferi

class MainViewControllerTest: XCTestCase {
    private var mainViewController: MainViewController!
    private let settingsService = MockSettingsService()
    private let appStateService = DefaultAppStateService()
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.mainViewController = storyboard.instantiateViewController(withIdentifier: "Main") as! MainViewController
        UIApplication.shared.keyWindow!.rootViewController =
            mainViewController.inject(MockMetricsService(),
                                      appStateService,
                                      MockLocationService(),
                                      settingsService,
                                      DefaultEditStateService(),
                                      MockPersistencyService())
        self.mainViewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationPermissionViewShown() {
        settingsService.hasLocationPermission = false
        settingsService.lastLocationDate = nil
        appStateService.currentAppState = .active
        waitUntil { done in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0,
                                          execute:
                {
                    done()
                    expect(self.mainViewController.view.subviews.last is PermissionView).to(beTrue())
            })
        }
    }
    
    func testLocationPermissionViewNotShown() {
        settingsService.hasLocationPermission = true
        appStateService.currentAppState = .active
        expect(self.mainViewController.view.subviews.last is PermissionView).to(beFalse())
    }
}
