import UIKit
import CoreLocation

class OnboardingPage3 : OnboardingPage, CLLocationManagerDelegate
{
    var locationManager: CLLocationManager!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
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
    
    override func appBecameActive() {
        if self.onboardingPageViewController.isCurrent(page: self) &&		 !self.settingsService.hasLocationPermission {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
