//
//  CalendarViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

struct YearSection: Hashable {
    var year: Int
    var months: [MonthSection]
}

struct MonthSection: Hashable {
    let id = UUID()
    var dayCount: Int
    var startWeekday: Int
    
    init(month: Int, year: Int) {
        dayCount = 30
        startWeekday = 1
    }
}

fileprivate typealias CalendarDataSource = UICollectionViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias CalendarSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

final class CalendarViewController: UIViewController {
    
    private let startTime = Date(timeIntervalSince1970: 0)
    
    private var endTime: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: "31/12/2050")!
    }()
    
    var collectionView: UICollectionView!
    
    private var dataSource: CalendarDataSource!
    
    private let itemsPerLine: CGFloat = 3
    
    private lazy var sections: [YearSection] = {
        let startYear = Calendar.current.component(.year, from: startTime)
        let endYear = Calendar.current.component(.year, from: endTime)
        
        return Array(startYear...endYear).map({ year in
            YearSection(year: year, months: Array(1...12).map({ MonthSection(month: $0, year: year) }))
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        createDataSource()
        updateContent()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        
        collectionView.register(LabelCollectionCell.self, forCellWithReuseIdentifier: "LabelCollectionCell")
        collectionView.register(CalendarHeaderCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "CalendarHeaderCollectionView")
    }
    
    func createDataSource() {
        dataSource = CalendarDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCollectionCell", for: indexPath) as! LabelCollectionCell
            cell.titleLabel.text = String(item.dayCount)
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let firstItem = self?.dataSource?.itemIdentifier(for: indexPath)!
            let category = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstItem!)!
            
            let categoryHeader = (collectionView ).dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarHeaderCollectionView", for: indexPath) as! CalendarHeaderCollectionView
            
            categoryHeader.title = String(category?.year ?? 0)
            return categoryHeader
        }
    }
    
    func updateContent() {
        var snapshot = CalendarSnapshot()
        
        for section in sections where !section.months.isEmpty {
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
            return self.createSection(using: self.sections[sectionIndex])
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
    func createSection(using item: YearSection) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = 94
        let sectionHeight = (CGFloat(item.months.count) / itemsPerLine).rounded(.up) * itemHeight
        
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

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
