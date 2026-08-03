import UIKit

final class DownloadProgressViewController: UIViewController {
  let model: DownloadViewModel

  private var progressView: CrispView?

  init(model: DownloadViewModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.isHidden = true

    self.model.onStart = { [weak self] in
      self?.view.isHidden = false
    }

    self.model.onProgress = { [weak self] progress in
      guard let self else { return }

      self.progressView?.progress = progress

      if progress >= 0.995 {
        self.view.isHidden = true
      }
    }

    self.view.backgroundColor = .black.withAlphaComponent(0.2)

    let backgroundView = UIView()
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.layer.cornerCurve = .continuous
    backgroundView.layer.cornerRadius = 18
    backgroundView.backgroundColor = .systemBackground

    backgroundView.layer.shadowColor = UIColor.black.cgColor
    backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
    backgroundView.layer.shadowRadius = 10
    backgroundView.layer.shadowOpacity = 0.08
    backgroundView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    self.view.addSubview(backgroundView)

    let crispLogo = CrispView()
    crispLogo.translatesAutoresizingMaskIntoConstraints = false
    self.progressView = crispLogo

    let label = UILabel()
    label.font = UIFont.preferredFont(forTextStyle: .footnote)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.text = NSLocalizedString(
      "sdk.indicator_loading",
      bundle: .module,
      value: "Loading…",
      comment: "Shown while the chat is loading",
    )

    backgroundView.addSubview(crispLogo)

    NSLayoutConstraint.activate([
      backgroundView.widthAnchor.constraint(
        greaterThanOrEqualTo: self.view.widthAnchor,
        multiplier: 0.3,
      ),
      backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor),
      backgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      backgroundView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -80),

      crispLogo.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.8),
      crispLogo.heightAnchor.constraint(equalTo: crispLogo.widthAnchor),
      crispLogo.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
      crispLogo.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
    ])
  }
}

private final class CrispView: UIView {
  var progress: Double = 0 {
    didSet { self.setNeedsLayout() }
  }

  private let progressLayer = CALayer()
  private let shapeLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .quaternarySystemFill

    self.progressLayer.backgroundColor = UIColor.secondaryLabel.cgColor
    self.layer.addSublayer(self.progressLayer)

    self.layer.mask = self.shapeLayer
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.shapeLayer.frame = self.bounds
    self.shapeLayer.path = self.createPath().cgPath

    let progressLayerHeight = self.bounds.height * self.progress

    self.progressLayer.frame = CGRect(
      x: 0,
      y: self.bounds.height - progressLayerHeight,
      width: self.bounds.width,
      height: progressLayerHeight,
    )
  }

  private func createPath() -> UIBezierPath {
    let path = UIBezierPath()
    let scaleX = bounds.width / 35.0
    let scaleY = bounds.height / 35.0

    // Points with (3, 6) translation from parent group baked in
    let points: [CGPoint] = [
      CGPoint(x: 14.226 * scaleX, y: 24.46 * scaleY),
      CGPoint(x: 4.584 * scaleX, y: 25.566 * scaleY),
      CGPoint(x: 3.0 * scaleX, y: 9.106 * scaleY),
      CGPoint(x: 30.066 * scaleX, y: 6.0 * scaleY),
      CGPoint(x: 31.65 * scaleX, y: 22.46 * scaleY),
      CGPoint(x: 22.283 * scaleX, y: 23.534 * scaleY),
      CGPoint(x: 18.777 * scaleX, y: 29.249 * scaleY),
      CGPoint(x: 14.226 * scaleX, y: 24.459 * scaleY),
    ]

    path.move(to: points[0])
    for point in points.dropFirst() {
      path.addLine(to: point)
    }
    path.close()

    return path
  }
}
