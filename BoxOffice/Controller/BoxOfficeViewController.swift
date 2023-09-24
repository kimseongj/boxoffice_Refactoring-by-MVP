//
//  ViewController.swift
//  BoxOffice
//
//  Created by goat, songjun on 13/01/23.
//

import UIKit

protocol CalendarDateDelegate: AnyObject {
    func receiveDate(date: String)
}

final class BoxOfficeViewController: UIViewController {
    private var presenter: BoxOfficePresenter?
    private var isCurrentListLayout: Bool = true
    private let imageSearchService = ImageSearchModel()
    
    @IBOutlet weak var boxOfficeListCollectionView: UICollectionView!
    lazy var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setURLCache()
        imageSearchService.removeCacheAfter30min()
        setUpView()
        configurePresenter()
        presenter?.getYesterdayDescription()
    }
    
    private func configurePresenter() {
        presenter = BoxOfficePresenter(boxOfficeView: self, dailyBoxOfficeService: DailyBoxOfficeModel())
    }
    
    private func setURLCache() {
        URLCache.shared = .init(memoryCapacity: 300 * 1024 * 1024, diskCapacity: 300 * 1024 * 1024, directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0])
    }
    
    private func setUpView() {
        setNavigationBar()
        setActivityIndicator()
        setBoxOfficeListCollectionView()
        configureRefreshControl()
        configureUI()
        setNavigationToolBar()
    }
    
    private func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "날짜선택", style: .plain, target: self, action: #selector(tabRightBarButton))
    }
    
    @objc
    private func tabRightBarButton() {
        guard let presenter = presenter else { return }
        let calendarPresenter = CalendarPresenter()
        let calendarViewController = CalendarViewController(presenter: calendarPresenter)

        calendarViewController.presenter?.delegate = presenter
        self.present(calendarViewController, animated: true, completion: nil)
    }
    
    private func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.startAnimating()
        boxOfficeListCollectionView.backgroundView = activityIndicator
    }
    
    private func setBoxOfficeListCollectionView() {
        boxOfficeListCollectionView.dataSource = self
        boxOfficeListCollectionView.delegate = self
        self.boxOfficeListCollectionView.collectionViewLayout = self.setUpCompositionalListLayout()
    }
    
    private func configureRefreshControl() {
        boxOfficeListCollectionView.refreshControl = UIRefreshControl()
        boxOfficeListCollectionView.refreshControl?.addTarget(self, action:
                                                                #selector(handleRefreshControl),
                                                              for: .valueChanged)
    }
    
    @objc
    private func handleRefreshControl() {
        DispatchQueue.main.async {
            self.boxOfficeListCollectionView.reloadData()
            self.boxOfficeListCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func configureUI() {
        let safeArea = view.safeAreaLayoutGuide
        
        boxOfficeListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            boxOfficeListCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            boxOfficeListCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            boxOfficeListCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            boxOfficeListCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

//MARK: - boxOfficeListCollectionView Mode
extension BoxOfficeViewController {
    private func setNavigationToolBar() {
        let flexibleSpace: UIBarButtonItem
        let changeModeButton: UIBarButtonItem
        
        changeModeButton = UIBarButtonItem(title: "화면 모드 변경", style: .plain, target: self, action: #selector(convertAlertMode))
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbarItems = [flexibleSpace, changeModeButton, flexibleSpace]
        self.navigationController?.isToolbarHidden = false
    }
    
    @objc func convertAlertMode() {
        if isCurrentListLayout == true {
            makeAlert(presentType: "아이콘", layoutType: setUpCompositionalIconLayout)
            isCurrentListLayout = false
        } else {
            makeAlert(presentType: "리스트", layoutType: setUpCompositionalListLayout)
            isCurrentListLayout = true
        }
    }

    private func makeAlert(presentType: String, layoutType: @escaping () -> UICollectionViewLayout) {
        let alertToListLayout = UIAlertController(title: "화면 모드 변경", message: "", preferredStyle: .actionSheet)
        alertToListLayout.addAction(UIAlertAction(title: presentType, style: .default, handler: { _ in
            self.boxOfficeListCollectionView.collectionViewLayout = layoutType()
            self.boxOfficeListCollectionView.reloadData()
        }))
        alertToListLayout.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in print("알럿 취소") }))
        present(alertToListLayout, animated: true)
    }
}

//MARK: - BoxOfficeViewMakable
extension BoxOfficeViewController: BoxOfficeViewMakable {
    func renewNavigationBarTitle() {
        self.title = presenter?.choosenDate.insertDash()
    }
    
    func reload() {
        boxOfficeListCollectionView.reloadData()
    }
}

//MARK: - boxOfficeListCollectionView DataSource
extension BoxOfficeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.sendDailyBoxOffice()?.boxOfficeResult.dailyBoxOfficeList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = String(describing: BoxOfficeListCell.self)
        let cell = boxOfficeListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BoxOfficeListCell
        
        switch isCurrentListLayout {
        case true:
            cell.configureListCellUI()
        case false:
            cell.configureIconCellUI()
        }
        
        guard let validDailyBoxOffice = presenter?.sendDailyBoxOffice() else {
            return cell
        }

        cell.setUpLabel(by: validDailyBoxOffice, indexPath: indexPath)
        
        return cell
    }
}

//MARK: - boxOfficeListCollectionView Delegate
extension BoxOfficeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        guard let movieCode = presenter?.sendDailyBoxOffice()?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieCode else { return }
        movieDetailVC.boxOfficeService.receiveMovieCode(movieCode: movieCode)
        
        self.navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

//MARK: - Compositional Layout
extension BoxOfficeViewController {
    private func setUpCompositionalListLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func setUpCompositionalIconLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupHeight =  NSCollectionLayoutDimension.fractionalWidth(1/2)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        return layout
    }
}
