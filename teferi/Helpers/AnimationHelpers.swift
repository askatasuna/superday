import Foundation
import UIKit

func animateLayer<T : CALayer>(
    _ layer : T,
    duration : Double,
    timingFunction : CAMediaTimingFunction? = nil,
    animation : (T) -> Void,
    properties : String...
    )
{
    animateLayerImpl(layer, duration: duration, timingFunction: timingFunction, animation: animation, properties: properties)
}

func animateLayer<T : CALayer>(
    _ layer : T,
    duration : Double,
    delay : Double,
    timingFunction : CAMediaTimingFunction? = nil,
    animation : @escaping (T) -> Void,
    properties : String...
    )
{
    if delay <= 0 {
        animateLayerImpl(layer, duration: duration, timingFunction: timingFunction, animation: animation, properties: properties)
        return;
    }
    
    Timer.schedule(withDelay: delay) {
        animateLayerImpl(layer, duration: duration, timingFunction: timingFunction, animation: animation, properties: properties)
    }
}

func animateLayerImpl<T : CALayer>(
    _ layer : T,
    duration : Double,
    timingFunction : CAMediaTimingFunction?,
    animation : (T) -> Void,
    properties : [String]
    )
{
    CATransaction.setDisableActions(true)
    animation(layer)
    for property in properties {
        let anim = CABasicAnimation(keyPath: property)
        anim.timingFunction = timingFunction
        anim.duration = duration
        layer.add(anim, forKey: nil)
    }
}
