import UIKit
import RxSwift
import SnapKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    //MARK: Fields
    private lazy var pages : [OnboardingPage] = { return (1...4).map { i in self.page("\(i)") } } ()
    
    private var launchAnim : LaunchAnimationView!
    
    @IBOutlet var pager: OnboardingPager!
    
    private var settingsService : SettingsService!
    private var mainViewController : MainViewController!
    private var notificationUpdateObservable : Observable<Bool>!
    
    //MARK: ViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        self.view.backgroundColor = UIColor.white
        self.setViewControllers([pages.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        pageControl.pageIndicatorTintColor = UIColor.green.withAlphaComponent(0.4)
        pageControl.currentPageIndicatorTintColor = UIColor.green
        pageControl.backgroundColor = UIColor.clear
        
        self.view.addSubview(self.pager)
        self.pager.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(102)
        }
        
        self.pager.createPageDots(forPageCount: self.pages.count)
        
        self.launchAnim = LaunchAnimationView(frame: self.view.bounds)
        self.view.addSubview(self.launchAnim)
        self.startLaunchAnimation()
    }
    
    //MARK: Actions
    @IBAction func pagerButtonTouchUpInside()
    {
        self.goToNextPage()
    }
    
    //MARK: Methods
    func inject(_ settingsService : SettingsService,
                _ mainViewController: MainViewController,
                _ notificationUpdateObservable: Observable<Bool>) -> OnboardingPageViewController
    {
        self.settingsService = settingsService
        self.mainViewController = mainViewController
        self.notificationUpdateObservable = notificationUpdateObservable
        return self
    }
    
    private func startLaunchAnimation()
    {
        //Small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim.animate(onCompleted:
            {
                self.launchAnim.removeFromSuperview()
                self.launchAnim = nil
            })
        }
    }
    
    func isCurrent(page: OnboardingPage) -> Bool {
        return page == self.viewControllers?.first
    }
    
    func goToNextPage()
    {
        let currentPageIndex = self.index(of: self.viewControllers!.first!)!
        guard let nextPage = self.pageAt(index: currentPageIndex + 1) else
        {
            self.settingsService.setInstallDate(Date())
            self.present(self.mainViewController, animated: false)
            return
        }
        
        self.setViewControllers([nextPage],
                                direction: .forward,
                                animated: true,
                                completion: nil)
        self.onNew(page: nextPage)
    }
    
    private func pageAt(index : Int) -> OnboardingPage?
    {
        return 0..<self.pages.count ~= index ? self.pages[index] : nil
    }
    
    private func index(of viewController: UIViewController) -> Int?
    {
        return self.pages.index(of: viewController as! OnboardingPage)
    }
    
    private func page(_ id: String) -> OnboardingPage
    {
        let page = UIStoryboard(name: "Onboarding", bundle: nil)
            .instantiateViewController(withIdentifier: "OnboardingScreen\(id)")
            as! OnboardingPage
        
        page.inject(self.settingsService, self, self.notificationUpdateObservable)
        return page
    }
    
    private func onNew(page: OnboardingPage)
    {
        if let buttonText = page.nextButtonText
        {
            self.pager.showNextButton(withText: buttonText)
        }
        else
        {
            self.pager.hideNextButton()
        }
        self.pager.switchPage(to: self.index(of: page)!)
    }
    
    // MARK: UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        let page = pendingViewControllers.first as! OnboardingPage
        
        if page.nextButtonText != nil
        {
            self.pager.clearButtonText()
        }
        else
        {
            self.pager.hideNextButton()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        let page = self.viewControllers!.first as! OnboardingPage
        self.onNew(page: page)
    }
    
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = self.index(of: viewController) else { return nil }
        
        return self.pageAt(index: currentPageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let currentPageIndex = self.index(of: viewController) else { return nil }
        
        return self.pageAt(index: currentPageIndex + 1)
    }
}
