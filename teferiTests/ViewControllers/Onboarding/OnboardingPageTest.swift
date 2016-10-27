//
//  OnboardingPage1Test.swift
//  teferi
//
//  Created by Olga Nesterenko on 10/26/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import Nimble
import XCTest
@testable import teferi

class OnboardingPageTest: XCTestCase {
    private var onboardingPage: OnboardingPage!
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        onboardingPage = storyboard.instantiateViewController(withIdentifier: "OnboardingScreen1") as! OnboardingPage1
        UIApplication.shared.keyWindow!.rootViewController = onboardingPage
        self.onboardingPage.loadViewIfNeeded()
    }
    
    override func tearDown() {
        self.onboardingPage = nil
        super.tearDown()
    }
    
    func testTransform() -> Void {
        let view = UIView()
        onboardingPage.initAnimatedTitleText(view)
        expect(view.transform).to(equal(CGAffineTransform(translationX: 100, y: 0)))
    }
    
    func testTitleTextAnimation() -> Void {
        let view = UIView()
        let delay = 0.1
        let duration = 0.1
        let totalTestDuration = 0.2
        
        waitUntil { done in
            self.onboardingPage.animateTitleText(view, duration: duration, delay: delay)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + totalTestDuration,
                                          execute:
                {
                    done()
                    expect(view.transform).to(equal(CGAffineTransform(translationX: 0, y: 0)))
            })
        }
    }
    
    func testTimelineCreation() -> Void {
        let timeSlots = [
            TimeSlot(category: .leisure, startTime: self.onboardingPage.t(9, 30), endTime: self.onboardingPage.t(10, 0)),
            TimeSlot(category: .work, startTime: self.onboardingPage.t(10, 0), endTime: self.onboardingPage.t(10, 55))
        ]
        let cells = self.onboardingPage.initAnimatingTimeline(with: timeSlots, in: UIView())
        expect(cells.count).to(equal(timeSlots.count))
    }
    
    func testTimelineCellsAnimation() {
        let timeSlots = [
            TimeSlot(category: .leisure, startTime: self.onboardingPage.t(9, 30), endTime: self.onboardingPage.t(10, 0))
        ]
        let cells = self.onboardingPage.initAnimatingTimeline(with: timeSlots, in: UIView())
        let delay = 1 + 0.2.multiplied(by: Double(cells.count))
        let duration = 0.6.multiplied(by: Double(cells.count))
        let totalTestDuration = delay + duration
        
        waitUntil(timeout: 2) { done in
            self.onboardingPage.animateTimeline(cells, delay: 1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + totalTestDuration,
                                          execute:
                {
                    done()
                    expect(cells.first!.transform).to(equal(CGAffineTransform(translationX: 0, y: 0)))
                    expect(cells.first!.alpha).to(equal(1))
            })
        }
    }
    
    func testDateCreation() {
        let hours = 2
        let minutes = 4
        let date = self.onboardingPage.t(hours, minutes)
        
        let dateComponents = NSCalendar.current.dateComponents(in: TimeZone.current, from: date)
        expect(dateComponents.hour).to(equal(hours))
        expect(dateComponents.minute).to(equal(minutes))
    }
}
