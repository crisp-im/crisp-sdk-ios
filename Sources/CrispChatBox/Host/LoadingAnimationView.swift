import UIKit

package final class LoadingAnimationView: UIView {
  private static let dotSize = CGFloat(12)
  private static let dotSpacing = CGFloat(6)
  private static let dotAnimationOffset = CGFloat(12)
  private static let dotAnimationDuration = TimeInterval(1.2)
  private static let dotDelay = TimeInterval(0.25)
  private static let numberOfDots = 3

  private let dots: [UIView]
  private var isAnimating = false

  override package init(frame: CGRect) {
    self.dots = (0 ..< Self.numberOfDots).map { _ in
      let dot = UIView()
      dot.layer.cornerRadius = Self.dotSize / 2
      dot.backgroundColor = .label
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

    let delay = Self.dotDelay * TimeInterval(self.dots.count)
    let curve = CAMediaTimingFunction(name: .easeInEaseOut)
    let startYPosition = Self.dotAnimationOffset + Self.dotSize / 2
    let endYPosition = Self.dotSize / 2

    for (idx, dot) in self.dots.enumerated() {
      let animation = CAKeyframeAnimation()
      animation.keyPath = "position.y"
      animation.values = [startYPosition, endYPosition, startYPosition]
      animation.keyTimes = [0.5, 0.75, 1]
      animation.duration = Self.dotAnimationDuration
      animation.repeatCount = Float.greatestFiniteMagnitude
      animation.beginTime = CACurrentMediaTime() + delay - Self.dotDelay * TimeInterval(idx + 1)
      animation.timingFunctions = [curve, curve, curve]
      dot.layer.add(animation, forKey: "bounce")
    }
  }

  package func stopAnimating() {
    guard self.isAnimating else {
      return
    }
    self.isAnimating = false
    self.dots.forEach { $0.layer.removeAnimation(forKey: "bounce") }
  }

  override package func layoutSubviews() {
    super.layoutSubviews()
    let firstFrame = CGRect(
      x: 0,
      y: Self.dotAnimationOffset,
      width: Self.dotSize,
      height: Self.dotSize,
    )
    _ = self.dots.reduce(firstFrame) { frame, dot in
      dot.frame = frame
      return frame.offsetBy(dx: frame.width + Self.dotSpacing, dy: 0)
    }
  }

  override package func sizeThatFits(_: CGSize) -> CGSize {
    CGSize(
      width: CGFloat(self.dots.count) * Self.dotSize +
        CGFloat(self.dots.count - 1) * Self.dotSpacing,
      height: Self.dotSize + Self.dotAnimationOffset,
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
