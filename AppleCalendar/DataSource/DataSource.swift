//
//  DataSource.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import Foundation
import UIKit.UIScreen

enum Screen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

struct DataSource {
    
    static let shared = DataSource()
    
    static let startTime = Date(timeIntervalSince1970: 0)
    
    static let endTime: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: "31/12/2050")!
    }()
    
    let yearSections: [YearSection] = {
        let startYear = Calendar.current.component(.year, from: startTime)
        let endYear = Calendar.current.component(.year, from: endTime)
        
        return Array(startYear...endYear).map({ year in
            YearSection(year: year, months: Array(1...12).map({ MonthSection(month: $0, year: year) }))
        })
    }()
    
    let monthItems: [MonthSection] = {
        let startYear = Calendar.current.component(.year, from: startTime)
        let endYear = Calendar.current.component(.year, from: endTime)
        
        return Array(startYear...endYear).flatMap({ year in
            Array(1...12).map({ MonthSection(month: $0, year: year) })
        })
    }()
}

struct YearSection: Hashable {
    var year: Int
    var months: [MonthSection]
}

struct MonthSection: Hashable {
    let id = UUID()
    var month: Int
    var days: [String] // includes blank days (the days before 1st)
    let monthText: String
    
    init(month: Int, year: Int) {
        self.month = month
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        
        let date = formatter.date(from: "\(month)/\(year)")!
        
        /// Weekday start from 1
        /// minus 1 to count from zero
        /// Sunday is the first day in Weekday, but in our calendar, it placed in the last column
        /// so minus 1 one more time to set the first index = 0 to monday
        /// and set sunday to index of 6 to turn it last
        var startWeekdayIndex = Calendar.current.component(.weekday, from: date.startOfMonth()) - 2
        if startWeekdayIndex == -1 {
            startWeekdayIndex = 6
        }
        
        let dayCount = date.endOfMonth().day
        
        let blankDays = [String](repeating: "", count: startWeekdayIndex)
        days = blankDays + (1...dayCount).map { String($0) }
        
        formatter.dateFormat = "MMM"
        monthText = formatter.string(from: date)
    }
}

struct Day: Hashable, ExpressibleByStringLiteral {
    let id = UUID()
    var day: String
    
    init(stringLiteral value: StringLiteralType) {
        day = value
    }
    
    init(day: String) {
        self.day = day
    }
}
