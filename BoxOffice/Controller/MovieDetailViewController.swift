//
//  MovieDetailViewController.swift
//  BoxOffice
//
//  Created by goat, songjun on 2023/03/30.
//

import UIKit

class MovieDetailViewController: UIViewController {
    private var presenter: MovieDetailPresenter?
    private let imageSearchService = ImageSearchModel()
    private let movieDetailView = MovieDetailView()
    private let provider = Provider()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    init(presenter: MovieDetailPresenter?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = movieDetailView
        setActivityIndicator()
        configurePresenter()
        presenter?.fetchMovieDetailData {
            self.stopActivityIndicator()
        }
    }
    
    func configurePresenter() {
        presenter?.movieDetailView = self
    }
    
    private func setActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension MovieDetailViewController: MovieDetailViewMakable {
    func fillLabels(movieDetail: MovieDetail?) {
        DispatchQueue.main.async {
            self.movieDetailView.directorTitleLabel.text = "감독"
            self.movieDetailView.directorDataLabel.text = self.presenter?.reformString(movieDetail: movieDetail, labelText: "감독")
            self.movieDetailView.productYearTitleLabel.text = "제작년도"
            self.movieDetailView.productYearDataLabel.text = movieDetail?.movieInformationResult.movieInformation.productYear
            
            self.movieDetailView.openDayTitleLabel.text = "개봉일"
            self.movieDetailView.openDayDataLabel.text =
            movieDetail?.movieInformationResult.movieInformation.openDate.insertDash()
            
            self.movieDetailView.showTimeTitleLabel.text = "상영시간"
            self.movieDetailView.showTimeDataLabel.text = movieDetail?.movieInformationResult.movieInformation.showTime
            
            self.movieDetailView.auditsTitleLabel.text = "관람등급"
            self.movieDetailView.auditsDataLabel.text = self.presenter?.reformString(movieDetail: movieDetail, labelText: "관람등급")
            
            self.movieDetailView.nationTitleLabel.text = "제작국가"
            self.movieDetailView.nationDataLabel.text = self.presenter?.reformString(movieDetail: movieDetail, labelText: "제작국가")
            
            self.movieDetailView.genreTitleLabel.text = "장르"
            self.movieDetailView.genreDataLabel.text = self.presenter?.reformString(movieDetail: movieDetail, labelText: "장르")
            
            self.movieDetailView.actorTitleLabel.text = "배우"
            self.movieDetailView.actorDataLabel.text = self.presenter?.reformString(movieDetail: movieDetail, labelText: "배우")
        }
    }
    
    func fillImage(iamgeData: Data) {
        DispatchQueue.main.async {
            self.movieDetailView.imageView.image = UIImage(data: iamgeData)
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}
