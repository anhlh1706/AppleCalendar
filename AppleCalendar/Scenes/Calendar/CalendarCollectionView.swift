//
//  CalendarCollectionView.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 21/11/2022.
//

import UIKit
import Anchorage

enum Screen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

//final class SelectDateCollectionView: UIView {
//    
//    private(set) var collectionView: UICollectionView!
//    
//    private let startTime = Date(timeIntervalSince1970: 0)
//    
//    private var endTime: Date = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        return formatter.date(from: "31/12/2050")!
//    }()
//    
//    private let today = Date()
//    
//    var updateDate: ((Date) -> Void)?
//    
//    // Khoảng cách giữa các items
//    var itemSpacing: CGFloat = 2
//    
//    // Width height của item
//    var itemWidth: CGFloat {
//        let contentInset: CGFloat = 4
//        return (Screen.width - itemSpacing * 6 - contentInset) / 7
//    }
//    
//    var flowLayout: UICollectionViewFlowLayout? {
//        collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//    }
//    
//    init() {
//        super.init(frame: .zero)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        backgroundColor = .systemGroupedBackground
//        
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        addSubview(collectionView)
//        collectionView.edgeAnchors == edgeAnchors
//        
//        collectionView.register(LabelCollectionCell.self, forCellWithReuseIdentifier: "LabelCollectionCell")
//        collectionView.registerHeaderViewClass(EarlyPaymentDateSectionHeaderView.self)
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
//        
//        flowLayout?.itemSize = CGSize(width: itemWidth, height: itemWidth)
//        flowLayout?.minimumInteritemSpacing = 2
//        flowLayout?.minimumLineSpacing = 2
//        collectionView.backgroundColor = .clear
//        
//        observable()
//    }
//    
//    func observable() {
//        collectionView.rx
//            .itemSelected
//            .asDriver()
//            .mapToVoid()
//            .drive(onNext: selectDate)
//            .disposed(by: rx.disposeBag)
//    }
//    
//    func selectDate() {
//        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
//        
//        // Lấy tháng theo section
//        let monthOfCell = today.addMonths(numberOfMonths: selectedIndexPath.section)
//        
//        // Lấy ngày của cell theo item
//        let day = (selectedIndexPath.item + 2) - startWeekdayIndex(ofDate: monthOfCell)
//        
//        // Update lại ngày vào tháng
//        var component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: monthOfCell)
//        component.day = day
//        
//        selectingDate = Calendar.current.date(from: component) ?? (GlobalInstance.sharedInstance.appConfig?.tomorrow ?? tomorrow)
//        
//        updateDate?(selectingDate)
//    }
//    
//    func startWeekdayIndex(ofDate date: Date) -> Int {
//        // Calendar tính index đầu tiên là chủ nhật,
//        // lịch hiển thị đầu tiên là thứ 2, nên phải trừ đi 1 để ra index hiển thị trên màn hình
//        // thứ 2: index = 1,
//        let index = Calendar.current.component(.weekday, from: date.startOfMonth()) - 1
//        
//        // Chủ nhật index = 0 nhưng hiển thị cuối nên phải chuyển thành 7
//        return index == 0 ? 7 : index
//    }
//    
//    func numberOfDateInMonth(_ date: Date) -> Int {
//        return date.endOfMonth().day
//    }
//}
//
//extension SelectDateCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        let monthCount = (Calendar.current.dateComponents([.month], from: today, to: maxDate).month ?? 0) + 2
//        return max(1, monthCount)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let displayDate = today.addMonths(numberOfMonths: section)
//        return numberOfDateInMonth(displayDate) + startWeekdayIndex(ofDate: displayDate) - 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueCell(fromClass: LabelCollectionCell.self, indexPath: indexPath)
//        
//        // Lấy tháng theo section
//        let displayMonth = today.addMonths(numberOfMonths: indexPath.section).startOfMonth()
//        
//        let month = today.addMonths(numberOfMonths: indexPath.section).month
//        let year = today.addMonths(numberOfMonths: indexPath.section).year
//        let day = (indexPath.item + 2) - startWeekdayIndex(ofDate: displayMonth)
//        
//        // Lấy ngày mà cell hiển thị
//        guard let dayOfThisCell = "\(day)/\(month)/\(year)".toDate(kMCFormatterDateShort) else {
//            return collectionView.dequeueCell(fromClass: LabelCollectionCell.self, indexPath: indexPath)
//        }
//        
//        // Tô xám ngày hôm nay
//        if dayOfThisCell.startOfDay.compare(today.startOfDay) == .orderedSame {
//            cell.contentView.backgroundColor = .border
//            cell.titleLabel.textColor = .white
//        }
//        
//        // Disable những ngày đã qua hoặc hôm nay
//        let isPastOrToday = dayOfThisCell.compare(today) != .orderedDescending
//        let isEmptyCell = day <= 0
//        
//        // Disable những ngày quá hạn
//        let isOverMaxDate = dayOfThisCell.compare(maxDate) == .orderedDescending
//        
//        let isCellDisable = isPastOrToday || isEmptyCell || isOverMaxDate
//        
//        cell.isUserInteractionEnabled = !isCellDisable
//        cell.contentView.alpha = isCellDisable ? 0.3 : 1
//        
//        // Select sẵn nếu đã chọn date
//        if dayOfThisCell.startOfDayCurrentTimezone.compare(selectingDate.startOfDayCurrentTimezone) == .orderedSame &&
//            collectionView.indexPathsForSelectedItems.isNilOrEmpty {
//            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
//        }
//        
//        // day <= 0, ở section đầu tiên và những ngày trước ngày 1
//        // day > indexPath.item, những item đầu tiên và lấy ngày của tháng trước đó
//        cell.titleLabel.text = (day <= 0) ? "" : String(day)
//        return cell
//    }
//    
//    // Section header
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let month = today.addMonths(numberOfMonths: indexPath.section).month
//        let year = today.addMonths(numberOfMonths: indexPath.section).year
//        
//        let headerView = collectionView.dequeueHeaderView(fromClass: EarlyPaymentDateSectionHeaderView.self, indexPath: indexPath)
//        headerView.titleLabel.text = "Tháng \(month)/\(year)"
//        
//        return headerView
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        CGSize(width: Screen.width, height: 111)
//    }
//    
//}

