//
//  CalendarPresenter.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/19.
//

import Foundation

protocol CalendarViewMakable: AnyObject {
    
}

class CalendarPresenter {
    weak var calendarView: CalendarViewMakable?
    var delegate: SendChoosenDateDelegate?
    var choosenDate: String = ""
    
    func receiveChoosenDate(_ choosenDate: String) {
        self.choosenDate = choosenDate
    }
    
    func resetChoosenDate() {
        choosenDate = ""
    }
    
    func sendChoosenDate() {
        delegate?.receive(choosenDate: choosenDate)
    }
}
