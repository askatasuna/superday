import UIKit
import RxSwift

class OnboardingPage : UIViewController
{
    private(set) var didAppear = false
    private(set) var nextButtonText : String?
    private(set) var settingsService : SettingsService!
    private(set) var notificationAuthorizationObservable : Observable<Bool>!

    private(set) var onboardingPageViewController : OnboardingPageViewController!

    var allowPagingSwipe : Bool { return self.nextButtonText != nil }
    
    init?(coder aDecoder: NSCoder, nextButtonText: String?)
    {
        super.init(coder: aDecoder)
        
        self.nextButtonText = nextButtonText
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appBecameActive),
                                               name: Notification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func inject(_ settingsService: SettingsService,
                _ onboardingPageViewController: OnboardingPageViewController,
                _ notificationAuthorizationObservable: Observable<Bool>)
    {
        self.settingsService = settingsService
        self.onboardingPageViewController = onboardingPageViewController
        self.notificationAuthorizationObservable = notificationAuthorizationObservable
    }
    
    override func viewDidAppear(_ animated: Bool)
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
    
    @objc func appBecameActive()
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
