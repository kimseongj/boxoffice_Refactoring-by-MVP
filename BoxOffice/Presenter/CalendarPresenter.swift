//
//  CalendarPresenter.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/19.
//

import Foundation

protocol CalendarViewMakable: AnyObject {
    
}

protocol CalendarViewPresenter {
    init(calendarView: CalendarViewMakable)
    func showView()
}

class CalendarPresenter: CalendarViewPresenter {
    weak var calendarView: CalendarViewMakable?
    var choosenDate: String = ""
    
    required init(calendarView: CalendarViewMakable) {
        self.calendarView = calendarView
    }
    
    func showView() {
        
    }
    
    func receiveChoosenDate(_ choosenDate: String) {
        self.choosenDate = choosenDate
    }
    
    func resetChoosenDate() {
        choosenDate = ""
    }
}
