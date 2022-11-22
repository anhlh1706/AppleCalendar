//
//  MonthViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit
import Anchorage

final class MonthsViewController: UIViewController {
    
    private(set) var collectionView: MonthsCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        collectionView = MonthsCollectionView()
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
    }
}
