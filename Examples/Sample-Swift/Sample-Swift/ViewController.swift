//
//  ViewController.swift
//  Sample-Swift
//
//  Created by Marc Bauer on 19.02.20.
//  Copyright © 2020 Crisp IM SARL. All rights reserved.
//

import UIKit
import Crisp

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func presentChat(_ sender: Any) {
    self.present(ChatViewController(), animated: true)
  }
}
