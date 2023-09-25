//
//  MovieDetailPresenter.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

protocol MovieDetailViewMakable: AnyObject {
    func fillLabels()
}

class MovieDetailPresenter {
    weak var boxOfficeView: BoxOfficeViewMakable?
    var movieDetailService: MovieDetailService
    var movieDetail: MovieDetail?
    
    init( movieDetailService: MovieDetailService = MovieDetailModel()) {
        self.movieDetailService = movieDetailService
    }
    
    func fetchMovieDetailData() {
        movieDetailService.fetchMovieDetailAPI { [weak self] in
            guard let self = self else { return }
            
            self.movieDetail = $0
        }
    }
    
    
}
