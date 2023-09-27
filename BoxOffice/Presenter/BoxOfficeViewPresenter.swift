//
//  BoxOfficeViewPresenter.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/22.
//

import Foundation

protocol BoxOfficeViewMakable: AnyObject {
    func renewNavigationBarTitle()
    func reload()
    func stopActivityIndicator()
}

class BoxOfficePresenter: SendChoosenDateDelegate {
    weak var boxOfficeView: BoxOfficeViewMakable?
    var dailyBoxOfficeService: DailyBoxOfficeService
    var dailyBoxOffice: DailyBoxOffice?
    var choosenDate: String = "" {
        didSet {
            fetchBoxOfficeData {
                DispatchQueue.main.async {
                    self.boxOfficeView?.reload()
                    self.boxOfficeView?.renewNavigationBarTitle()
                    self.boxOfficeView?.stopActivityIndicator()
                }
            }
        }
    }
    
    func receive(choosenDate: String) {
        self.choosenDate = choosenDate
    }
    
    init(boxOfficeView: BoxOfficeViewMakable, dailyBoxOfficeService: DailyBoxOfficeService = DailyBoxOfficeModel()) {
        self.boxOfficeView = boxOfficeView
        self.dailyBoxOfficeService = dailyBoxOfficeService
        
        configureCalendarPresenterDelegate()
    }
    
    func configureCalendarPresenterDelegate() {
    
    }
    
    func fetchBoxOfficeData(completion: @escaping () -> Void) {
        dailyBoxOfficeService.fetchDailyBoxOfficeAPI(date: choosenDate) { [weak self] in
            guard let self = self else { return }
            
            self.dailyBoxOffice = $0
            completion()
        }
    }
    
    func sendDailyBoxOffice() -> DailyBoxOffice? {
        
        return dailyBoxOffice
    }
    
    func getYesterdayDescription() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let yesterDate = formatter.string(from: Date(timeIntervalSinceNow: -86400))
        choosenDate = yesterDate
    }
}

protocol SendChoosenDateDelegate: AnyObject {
    func receive(choosenDate: String)
}
