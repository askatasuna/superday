import UIKit
import RxSwift
import SnapKit

class OnboardingPageViewController: UIViewController
{
    //MARK: Fields
    fileprivate lazy var pages : [OnboardingPage] = { return (1...4).map { i in self.page("\(i)") } } ()
    
    private var launchAnim : LaunchAnimationView!
    fileprivate let scrollView = UIScrollView()
    
    @IBOutlet var pager: OnboardingPager!
    
    private var settingsService : SettingsService!
    private var mainViewController : MainViewController!
    private var notificationUpdateObservable : Observable<Bool>!
    
    fileprivate var currentPageIndex = 0
    
    var allowsSwipe = true {
        didSet {
            self.scrollView.isUserInteractionEnabled = allowsSwipe
        }
    }
    
    //MARK: ViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
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
        
        self.setupPages()
        
        
        self.pages.first!.onAppear()
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
    
    func goToNextPage()
    {
        
        guard let _ = self.pageAt(index: currentPageIndex + 1) else
        {
            self.settingsService.setInstallDate(Date())
            self.present(self.mainViewController, animated: false)
            return
        }
        self.scrollView.setContentOffset(self.contentOffset(for: self.currentPageIndex + 1),
                                         animated: true)
    }
    
    private func setupPages() {
        var lastView: UIView? = nil
        
        for page in self.pages {
            self.installViewController(childViewController: page, inside: scrollView)
            page.view.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.leading.equalTo(lastView != nil ? lastView!.snp.trailing : scrollView.snp.leading)
                make.height.width.equalToSuperview()
            })
            lastView = page.view
        }
        lastView!.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
        }
    }
    
    private func contentOffset(for pageIndex: NSInteger) -> CGPoint {
        return CGPoint(x: self.scrollView.frame.width.multiplied(by: CGFloat(pageIndex)), y: 0)
    }

    fileprivate func pageAt(index : Int) -> OnboardingPage?
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
    
    fileprivate func onNew(page: OnboardingPage)
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
}

extension OnboardingPageViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        self.onScrollFinished(with: targetContentOffset.pointee)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.onScrollFinished(with: scrollView.contentOffset)
    }
    
    private func onScrollFinished(with contentOffset: CGPoint) {
        self.currentPageIndex = Int(contentOffset.x.divided(by: scrollView.frame.width))
        print(self.currentPageIndex)
        if let page = self.pageAt(index: self.currentPageIndex) {
            page.onAppear()
            self.onNew(page: page)
        }
    }
}
