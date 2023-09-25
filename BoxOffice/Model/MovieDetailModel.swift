//
//  MovieDetailModel.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

protocol MovieDetailService {
    func fetchMovieDetailAPI(completion: @escaping () -> Void)
}

final class MovieDetailModel: MovieDetailService {
    let provider = Provider()
    var movieDetail: MovieDetail?
    var movieCode = ""
    
    func fetchMovieDetailAPI(completion: @escaping () -> Void) {
        var movieDetailEndpoint = MovieDetailEndpoint()
        movieDetailEndpoint.insertMovieCodeQueryValue(movieCode: movieCode)
        
        provider.loadBoxOfficeAPI(endpoint: movieDetailEndpoint,
                                  parser: Parser<MovieDetail>()) { parsedData in
            self.movieDetail = parsedData
            completion()
        }
    }
    
    func receiveMovieCode(movieCode: String) {
        self.movieCode = movieCode
    }
}
