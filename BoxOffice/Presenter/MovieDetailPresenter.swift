//
//  MovieDetailPresenter.swift
//  BoxOffice
//
//  Created by kimseongjun on 2023/09/25.
//

import Foundation

protocol MovieDetailViewMakable: AnyObject {
    func fillLabels(movieDetail: MovieDetail?)
    func fillImage(iamgeData: Data)
}

class MovieDetailPresenter {
    weak var movieDetailView: MovieDetailViewMakable?
    var movieDetailService: MovieDetailService
    var imageSearchService: ImageSearchService
    var thumbnailImageData: Data?
    var movieCode: String
    var movieName: String = "" 
    
    init(movieDetailService: MovieDetailService = MovieDetailModel(),
         imageSearchService: ImageSearchService = ImageSearchModel(), movieCode: String) {
        self.movieDetailService = movieDetailService
        self.imageSearchService = imageSearchService
        self.movieCode = movieCode
    }
    
    func fetchMovieDetailData(completion: @escaping () -> Void) {
        movieDetailService.fetchMovieDetailAPI(movieCode: movieCode) { [weak self] in
            guard let self = self else { return }
                self.movieDetailView?.fillLabels(movieDetail: $0)
                self.fetchSearchedImage(movieName: $0.movieInformationResult.movieInformation.movieName)
            completion()
        }
    }
    
    func fetchSearchedImage(movieName: String) {
        imageSearchService.fetchSearchedImage(movieName: movieName) { [weak self] in
            guard let self = self else { return }
            self.movieDetailView?.fillImage(iamgeData: $0)
        }
    }
}
