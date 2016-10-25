//
//  ViewControllerExtension.swift
//  teferi
//
//  Created by Olga Nesterenko on 10/25/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import UIKit

extension UIViewController {
    func installViewController(childViewController: UIViewController, inside view: UIView) -> Void {
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
}
