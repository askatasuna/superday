//
//  OnboardingPage3Test.swift
//  teferi
//
//  Created by Olga Nesterenko on 10/27/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import Nimble
import RxSwift
import XCTest
@testable import teferi

class OnboardingPageViewControllerTest: XCTestCase {
    private var onBoardingPageViewController: OnboardingPageViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        self.onBoardingPageViewController = (storyboard.instantiateViewController(withIdentifier: "OnboardingPager") as! OnboardingPageViewController).inject(MockSettingsService(),
                                                                                                                                                              MainViewController(),
                                                                                                                                                              Variable(false).asObservable())
        self.onBoardingPageViewController.loadViewIfNeeded()
        UIApplication.shared.keyWindow!.rootViewController = onBoardingPageViewController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPagerInitialized() {
        expect(self.onBoardingPageViewController.pager).toNot(beNil())
    }
    
    func testDataSourceSet() {
        expect(self.onBoardingPageViewController.dataSource).toNot(beNil())
    }
    
    func testDelegateSet() {
        expect(self.onBoardingPageViewController.delegate).toNot(beNil())
    }
    
    func testGoToNextPage() {
        let page = self.onBoardingPageViewController.viewControllers!.first!
        onBoardingPageViewController.goToNextPage()
        expect(self.onBoardingPageViewController.viewControllers!.first).toNot(equal(page))
    }
    
    func testAllowsPagingSwipe() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let page = storyboard.instantiateViewController(withIdentifier: "OnboardingScreen3") as! OnboardingPage3
        page.startAnimations()
        expect(self.onBoardingPageViewController.pageViewController(self.onBoardingPageViewController, viewControllerAfter: page))
            .to(beNil())
        expect(self.onBoardingPageViewController.pageViewController(self.onBoardingPageViewController, viewControllerBefore: page))
            .to(beNil())
    }
}
