//
//  MovieDetailModel.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

final class MovieDetailModel {
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
