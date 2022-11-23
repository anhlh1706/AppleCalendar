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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchAction))
    }
    
    @objc
    func searchAction() {
        
    }
}

extension NavigationController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ViewControllerAnimatedTransitioning(isPresenting: operation == .push)
    }
}

final class ViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool
    
    let transactionDuration: CGFloat = 0.4
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let parentVC = isPresenting ? fromViewController : toViewController
        
        let childVC = isPresenting ? toViewController : fromViewController
        
        // MARK: Set all the views in place and have been processed thru Autolayout
        parentVC?.view.layoutIfNeeded()
        childVC?.view.layoutIfNeeded()
        
        // MARK: - Transition from Years to Months (after selecting a month in the first ViewController)
        if let fromViewController = fromViewController as? YearsViewController, let toViewController = toViewController as? MonthsViewController {
            guard let selectingIndexPath = fromViewController.collectionView.indexPathsForSelectedItems?.first else { return }
            guard let selectingCell = fromViewController.collectionView.cellForItem(at: selectingIndexPath) else { return }
            
            let fullScreenWidth = fromViewController.view.bounds.width
            let currentWidth = selectingCell.bounds.width
            let scaleFactor = fullScreenWidth / currentWidth
            
            UIView.animate(withDuration: transactionDuration) {
                selectingCell.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                fromViewController.collectionView.alpha = 0
            }
            
        }
        
        // MARK: - Transition from Months to Years (Months backward)
        if let fromViewController = fromViewController as? MonthsViewController, let toViewController = toViewController as? YearsViewController {
            guard let selectedCell = toViewController.collectionView.visibleCells.first(where: { !$0.transform.isIdentity }) else { return }
            UIView.animate(withDuration: transactionDuration) {
                selectedCell.transform = CGAffineTransform(scaleX: 1, y: 1)
                toViewController.collectionView.alpha = 1
            }
            
        }
        
        
        
        
        container.backgroundColor = toView.backgroundColor
        toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(0)
        toView.alpha = 0
        
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(0)
        
        
        
        
        UIView.animate(withDuration: transactionDuration, delay: 0, animations: {
            toView.alpha = 0.001
            toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(0.0001)
        }, completion: { _ in
            fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(1)
//            toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(1)
            toView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.6
    }
    
}
