import UIKit

extension UIView
{
    static func animate(withDuration duration: TimeInterval,
                        options: UIViewAnimationOptions, animations: @escaping () -> ())
    {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
    }
    
    static func animate(withDuration duration: TimeInterval, delay: TimeInterval,
                 options: UIViewAnimationOptions, animations: @escaping () -> ())
    {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: nil)
    }
    
    static func animate(withDuration duration: TimeInterval, delay: TimeInterval,
                 animations: @escaping () -> ())
    {
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: animations, completion: nil)
    }
    
    
    static func scheduleAnimation(withDelay delay: TimeInterval, duration: TimeInterval,
                                  options: UIViewAnimationOptions, animations: @escaping () -> ())
    {
        Timer.schedule(withDelay: delay)
        {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        }
    }
    
    static func scheduleAnimation(withDelay delay: TimeInterval, duration: TimeInterval, animations: @escaping () -> ())
    {
        Timer.schedule(withDelay: delay)
        {
            UIView.animate(withDuration: duration, delay: 0, options: [], animations: animations, completion: nil)
        }
    }
}
