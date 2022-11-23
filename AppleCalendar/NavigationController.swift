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

final class ViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPush: Bool
    
    let transactionDuration: CGFloat = 0.4
    
    init(isPush: Bool) {
        self.isPush = isPush
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        isPush ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let parentVC = isPush ? fromViewController : toViewController
        
        let childVC = isPush ? toViewController : fromViewController
        
        // MARK: Set all the views in place and have been processed thru Autolayout
        parentVC?.view.layoutIfNeeded()
        childVC?.view.layoutIfNeeded()
        
        // MARK: - Transition from Years to Months (after selecting a month in the first ViewController)
        if let fromViewController = fromViewController as? YearsViewController, let toViewController = toViewController as? MonthsViewController {
            guard let selectingIndexPath = fromViewController.collectionView.indexPathsForSelectedItems?.first else { return }
            guard let selectingCell = fromViewController.collectionView.cellForItem(at: selectingIndexPath) else { return }
            
            // FromMonth fade big out
            let scaleOutFactor = {
                let currentWidth = selectingCell.bounds.width
                return Screen.width / currentWidth
            }()
            
            let translationXFactor = {
                let x = selectingCell.frame.minX
                let translationAfterScaled = (selectingCell.bounds.width / 2) * (scaleOutFactor - 1)
                let xAfterScaled = x - translationAfterScaled
                return xAfterScaled
            }()
            
            let translationYFactor = {
                let y = selectingCell.frame.minY
                let translationAfterScaled = (selectingCell.bounds.height / 2) * (scaleOutFactor - 1)
                let yAfterScaled = y - translationAfterScaled - fromViewController.collectionView.contentOffset.y
                return yAfterScaled
            }()
            
            UIView.animate(withDuration: transactionDuration) {
                for cell in fromViewController.collectionView.subviews.filter({ $0 !== selectingCell }) {
                    let xDistance = cell.frame.minX - selectingCell.frame.minX
                    let yDistance = cell.frame.minY - selectingCell.frame.minY
                    
                    let xTranslation = xDistance * (scaleOutFactor + 1)
                    let yTranslation = yDistance * (scaleOutFactor + 1)
                    
                    cell.transform = CGAffineTransform(translationX: xTranslation, y: yTranslation).scaledBy(x: scaleOutFactor, y: scaleOutFactor)
                }
                
                selectingCell.transform = CGAffineTransform(translationX: -translationXFactor, y: -translationYFactor).scaledBy(x: scaleOutFactor, y: scaleOutFactor)
                fromViewController.view.alpha = 0
            }
            
            // Set collectionView offset in selected month
            if let attributes = toViewController.collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: selectingIndexPath.section * 12 + selectingIndexPath.item)) {
                let offsetY = attributes.frame.origin.y - toViewController.collectionView.contentInset.top
                toViewController.collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            }
            
            // ToMonth fade big in
            let scaleInFactor = 1 / scaleOutFactor
            toViewController.collectionView.subviews.forEach {
                $0.transform = CGAffineTransform(scaleX: scaleInFactor, y: scaleInFactor)
            }
            
//            let indexPath = IndexPath(item: 0, section: selectingIndexPath.section * 12 + selectingIndexPath.item)
//            DispatchQueue.main.async {
//                toViewController.collectionView.scroll
//                toViewController.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
//            }
//            let translationXFactor = {
//                let x = selectingCell.frame.minX
//                let translationAfterScaled = (selectingCell.bounds.width / 2) * (scaleFactorIn - 1)
//                let xAfterScaled = x - translationAfterScaled
//                return xAfterScaled
//            }()
//
//            let translationYFactor = {
//                let y = selectingCell.frame.minY
//                let translationAfterScaled = (selectingCell.bounds.height / 2) * (scaleFactorIn - 1)
//                let yAfterScaled = y - translationAfterScaled - fromViewController.collectionView.contentOffset.y
//                return yAfterScaled
//            }()
            
//            UIView.animate(withDuration: transactionDuration) {
//                for cell in fromViewController.collectionView.visibleCells.filter({ $0 !== selectingCell }) {
//                    let xDistance = cell.frame.minX - selectingCell.frame.minX
//                    let yDistance = cell.frame.minY - selectingCell.frame.minY
//
//                    let xTranslation = xDistance * (scaleFactor + 1)
//                    let yTranslation = yDistance * (scaleFactor + 1)
//
//                    cell.transform = CGAffineTransform(translationX: xTranslation, y: yTranslation).scaledBy(x: scaleFactor, y: scaleFactor)
//                }
//
//                selectingCell.transform = CGAffineTransform(translationX: -translationXFactor, y: -translationYFactor).scaledBy(x: scaleFactor, y: scaleFactor)
//                fromViewController.collectionView.alpha = 0.3
//            }
        }
        
        // MARK: - Transition from Months to Years (Months backward)
        if let fromViewController = fromViewController as? MonthsViewController, let toViewController = toViewController as? YearsViewController {
            guard let selectedCell = toViewController.collectionView.visibleCells.first(where: { !$0.transform.isIdentity }) else { return }
            toViewController.title = ""
            UIView.animate(withDuration: transactionDuration) {
                toViewController.collectionView.subviews.forEach { $0.transform = .identity }
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
            toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(1)
            toView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.6
    }
    
}
