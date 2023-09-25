//
//  MovieDetailModel.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

protocol MovieDetailService {
    func fetchMovieDetailAPI(movieCode: String, completion: @escaping (MovieDetail) -> Void)
}

final class MovieDetailModel: MovieDetailService {
    let provider = Provider()
    var movieDetail: MovieDetail?
    var movieCode = ""
    
    func fetchMovieDetailAPI(completion: @escaping (MovieDetail) -> Void) {
        var movieDetailEndpoint = MovieDetailEndpoint()
        movieDetailEndpoint.insertMovieCodeQueryValue(movieCode: movieCode)
        
        provider.loadBoxOfficeAPI(endpoint: movieDetailEndpoint,
                                  parser: Parser<MovieDetail>()) { parsedData in
            completion(parsedData)
        }
    }
    
    func receiveMovieCode(movieCode: String) {
        self.movieCode = movieCode
    }
}
