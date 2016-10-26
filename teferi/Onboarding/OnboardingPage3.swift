import UIKit
import RxSwift
import CoreLocation

class OnboardingPage3 : OnboardingPage, CLLocationManagerDelegate
{
    private var locationManager: CLLocationManager!
    private var disposeBag : DisposeBag? = DisposeBag()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        disposeBag = disposeBag ?? DisposeBag()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(disposeBag!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedAlways || status == .denied
        {
            if status == .authorizedAlways
            {
                self.settingsService.setAllowedLocationPermission()
            }
            
            self.finish()
        }
    }
    
    override func finish() {
        super.finish()
        disposeBag = nil
    }
    
    func onAppStateChanged(appState: AppState) {
        if appState == .active {
            if self.onboardingPageViewController.isCurrent(page: self) && !self.settingsService.hasLocationPermission {
                locationManager.requestAlwaysAuthorization()
            }
        }
    }
}
