import UIKit
import RxSwift

class OnboardingPage4 : OnboardingPage
{
    private var notificationSubscription : Disposable?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        self.notificationSubscription =
            self.notificationAuthorizationObservable
                .subscribe(onNext: { wasSet in
                    
                    guard wasSet else { return }
                    
                    self.notificationSubscription?.dispose()
                    self.finish()
                })
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge ], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
}
