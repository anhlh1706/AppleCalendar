//
//  LabelCollectionCell.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

final class LabelCollectionCell: UICollectionViewCell {
    
    private(set) var titleLabel: UILabel!
    private(set) var topSeparator: UIView!
    
    var showTopSeparator = false {
        didSet { topSeparator.isHidden = !showTopSeparator }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.centerAnchors == contentView.centerAnchors
        
        topSeparator = UIView()
        contentView.addSubview(topSeparator)
        topSeparator.topAnchor == contentView.topAnchor
        topSeparator.horizontalAnchors == contentView.horizontalAnchors
        topSeparator.heightAnchor == 0.5
        
        titleLabel.textAlignment = .center
        topSeparator.backgroundColor = .separator
        topSeparator.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
