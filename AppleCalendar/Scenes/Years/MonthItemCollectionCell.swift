//
//  MonthItemCollectionCell.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias MonthsDataSource = UICollectionViewDiffableDataSource<MonthSection, Day>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<MonthSection, Day>

final class MonthItemCollectionCell: UICollectionViewCell {
    
    private(set) var collectionView: UICollectionView!
    
    let itemsPerLine: CGFloat = 7
    
    var section: MonthSection! {
        didSet {
            updateContent()
        }
    }
    
    private var dataSource: MonthsDataSource!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        createDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: createCompositionalLayout())
        contentView.addSubview(collectionView)
        collectionView.edgeAnchors == contentView.edgeAnchors
        
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(LabelCollectionCell.self, forCellWithReuseIdentifier: "LabelCollectionCell")
        collectionView.register(YearHeaderCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "YearHeaderCollectionView")
        
    }
    
    func createDataSource() {
        dataSource = MonthsDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCollectionCell", for: indexPath) as! LabelCollectionCell
            
            let day = (Int(item.day) ?? 0) == 0 ? "" : item.day
            cell.titleLabel.text = day
            cell.showTopSeparator = false
            cell.titleLabel.font = .systemFont(ofSize: 8, weight: .semibold)
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let firstItem = self?.dataSource?.itemIdentifier(for: indexPath)!
            let category = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstItem!)!
            
            let categoryHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YearHeaderCollectionView", for: indexPath) as! YearHeaderCollectionView
            categoryHeader.showBottomSeparator = false
            categoryHeader.title = category?.monthText
            categoryHeader.label.font = .systemFont(ofSize: 16, weight: .semibold)
            return categoryHeader
        }
    }
    
    func updateContent() {
        var snapshot = MonthsSnapshot()
        
        snapshot.appendSections([section])
        snapshot.appendItems(section.days.map { Day(day: $0) }, toSection: section)
        
        if !snapshot.itemIdentifiers.isEmpty {
            dataSource?.apply(snapshot)
        } else {
            dataSource.apply(MonthsSnapshot())
        }
    }
    
    /// Configure flow layout
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(using: self.section)
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration = config
        return layout
    }
    
    /// Configure section header layout.
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(80))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return layoutSectionHeader
    }
    
    /// Configure section layout
    func createSection(using item: MonthSection) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = 14
        let sectionHeight = (CGFloat(item.days.count) / itemsPerLine).rounded(.up) * itemHeight
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemsPerLine), heightDimension: .absolute(itemHeight))
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(sectionHeight))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 18, trailing: 5)
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
}
