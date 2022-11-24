//
//  MonthTableViewCell.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 24/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias MonthsDataSource = UICollectionViewDiffableDataSource<MonthSection, Day>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<MonthSection, Day>

final class MonthTableViewCell: UITableViewCell {
    
    private(set) var collectionView: SizingCollectionView!
    
    var month: MonthSection! {
        didSet {
            updateContent()
        }
    }
    private var ds: MonthsDataSource!
    
    private let itemsPerLine: CGFloat = 7
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
        createDataSource()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        collectionView = SizingCollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        contentView.addSubview(collectionView)
        collectionView.edgeAnchors == contentView.edgeAnchors
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(LabelCollectionCell.self, forCellWithReuseIdentifier: "LabelCollectionCell")
        collectionView.register(YearHeaderCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "YearHeaderCollectionView")
    }
    
    func createDataSource() {
        ds = MonthsDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCollectionCell", for: indexPath) as! LabelCollectionCell
            
            let day = (Int(item.day) ?? 0) == 0 ? "" : item.day
            cell.titleLabel.text = day
            cell.showTopSeparator = !day.isEmpty
            return cell
        }
        
        ds?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let firstItem = self?.ds?.itemIdentifier(for: indexPath)!
            let category = self?.ds?.snapshot().sectionIdentifier(containingItem: firstItem!)!
            
            let categoryHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YearHeaderCollectionView", for: indexPath) as! YearHeaderCollectionView
            
            categoryHeader.title = category?.monthText
            categoryHeader.showBottomSeparator = false
            return categoryHeader
        }
    }
    
    func updateContent() {
        var snapshot = MonthsSnapshot()
        
        if let month = month {
            snapshot.appendSections([month])
            snapshot.appendItems(month.days.map({ Day(day: $0) }), toSection: month)
        }
        
        if !snapshot.itemIdentifiers.isEmpty {
            ds?.apply(snapshot)
        } else {
            ds?.apply(MonthsSnapshot())
        }
    }
    
    /// Configure flow layout
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(using: DataSource.shared.monthItems[sectionIndex])
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
        let itemHeight: CGFloat = 60
        let sectionHeight = (CGFloat(item.days.count) / itemsPerLine).rounded(.up) * itemHeight
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemsPerLine), heightDimension: .absolute(itemHeight))
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(sectionHeight))

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18)
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)

        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
}