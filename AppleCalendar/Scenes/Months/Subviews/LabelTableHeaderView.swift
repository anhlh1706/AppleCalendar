//
//  LabelTableHeaderView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 24/11/2022.
//

import UIKit
import Anchorage

final class LabelTableHeaderView: UITableViewHeaderFooterView {
    
    private(set) var label: UILabel!
    private var bottomSeparator: UIView!
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    var showBottomSeparator = true {
        didSet { bottomSeparator.isHidden = !showBottomSeparator }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label = UILabel()
        addSubview(label)
        label.verticalAnchors == verticalAnchors + 5
        label.leadingAnchor == leadingAnchor + 3
        
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
