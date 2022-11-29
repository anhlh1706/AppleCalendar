//
//  NavigationController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit

final class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationItem.largeTitleDisplayMode = .never
        navigationBar.topItem?.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchAction)), animated: false)
    }
    
    @objc
    func searchAction() {
        
    }
}

extension NavigationController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ViewControllerAnimatedTransitioning(isPush: operation == .push)
    }
}
