//
//  ViewControllerAnimatedTransitioning.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 25/11/2022.
//

import Anchorage
import UIKit

final class ViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPush: Bool
    
    let translationDuration: CGFloat = 0.5
    
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
        
        /// Set all the views in place and have been processed thru Autolayout
        parentVC?.view.layoutIfNeeded()
        childVC?.view.layoutIfNeeded()
        
        // MARK: - Transition from Years to Months (after selecting a month in the first viewController)
        if let fromViewController = fromViewController as? YearsViewController, let toViewController = toViewController as? MonthsViewController {
            guard let selectingIndexPath = fromViewController.collectionView.indexPathsForSelectedItems?.first else { return }
            guard let selectingCell = fromViewController.collectionView.cellForItem(at: selectingIndexPath) else { return }
            
            /// Selected month from Years fade big out
            let scaleOutFactor = {
                let currentWidth = selectingCell.bounds.width
                return Screen.width / currentWidth
            }()
            
            let originX = selectingCell.frame.minX
            let originY = selectingCell.frame.minY - fromViewController.collectionView.contentOffset.y
            
            let translationXFactor = {
                let translationAfterScaled = (selectingCell.bounds.width / 2) * (scaleOutFactor - 1)
                let xAfterScaled = originX - translationAfterScaled
                return xAfterScaled
            }()
            
            let translationYFactor = {
                let y = selectingCell.frame.minY
                let translationAfterScaled = (selectingCell.bounds.height / 2) * (scaleOutFactor - 1)
                let yAfterScaled = y - translationAfterScaled - fromViewController.collectionView.contentOffset.y
                return yAfterScaled
            }()
            
            UIView.animate(withDuration: translationDuration, animations: {
                for cell in fromViewController.collectionView.subviews.filter({ $0 !== selectingCell }) {
                    let xDistance = cell.frame.minX - selectingCell.frame.minX
                    let yDistance = cell.frame.minY - selectingCell.frame.minY
                    
                    let xTranslation = xDistance * (scaleOutFactor + 1)
                    let yTranslation = yDistance * (scaleOutFactor + 1)
                    
                    cell.transform = CGAffineTransform(translationX: xTranslation, y: yTranslation).scaledBy(x: scaleOutFactor, y: scaleOutFactor)
                }
                
                selectingCell.transform = CGAffineTransform(translationX: -translationXFactor, y: -translationYFactor).scaledBy(x: scaleOutFactor, y: scaleOutFactor)
            })
            
            UIView.animate(withDuration: translationDuration * 0.6, animations: {
                fromViewController.collectionView.subviews.forEach { $0.alpha = 0 }
            }, completion: { [self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + translationDuration / 2) {
                    fromViewController.collectionView.subviews.forEach { $0.alpha = 1 }
                }
            })
            
            // Set tableView offset in selected month
            let indexPathToAnimateIn = IndexPath(row: selectingIndexPath.section * 12 + selectingIndexPath.item, section: 0)
            toViewController.tableView.scrollToRow(at: indexPathToAnimateIn, at: .top, animated: false)
            
            /// Month to show fade big in
            /// Dummy
            let scaleInFactor = 1 / scaleOutFactor
            
            let dummyView = MonthItemDummyView(month: DataSource.shared.monthItems[indexPathToAnimateIn.row])
            fromViewController.view.addSubview(dummyView)
            dummyView.edgeAnchors == fromViewController.view.safeAreaLayoutGuide.edgeAnchors
            
            let translationDummyXFactor = {
                let widthAfterScaled = Screen.width * scaleInFactor
                let xAfterScaled = (Screen.width - widthAfterScaled) / 2
                return originX - xAfterScaled
            }()

            let translationDummyYFactor = {
                let heightAfterScaled = Screen.height * scaleInFactor
                let yAfterScaled = (Screen.height - heightAfterScaled) / 2
                return originY - yAfterScaled + DataSource.bigSectionHeaderHeight
            }()
            
            dummyView.transform = CGAffineTransform(translationX: translationDummyXFactor, y: translationDummyYFactor).scaledBy(x: scaleInFactor, y: scaleInFactor)
            dummyView.layoutIfNeeded()
            dummyView.alpha = 0
            
            UIView.animate(withDuration: translationDuration, delay: 0, animations: {
                dummyView.transform = .identity
                dummyView.alpha = 1
            }) { _ in
                dummyView.removeFromSuperview()
            }
            
        }
        
        // MARK: - Transition from Months to Years (Months backward)
        if let fromViewController = fromViewController as? MonthsViewController, let toViewController = toViewController as? YearsViewController {
//            guard let selectedCell = toViewController.collectionView.visibleCells.first(where: { !$0.transform.isIdentity }) else { return }
            toViewController.title = ""
            UIView.animate(withDuration: translationDuration) {
                fromViewController.tableView.visibleCells.forEach { $0.transform = .identity }
                toViewController.collectionView.subviews.forEach { $0.transform = .identity }
                toViewController.collectionView.alpha = 1
            }
        }
        
        
        container.backgroundColor = toView.backgroundColor
        toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(0)
        toView.alpha = 0
        
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(0)
        
        
        UIView.animate(withDuration: translationDuration, delay: 0, animations: {
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
        TimeInterval(translationDuration)
    }
    
}
