import Foundation

extension Timer
{
    @discardableResult static func schedule(
        withDelay delay: TimeInterval = 0,
        withRepeatingInterval interval : TimeInterval = 0,
        handler: @escaping () -> Void
        ) -> Timer
    {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, { _ in handler() })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .commonModes)
        return timer!
    }
}
