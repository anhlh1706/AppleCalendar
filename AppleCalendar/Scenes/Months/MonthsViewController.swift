//
//  MonthViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias MonthsDataSource = UITableViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

final class MonthsViewController: UIViewController {
    
    private(set) var tableView: UITableView!
    
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
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MonthTableViewCell.self, forCellReuseIdentifier: "MonthTableViewCell")
        tableView.register(LabelTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "LabelTableHeaderView")
    }
    
    func createDataSource() {
        ds = MonthsDataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MonthTableViewCell", for: indexPath) as! MonthTableViewCell
            cell.month = item
            return cell
        }
        
    }
    
    func updateContent() {
        var snapshot = MonthsSnapshot()
        
        let section = YearSection(year: 0, months: DataSource.shared.monthItems)
        snapshot.appendSections([section])
        snapshot.appendItems(section.months, toSection: section)
        
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
        let itemHeight: CGFloat = 200
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

extension MonthsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let startYear = Calendar.current.component(.year, from: DataSource.startTime)
        
        let displayingYear = startYear + (indexPath.row / 12)
        if displayingYear != currentYear {
            currentYear = displayingYear
        }
    }
}
