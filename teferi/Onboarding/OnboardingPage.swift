import UIKit
import RxSwift

class OnboardingPage : UIViewController
{
    private(set) var didAppear = false
    private(set) var nextButtonText : String?
    private(set) var settingsService : SettingsService!
    private(set) var notificationAuthorizationObservable : Observable<Bool>!
    
    private(set) var onboardingPageViewController : OnboardingPageViewController!
    
    init?(coder aDecoder: NSCoder, nextButtonText: String?)
    {
        super.init(coder: aDecoder)
        
        self.nextButtonText = nextButtonText
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inject(_ settingsService: SettingsService,
                _ onboardingPageViewController: OnboardingPageViewController,
                _ notificationAuthorizationObservable: Observable<Bool>)
    {
        self.settingsService = settingsService
        self.onboardingPageViewController = onboardingPageViewController
        self.notificationAuthorizationObservable = notificationAuthorizationObservable
    }
    
    func onAppear()
    {
        guard !self.didAppear else { return }
        self.didAppear = true
        
        self.startAnimations()
    }
    
    func finish()
    {
        self.onboardingPageViewController.goToNextPage()
    }
    
    func startAnimations()
    {
        // override in page
    }
    
    func appBecameActive()
    {
        // override in page
    }
    
    func t(_ hours : Int, _ minutes : Int) -> Date
    {
        return Date()
            .ignoreTimeComponents()
            .addingTimeInterval(TimeInterval((hours * 60 + minutes) * 60))
    }
}
