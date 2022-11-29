//
//  MonthItemDummyView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 25/11/2022.
//

import UIKit
import Anchorage

fileprivate typealias MonthsDataSource = UITableViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

/// Dummy view to show scale in animation after selecting a month from year
/// Showing a month with exactly same position with month screen after scaled 
final class MonthItemDummyView: UIView, UITableViewDelegate {
    
    private(set) var tableView: UITableView!
    
    let month: MonthSection
    
    private var ds: MonthsDataSource!
    
    init(month: MonthSection) {
        self.month = month
        super.init(frame: .zero)
        backgroundColor = .clear
        setupTableView()
        createDataSource()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableView() {
        tableView = UITableView()
        addSubview(tableView)
        tableView.edgeAnchors == edgeAnchors
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
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
        
        let section = YearSection(year: 0, months: [month])
        snapshot.appendSections([section])
        snapshot.appendItems(section.months, toSection: section)
        
        if !snapshot.itemIdentifiers.isEmpty {
            ds?.apply(snapshot)
        } else {
            ds?.apply(MonthsSnapshot())
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        bounds.height
    }
}
