//
//  CalendarViewController.swift
//  BoxOffice
//
//  Created by goat, songjun on 2023/04/04.
//

import UIKit

class CalendarViewController: UIViewController, CalendarViewMakable {
    var presenter: CalendarPresenter?
    private var calendarView = CalendarView()
    weak var delegate: CalendarDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CalendarPresenter(calendarView: self)
        view = calendarView
        setCalendarViewSelectionBehavior()
    }
    
    private func setCalendarViewSelectionBehavior() {
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
    }
}

extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let presenter = presenter else { return }
        guard let year = dateComponents?.year?.addZeroAndConvertToString() else { return }
        guard let month = dateComponents?.month?.addZeroAndConvertToString() else { return }
        guard let day = dateComponents?.day?.addZeroAndConvertToString() else { return }
        let choosenDate: String = year + month + day
        
        presenter.receiveChoosenDate(choosenDate)
        delegate?.receiveDate(date: presenter.choosenDate)
        presenter.resetChoosenDate()
        
        self.dismiss(animated: true)
    }
}

