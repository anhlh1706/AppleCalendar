//
//  CalendarHeaderCollectionView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

final class CalendarHeaderCollectionView: UICollectionReusableView {
    
    private(set) var label: UILabel!
    
    var title: String = "" {
        didSet {
            label.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel()
        addSubview(label)
        label.verticalAnchors == verticalAnchors + 5
        label.leadingAnchor == leadingAnchor
        
        label.font = .systemFont(ofSize: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
