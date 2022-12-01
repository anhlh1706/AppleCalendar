//
//  YearItemDummyView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 01/12/2022.
//

import UIKit
import Anchorage

fileprivate typealias YearDataSource = UICollectionViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias YearSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

/// Dummy view to show scale in animation when back from month to year
/// Showing a year with exactly same position with year screen after scaled out
final class YearItemDummyView: UIView, UITableViewDelegate {
    
    private(set) var collectionView: UICollectionView!
    
    let years: [YearSection]
    
    private let itemsPerLine: CGFloat = 3
    
    private var dataSource: YearDataSource!
    
    init(years: [YearSection]) {
        self.years = years
        super.init(frame: .zero)
        backgroundColor = .white
        setupCollectionView()
        createDataSource()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: createCompositionalLayout())
        addSubview(collectionView)
        collectionView.edgeAnchors == edgeAnchors
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MonthItemCollectionCell.self, forCellWithReuseIdentifier: "MonthItemCollectionCell")
        collectionView.register(YearHeaderCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "YearHeaderCollectionView")
    }
    
    func createDataSource() {
        dataSource = YearDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthItemCollectionCell", for: indexPath) as! MonthItemCollectionCell
            cell.section = item
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let firstItem = self?.dataSource?.itemIdentifier(for: indexPath)!
            let category = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstItem!)!
            
            let categoryHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "YearHeaderCollectionView", for: indexPath) as! YearHeaderCollectionView
            
            categoryHeader.title = String(category?.year ?? 0)
            return categoryHeader
        }
    }
    
    func updateContent() {
        var snapshot = YearSnapshot()
        
        for section in years where !section.months.isEmpty {
            snapshot.appendSections([section])
            snapshot.appendItems(section.months.map { $0 }, toSection: section)
        }
        
        if !snapshot.itemIdentifiers.isEmpty {
            dataSource?.apply(snapshot)
        } else {
            dataSource.apply(YearSnapshot())
        }
    }
    
    /// Configure flow layout
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(using: DataSource.yearSections[sectionIndex])
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration = config
        return layout
    }
    
    /// Configure section header layout.
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                             heightDimension: .estimated(DataSource.bigSectionHeaderHeight))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return layoutSectionHeader
    }
    
    /// Configure section layout
    func createSection(using item: YearSection) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = 145
        let sectionHeight = (CGFloat(item.months.count) / itemsPerLine).rounded(.up) * itemHeight
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemsPerLine), heightDimension: .absolute(itemHeight))
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(sectionHeight))

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)

        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
}
