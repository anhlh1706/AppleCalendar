//
//  MonthViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias MonthsDataSource = UICollectionViewDiffableDataSource<MonthSection, Day>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<MonthSection, Day>

private let monthSections: [MonthSection] = {
    let startYear = Calendar.current.component(.year, from: startTime)
    let endYear = 1971// Calendar.current.component(.year, from: endTime)
    
    return Array(startYear...endYear).flatMap({ year in
        Array(1...12).map({ MonthSection(month: $0, year: year) })
    })
}()

final class MonthsViewController: UIViewController {
    
    private(set) var collectionView: UICollectionView!
    
    private var ds: MonthsDataSource!
    
    private let itemsPerLine: CGFloat = 7
    
    var currentYear: Int = 1970 {
        didSet {
            navigationController?.viewControllers.first?.title = String(currentYear)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        createDataSource()
        updateContent()
    }
}

extension MonthsViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        collectionView.delegate = self
        
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
        
        for section in monthSections where !section.days.isEmpty {
            snapshot.appendSections([section])
            snapshot.appendItems(section.days.map { Day(day: $0) }, toSection: section)
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
            return self.createSection(using: monthSections[sectionIndex])
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

extension MonthsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let startYear = Calendar.current.component(.year, from: startTime)
        
        let displayingYear = startYear + (indexPath.section / 12)
        if displayingYear != currentYear {
            currentYear = displayingYear
        }
    }
}
