//
//  CalendarViewController.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/19.
//

import UIKit

class CalendarViewController: UIViewController, CalendarViewMakable {
    var presenter: CalendarPresenter?
    private var calendarView = CalendarView()
    weak var delegate: CalendarDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = calendarView
        setCalendarViewSelectionBehavior()
        //configurePresenter()
    }
    
    init(presenter: CalendarPresenter?) {
        
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePresenter() {
        presenter = CalendarPresenter()
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
        presenter.sendChoosenDate()
        presenter.resetChoosenDate()
        
        self.dismiss(animated: true)
    }
}
