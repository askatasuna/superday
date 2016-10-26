import UIKit
import RxSwift
import CoreData

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate
{   
    //MARK: Fields
    private let disposeBag = DisposeBag()
    private let notificationAuthorizationVariable = Variable(false)
    
    private let metricsService : MetricsService
    private let loggingService : LoggingService
    private var appStateService : AppStateService
    private let locationService : LocationService
    private let settingsService : SettingsService
    private let editStateService : EditStateService
    private let persistencyService : PersistencyService
    private let notificationService : NotificationService
    private let timeSlotCreationService : TimeSlotCreationService
    
    //MARK: Properties
    var window: UIWindow?
    
    //Initializers
    override init()
    {
        self.metricsService = FabricMetricsService()
        self.appStateService = DefaultAppStateService()
        self.settingsService = DefaultSettingsService()
        self.editStateService = DefaultEditStateService()
        self.loggingService = SwiftyBeaverLoggingService()
        self.locationService = DefaultLocationService(loggingService: self.loggingService)
        self.persistencyService = CoreDataPersistencyService(loggingService: self.loggingService)
        self.notificationService = DefaultNotificationService(loggingService: self.loggingService)
        self.timeSlotCreationService =
            DefaultTimeSlotCreationService(settingsService: self.settingsService,
                                           persistencyService: self.persistencyService,
                                           loggingService: self.loggingService,
                                           notificationService: self.notificationService)
    }
    
    //MARK: UIApplicationDelegate lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let isInBackground = launchOptions?[UIApplicationLaunchOptionsKey.location] != nil
        
        //Starts location tracking
        self.locationService
            .locationObservable
            .subscribe(onNext: self.timeSlotCreationService.onNewLocation)
            .addDisposableTo(disposeBag)
        
        self.locationService.startLocationTracking()
        
        //Faster startup when the app wakes up for location updates
        if isInBackground { return true }
        
        self.initializeWindowIfNeeded()
        
        return true
    }
    
    private func initializeWindowIfNeeded()
    {
        guard self.window == nil else { return }
        
        self.metricsService.initialize()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "Main") as! MainViewController
        var initialViewController : UIViewController =
            mainViewController.inject(self.metricsService,
                                      self.appStateService,
                                      self.locationService,
                                      self.settingsService,
                                      self.editStateService,
                                      self.persistencyService)
        
        if self.settingsService.installDate == nil
        {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let onboardController = storyboard.instantiateViewController(withIdentifier: "OnboardingPager") as! OnboardingPageViewController
            
            initialViewController =
                onboardController.inject(settingsService,
                                         appStateService,
                                         mainViewController,
                                         notificationAuthorizationVariable.asObservable())
            
            mainViewController.setIsFirstUse()
        }
        
        self.window!.rootViewController = initialViewController
        self.window!.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.appStateService.currentAppState = .inactive
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.locationService.startLocationTracking()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.appStateService.currentAppState = .active
        self.initializeWindowIfNeeded()
        self.notificationService.unscheduleAllNotifications()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        self.notificationAuthorizationVariable.value = true
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL =
    {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.toggl.teferi" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel =
    {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "teferi", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
    {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext =
    {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support
    func saveContext ()
    {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
