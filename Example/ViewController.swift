//
//  ViewController.swift
//  Example
//
//  Created by Quentin de Quelen on 20/07/2017.
//  Copyright © 2017 crisp.im. All rights reserved.
//

import UIKit
import Crisp

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let crispButton = CrispButton()
        view.addSubview(crispButton)
        crispButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        crispButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

