//
//  DailyBoxOfficeModel.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

protocol DailyBoxOfficeService {
    func fetchDailyBoxOfficeAPI(date: String, completion: @escaping (DailyBoxOffice) -> Void)
}

final class DailyBoxOfficeModel: DailyBoxOfficeService{
    let provider = Provider()
    
    func fetchDailyBoxOfficeAPI(date: String, completion: @escaping (DailyBoxOffice) -> Void) {
        var dailyBoxOfficeEndpoint = DailyBoxOfficeEndpoint()
        dailyBoxOfficeEndpoint.insertDateQueryValue(date: date)
        
        provider.loadBoxOfficeAPI(endpoint: dailyBoxOfficeEndpoint,
                                  parser: Parser<DailyBoxOffice>()) { parsedData in
            completion(parsedData)
        }
    }
}
