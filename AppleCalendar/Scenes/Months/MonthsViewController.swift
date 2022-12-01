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
    
    private var dataSource: MonthsDataSource!
    
    let currentYear = CurrentValueSubject<String?, Never>(nil)
    
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
        tableView.separatorStyle = .none
        tableView.register(MonthTableViewCell.self, forCellReuseIdentifier: "MonthTableViewCell")
        
//        tableView.publisher(for: \.contentSize)
//            .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: false)
//            .map({ _ in () })
//            .sink(receiveValue: tableView.layoutIfNeeded)
//            .store(in: &cancellables)
        
        currentYear.sink(receiveValue: { [weak self] year in
            self?.navigationController?.viewControllers.first?.title = year
        }).store(in: &cancellables)
        
    }
    
    func createDataSource() {
        dataSource = MonthsDataSource(tableView: tableView) { tableView, indexPath, item in
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
            dataSource?.apply(snapshot)
        } else {
            dataSource?.apply(MonthsSnapshot())
        }
    }
    
}

extension MonthsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let startYear = Calendar.current.component(.year, from: DataSource.startTime)
        
        let displayingYear = String(startYear + (indexPath.row / 12))
        if displayingYear != currentYear.value {
            currentYear.send(String(displayingYear))
        }
    }
}
