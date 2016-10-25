import RxSwift
import RxCocoa
import UIKit
import CoreGraphics

class TimelineViewController : UITableViewController
{
    // MARK: Fields
    private var editingIndex = -1
    private var hasInitialized = false
    
    private static let baseCellHeight = 40
    private let disposeBag = DisposeBag()
    private let viewModel : TimelineViewModel
    private var editStateService : EditStateService
    
    private let cellIdentifier = "timelineCell"
    private let emptyCellIdentifier = "emptyStateView"
    
    private lazy var footerCell : UITableViewCell = { return UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120)) }()
    
    //MARK: Initializers
    init(date: Date, metricsService: MetricsService, editStateService: EditStateService, persistencyService: PersistencyService)
    {
        self.editStateService = editStateService
        self.viewModel = TimelineViewModel(date: date,
                                           metricsService: metricsService,
                                           persistencyService: persistencyService)
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("NSCoder init is not supported for this ViewController")
    }
    
    // MARK: Properties
    var date : Date { return self.viewModel.date }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        self.tableView.register(UINib.init(nibName: "EmptyStateView", bundle: Bundle.main), forCellReuseIdentifier: emptyCellIdentifier)
    
        self.viewModel
            .timeSlotsObservable
            .subscribe(onNext: self.onNewTimeSlotAvailable)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel
            .timeObservable
            .subscribe(onNext: self.onTimeTick)
            .addDisposableTo(self.disposeBag)
        
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: self.onIsEditing)
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: Methods
    private func onNewTimeSlotAvailable(timeSlots: [TimeSlot])
    {
        self.tableView.reloadData()
        
        let rowAnimation = self.hasInitialized ? UITableViewRowAnimation.top : .none
        
        let updateIndexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        self.tableView.reloadRows(at: [updateIndexPath], with: rowAnimation)
        
        let scrollIndexPath = IndexPath(row: viewModel.timeSlots.count, section: 0)
        self.tableView.scrollToRow(at: scrollIndexPath, at: .bottom, animated: true)
        
        self.hasInitialized = true
    }
    
    private func onIsEditing(isEditing: Bool)
    {
        self.tableView.isEditing = isEditing
        self.tableView.isScrollEnabled = !isEditing
        
        if self.tableView.isEditing || self.editingIndex == -1 { return }
        
        let indexPath = IndexPath(row: self.editingIndex, section: 0)
        self.tableView.reloadRows(at: [ indexPath ], with: .fade)
        self.editingIndex = -1
    }
    
    private func onTimeTick(time: Int)
    {
        guard !tableView.isEditing else { return }
        
        let indexPath = IndexPath(row: viewModel.timeSlots.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private func onCategoryTapped(point: CGPoint, index: Int)
    {
        self.editingIndex = index
        self.editStateService.notifyEditingBegan(point: point, timeSlot: self.viewModel.timeSlots[index])
    }
    
    // MARK: UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.timeSlots.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard self.viewModel.timeSlots.count > 0 else
        {
            return tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath);
        }
        
        let index = indexPath.item
        
        if index == self.viewModel.timeSlots.count { return footerCell }
        
        let timeSlot = self.viewModel.timeSlots[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimelineCell;
        
        cell.bind(toTimeSlot: timeSlot, index: index)
        
        if !cell.isSubscribedToClickObservable
        {
            cell.editClickObservable
                .subscribe(onNext: onCategoryTapped)
                .addDisposableTo(disposeBag)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard self.viewModel.timeSlots.count > 0 else
        {
            return self.view.frame.height
        }
        
        let index = indexPath.item
        
        if index == self.viewModel.timeSlots.count { return 120 }
        
        let timeSlot = self.viewModel.timeSlots[index]
        let isRunning = timeSlot.endTime == nil
        
        return TimelineViewController.timelineCellHeight(
            duration: timeSlot.duration, isRunning: isRunning)
    }
    
    static func timelineCellHeight(duration : TimeInterval, isRunning : Bool) -> CGFloat
    {
        let interval = Int(duration)
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let height = baseCellHeight
            + Constants.minLineSize * (1 + (minutes / 15) + (hours * 4))
            + (isRunning ? 8 : 0)
        
        return CGFloat(height)
    }
}
