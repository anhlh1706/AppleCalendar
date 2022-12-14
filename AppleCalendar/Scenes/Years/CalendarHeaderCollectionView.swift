//
//  YearHeaderCollectionView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

final class YearHeaderCollectionView: UICollectionReusableView {
    
    private(set) var label: UILabel!
    private var bottomSeparator: UIView!
    
    private(set) var leadingConstraint: NSLayoutConstraint!
    
    let padding: CGFloat = 3
    
    var titleLeading: CGFloat = 0 {
        didSet {
            leadingConstraint?.constant = titleLeading + padding
        }
    }
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    var showBottomSeparator = true {
        didSet { bottomSeparator.isHidden = !showBottomSeparator }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel()
        addSubview(label)
        label.verticalAnchors == verticalAnchors + 5
        leadingConstraint = label.leadingAnchor == leadingAnchor + 3
        
        bottomSeparator = UIView()
        addSubview(bottomSeparator)
        bottomSeparator.bottomAnchor == bottomAnchor
        bottomSeparator.horizontalAnchors == horizontalAnchors + 5
        bottomSeparator.heightAnchor == 0.5
        
        label.font = .systemFont(ofSize: 36, weight: .bold)
        bottomSeparator.backgroundColor = .separator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
