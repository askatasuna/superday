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
        self.onboardingPageViewController.allowsSwipe = false
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
            self.onboardingPageViewController.allowsSwipe = true
            self.finish()
        }
    }
}
