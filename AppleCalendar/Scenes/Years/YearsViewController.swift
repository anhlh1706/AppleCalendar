//
//  YearsViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias CalendarDataSource = UICollectionViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias CalendarSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

final class YearsViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    private var dataSource: CalendarDataSource!
    
    let monthsViewController = MonthsViewController()
    
    private let itemsPerLine: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        createDataSource()
        updateContent()
        preloadMonths()
    }
    
    func preloadMonths() {
        monthsViewController.view.layoutIfNeeded()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MonthItemCollectionCell.self, forCellWithReuseIdentifier: "MonthItemCollectionCell")
        collectionView.register(YearHeaderCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "YearHeaderCollectionView")
    }
    
    func createDataSource() {
        dataSource = CalendarDataSource(collectionView: collectionView) { collectionView, indexPath, item in
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
        var snapshot = CalendarSnapshot()
        
        for section in DataSource.shared.yearSections where !section.months.isEmpty {
            snapshot.appendSections([section])
            snapshot.appendItems(section.months.map { $0 }, toSection: section)
        }
        
        if !snapshot.itemIdentifiers.isEmpty {
            dataSource?.apply(snapshot)
        } else {
            dataSource.apply(CalendarSnapshot())
        }
    }
    
    /// Configure flow layout
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.createSection(using: DataSource.shared.yearSections[sectionIndex])
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration = config
        return layout
    }
    
    /// Configure section header layout.
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(80))
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

extension YearsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(monthsViewController, animated: true)
        title = String(DataSource.shared.yearSections[indexPath.section].year)
    }
}
