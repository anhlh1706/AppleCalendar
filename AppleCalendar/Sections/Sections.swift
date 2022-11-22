//
//  Sections.swift
//  AppleCalendar
//
//  Created by Lê Hoàng Anh on 22/11/2022.
//

import Foundation

let startTime = Date(timeIntervalSince1970: 0)

var endTime: Date = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.date(from: "31/12/2050")!
}()

struct YearSection: Hashable {
    var year: Int
    var months: [MonthSection]
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

struct MonthSection: Hashable {
    let id = UUID()
    var month: Int
    var days: [String] // includes blank day (the day before 1st)
    let monthText: String
    
    init(month: Int, year: Int) {
        self.month = month
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        
        let date = formatter.date(from: "\(month)/\(year)")!
        
        let startWeekdayIndex = Calendar.current.component(.weekday, from: date.startOfMonth()) - 1
        
        let dayCount = date.endOfMonth().day
        
        // Sunday has index 0 but it's placed in the last column so turn it to 7
        let blankDays = [String](repeating: "", count: startWeekdayIndex)
        days = blankDays + (0...dayCount).map { String($0) }
        
        formatter.dateFormat = "MMM"
        monthText = formatter.string(from: date)
    }
}
