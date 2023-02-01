import Crisp
import UIKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let openButton = UIButton()
    openButton.setImage(UIImage(named: "crisp"), for: .normal)
    openButton.tintColor = .white
    openButton.backgroundColor = self.view.tintColor
    openButton.translatesAutoresizingMaskIntoConstraints = false
    openButton.layer.cornerRadius = 30
    self.view.addSubview(openButton)

    openButton.addTarget(self, action: #selector(self.showChat), for: .touchUpInside)

    NSLayoutConstraint.activate([
      openButton.widthAnchor.constraint(equalToConstant: 60),
      openButton.heightAnchor.constraint(equalToConstant: 60),
      openButton.trailingAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
        constant: -20
      ),
      openButton.bottomAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
        constant: -20
      ),
    ])
  }

  @objc func showChat() {
    self.present(ChatViewController(), animated: true)
  }
}
