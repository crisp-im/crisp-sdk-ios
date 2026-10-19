import UIKit

package final class LoadingAnimationView: UIView {
  private static let dotSize = CGFloat(10)
  private static let dotSpacing = CGFloat(8)
  private static let dotAnimationDuration = TimeInterval(0.6)
  private static let dotDelay = TimeInterval(0.2)
  private static let dotMinScale = CGFloat(0.6)
  private static let dotMinOpacity = Float(0.2)
  private static let numberOfDots = 3

  private let dots: [UIView]
  private var isAnimating = false

  override package init(frame: CGRect) {
    self.dots = (0 ..< Self.numberOfDots).map { _ in
      let dot = UIView()
      dot.bounds = CGRect(x: 0, y: 0, width: Self.dotSize, height: Self.dotSize)
      dot.layer.cornerRadius = Self.dotSize / 2
      dot.layer.opacity = Self.dotMinOpacity
      dot.backgroundColor = .secondaryLabel
      return dot
    }
    super.init(frame: frame)
    self.dots.forEach(self.addSubview)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  package func startAnimating() {
    guard !self.isAnimating else {
      return
    }

    self.isAnimating = true

    let curve = CAMediaTimingFunction(name: .easeInEaseOut)
    let shouldScale = !UIAccessibility.isReduceMotionEnabled

    for (idx, dot) in self.dots.enumerated() {
      var animations = [CABasicAnimation]()

      let opacity = CABasicAnimation(keyPath: "opacity")
      opacity.fromValue = Self.dotMinOpacity
      opacity.toValue = Float(1)
      animations.append(opacity)

      if shouldScale {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = Self.dotMinScale
        scale.toValue = CGFloat(1)
        animations.append(scale)
      }

      let group = CAAnimationGroup()
      group.animations = animations
      group.duration = Self.dotAnimationDuration
      group.autoreverses = true
      group.repeatCount = Float.greatestFiniteMagnitude
      group.timingFunction = curve
      group.fillMode = .backwards
      group.beginTime = CACurrentMediaTime() + Self.dotDelay * TimeInterval(idx)
      dot.layer.add(group, forKey: "pulse")
    }
  }

  package func stopAnimating() {
    guard self.isAnimating else {
      return
    }
    self.isAnimating = false
    self.dots.forEach { $0.layer.removeAnimation(forKey: "pulse") }
  }

  override package func layoutSubviews() {
    super.layoutSubviews()
    // Use `center` rather than `frame` so layout stays valid while the dots are scaled
    for (idx, dot) in self.dots.enumerated() {
      dot.center = CGPoint(
        x: Self.dotSize / 2 + CGFloat(idx) * (Self.dotSize + Self.dotSpacing),
        y: Self.dotSize / 2,
      )
    }
  }

  override package func sizeThatFits(_: CGSize) -> CGSize {
    CGSize(
      width: CGFloat(self.dots.count) * Self.dotSize +
        CGFloat(self.dots.count - 1) * Self.dotSpacing,
      height: Self.dotSize,
    )
  }

  override package var intrinsicContentSize: CGSize {
    self.sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity))
  }

  override package func didMoveToWindow() {
    super.didMoveToWindow()

    switch window {
    case .none where self.isAnimating:
      self.stopAnimating()
      self.isAnimating = true

    case .some where self.isAnimating:
      self.isAnimating = false
      self.startAnimating()

    default: break
    }
  }
}
