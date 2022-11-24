//
//  LabelTableViewCell.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 24/11/2022.
//

import UIKit
import Anchorage

final class LabelTableViewCell: UITableViewCell {
    
    private(set) var titleLabel: UILabel!
    
    private var topSpacingConstraint: NSLayoutConstraint!
    private var bottomSpacingConstraint: NSLayoutConstraint!
    private var leadingSpacingConstraint: NSLayoutConstraint!
    private(set) var labelTrailingConstraint: NSLayoutConstraint!
    
    private(set) var topSeparator: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topSpacing = 12
        bottomSpacing = 12
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var leadingSpacing: CGFloat = 20 {
        didSet {
            leadingSpacingConstraint.constant = leadingSpacing
        }
    }
    
    var labelTrailingSpacing: CGFloat = 20 {
        didSet {
            labelTrailingConstraint.constant = -labelTrailingSpacing
        }
    }
    
    var verticalSpacing: CGFloat = 12 {
        didSet {
            topSpacing = verticalSpacing
            bottomSpacing = verticalSpacing
        }
    }
    
    var topSpacing: CGFloat = 12 {
        didSet {
            topSpacingConstraint.constant = topSpacing
        }
    }
    
    var bottomSpacing: CGFloat = 12 {
        didSet {
            bottomSpacingConstraint.constant = -bottomSpacing
        }
    }
    
    var showTopSeparator = true {
        didSet { topSeparator.isHidden = !showTopSeparator }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        leadingSpacingConstraint = titleLabel.leadingAnchor == contentView.leadingAnchor + 20
        topSpacingConstraint = titleLabel.topAnchor == contentView.topAnchor + 12
        bottomSpacingConstraint = titleLabel.bottomAnchor == contentView.bottomAnchor - 12
        labelTrailingConstraint = titleLabel.trailingAnchor == contentView.trailingAnchor - 20
        
        topSeparator = UIView()
        contentView.addSubview(topSeparator)
        topSeparator.topAnchor == contentView.topAnchor
        topSeparator.horizontalAnchors == contentView.horizontalAnchors
        topSeparator.heightAnchor == 0.5
        
        topSeparator.backgroundColor = .separator
        
        titleLabel.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
