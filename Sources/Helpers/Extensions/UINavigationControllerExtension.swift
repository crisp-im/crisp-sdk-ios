//
//  UINavigationControllerExtension.swift
//  Crisp
//
//  Created by Quentin de Quelen on 15/01/2017.
//  Copyright © 2017 qdequele. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
	func getNavigationController() -> UINavigationController? {
		if let navigationController = UIApplication.shared.keyWindow?.rootViewController {
			return navigationController as? UINavigationController
		}
		return nil
	}

	func getCurrentViewController() -> UIViewController? {
		if let navigationController = getNavigationController() {
			return navigationController.visibleViewController
		}

		if let rootController = UIApplication.shared.keyWindow?.rootViewController {
			var currentController: UIViewController! = rootController
			while( currentController.presentedViewController != nil ) {
				currentController = currentController.presentedViewController
			}
			return currentController
		}
		return nil
	}
}
