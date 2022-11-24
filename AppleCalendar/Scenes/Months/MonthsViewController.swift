//
//  MonthViewController.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import UIKit
import Anchorage
import Combine

fileprivate typealias MonthsDataSource = UITableViewDiffableDataSource<YearSection, MonthSection>
fileprivate typealias MonthsSnapshot = NSDiffableDataSourceSnapshot<YearSection, MonthSection>

final class MonthsViewController: UIViewController {
    
    private var cancellables = [AnyCancellable]()
    
    private(set) var tableView: UITableView!
    
    private var ds: MonthsDataSource!
    
    private var observation: NSKeyValueObservation!
    
    var currentYear: Int = 1970 {
        didSet {
            navigationController?.viewControllers.first?.title = String(currentYear)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        createDataSource()
        updateContent()
    }
}

extension MonthsViewController {
    
    func setupTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MonthTableViewCell.self, forCellReuseIdentifier: "MonthTableViewCell")
        tableView.register(LabelTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "LabelTableHeaderView")
        
//        tableView.publisher(for: \.contentSize).throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: false).sink { [weak tableView] _ in
//            tableView?.layoutIfNeeded()
//        }.store(in: &cancellables)
        
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
