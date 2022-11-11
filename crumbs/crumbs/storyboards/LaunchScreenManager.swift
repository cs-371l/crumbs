import UIKit

class LaunchScreenManager {

    // MARK: - Properties

    static let instance = LaunchScreenManager(animationDurationBase: 3.0)

    var view: UIView?
    var parentView: UIView?

    let animationDurationBase: Double

    let logoViewTag = 100

    // MARK: - Lifecycle

    init(animationDurationBase: Double) {
        self.animationDurationBase = animationDurationBase
    }

    // MARK: - Animate

    func animateAfterLaunch(_ parentViewPassedIn: UIView) {
        parentView = parentViewPassedIn
        view = loadView()

        fillParentViewWithView()

        hideLogo()
        hideRingSegments()
    }

    func loadView() -> UIView {
        return UINib(nibName: "LaunchScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    func fillParentViewWithView() {
        parentView!.addSubview(view!)

        view!.frame = parentView!.bounds
        view!.center = parentView!.center
    }

    func hideLogo() {
        let logo = view!.viewWithTag(logoViewTag)!

        UIView.animate(
            withDuration: animationDurationBase / 4,
            delay: animationDurationBase / 2,
            options: .curveEaseIn,
            animations: {
                logo.alpha = 0
                logo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        )
    }

    func hideRingSegments() {
        let distanceToMove = parentView!.frame.size.height * 1.75

        for number in 1...12 {
            let ringSegment = view!.viewWithTag(number)!

            let degrees = 360 - (number * 30) + 15

            let angle = CGFloat(degrees)

            let radians = angle * (CGFloat.pi / 180)

            let translationX = (cos(radians) * distanceToMove)
            let translationY = (sin(radians) * distanceToMove) * -1

            UIView.animate(
                withDuration: animationDurationBase * 1.75,
                delay: animationDurationBase / 1.5,
                options: .curveLinear,
                animations: {
                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: translationX, y: translationY)

                    transform = transform.rotated(by: -1.95)

                    ringSegment.transform = transform
                }
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDurationBase * 1.25) {
                self.view!.removeFromSuperview()
            }
        }
    }
}
