func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension UIView {
    func shake(shakeMe:Bool) {
        let animationKey = "shake"
        layer.removeAnimationForKey(animationKey)

        if (shakeMe){
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 1.0
            //animation.repeatCount = 5
            //animation.autoreverses = true
            animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
            layer.addAnimation(animation, forKey: animationKey)
        }
    }
}