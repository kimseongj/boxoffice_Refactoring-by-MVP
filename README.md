# 🎬 BoxOffice Project - Refactoring By MVP

## ⚒️ 기능 소개
영화진흥위원회 API, 다음 이미지 API를 기반으로 박스오피스 순위를 보여주는 프로젝트 

|영화 순위 테이블 리스트|영화 순위 격자 리스트|
|:----:|:----:|
|<img src="https://github.com/kimseongj/TIL/assets/88870642/889d0c16-4fd8-4eb1-9090-c291dbb48dee" width=250>|<img src="https://github.com/kimseongj/TIL/assets/88870642/f9312cd6-165e-4cae-8b76-634dd626e1c2" width=250>|
|영화순위를 테이블 리스트 형태로 표현합니다.|영화순위를 격자 리스트 형태로 표현합니다.|
|**날짜 선택**|**영화 상세정보**|
|<img src="https://github.com/kimseongj/TIL/assets/88870642/0d45266a-9417-4a40-8620-ad43b2bd1a0f" width=250>|<img src="https://github.com/kimseongj/TIL/assets/88870642/92bfc039-df54-48c8-b0c1-a96de8623ac6" width=250>|
|날짜를 선택하여 과거 영화순위를 확인할 수 있습니다.|영화 이미지를 API호출하고 상세 정보를 볼 수 있습니다.|


## ⚙️ 기술 스택

<img src="https://img.shields.io/badge/MVP-100AF?style=flat-square"/>
<img src="https://img.shields.io/badge/NetworkLayer-AAA1AF?style=flat-square"/>
<img src="https://img.shields.io/badge/URLSession-100000?style=flat-square"/>
<img src="https://img.shields.io/badge/ModernCollectionView-FF0000?style=flat-square"/>

## 📝 아키텍쳐
### - MVP

## 🏃기술적 도전
<details>
    <summary><big>MVP</big></summary>
    
### MVP
>MVP 패턴을 이해하고자 MVC로 진행했던 프로젝트인 boxoffice를 MVP로 리팩토링해보았습니다.

:fire: **MVP란?**
MVP는 Model View Presenter로 나누어지며, Model과 View는 서로를 모르고 Presenter를 통해 Model의 데이터를 받아서 사용하고, View에서의 사용자 이벤트, UI업데이트를 합니다.

- **Model**
Model은 외부 데이터 혹은 내부 데이터 등 앱 실행에 있어 실질적으로 필요한 데이터를 갖고 있습니다.

- **View**
UI를 그리는 메서드, 프로퍼티 등을 선언하고 작동시킵니다.

- **Presenter**
Model의 데이터를 가지고 비즈니스 로직을 구현하고 View의 UI업데이트를 합니다. 이 때, UI업데이트란, 직접 UI를 구현한다기 보다 비즈니스 로직에 의해 UI의 데이터 변경을 뜻합니다.

:fire: **배운 점**
- Presenter가 Model과 View를 연결해주는 역할을 하기때문에 결합도가 높아질 수 있습니다. 이를 방지하기 위해 Protocol을 사용하여 의존성 역전을 시켜야 합니다.
- Binding을 사용하지 않기 때문에 데이터의 변화 추적을 구현해주어야 합니다.
    
</details>

<details>
    <summary><big>Network Layer 구현</big></summary> 
    
### Network Layer
> Network Layer를 구현하여 network 과정의 모듈화 및 유닛 테스트를 할 수 있도록 구현했습니다. Endpoint, Provider, Parser를 만들었고, Endpoint의 경우 EndpointMakable Protocol을 구현하여 채택했습니다.

#### :fire: 코드 구현
- **EndpointMakable**
```swift
protocol EndpointMakeable {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
    var header: [String: String]? { get }
    
    func makeURL() -> URL?
    func makeURLRequest() -> URLRequest?
}

extension EndpointMakeable {
    
    func makeURL() -> URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = path
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { return nil }
        
        return url
    }
    
    func makeURLRequest() -> URLRequest? {
        guard let url = makeURL() else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        header?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        return urlRequest
    }
}
```
- **Provider**
```swift
struct Provider {
    func requestAPI<T: Decodable>(endpoint: EndpointMakeable, parser: Parser<T>, completion: @escaping (T) -> Void) {
        guard let request = endpoint.makeURLRequest() else { return }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { return }
            
            guard let httpURLResponse = response as? HTTPURLResponse, (200...299).contains(httpURLResponse.statusCode) else { return }
            
            guard let validData = data, let parsedData = parser.parse(data: validData) else { return }
            completion(parsedData)
        }
        dataTask.resume()
    }
}
```
</details>

<details>
    <summary><big>NSMutableAttributedString 활용</big></summary> 
    
### NSMutableAttributedString 활용
> 프로젝트 진행 중 하나의 String에서 여러 색이 사용되야되는 요구사항이 있었습니다. NSMutableAttributedString을 사용하여 이 문제를 해결하였습니다.
    
🔥 **NSMutableAttributedString에서 색 메서드 구현**
- 한개의 Label에 여러 색의 글자를 넣기 위해 고민했고, 이를 해결하기 위해 NSMutableAttributedString을 extension하여 색 변환 메서드를 생성하였습니다.
- 디셔너리 타입의 attributes를 수정하는 방식으로 구현했습니다.
    
🔥 **코드 구현**    
```swift
extension NSMutableAttributedString {
    func makeColorToText(string: String, color: UIColor) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        append(NSAttributedString(string: string, attributes: attributes))
        
        return self
    }
}
```
</details>

<details>
    <summary><big>Compositional layout 공부</big></summary> 
    
### Compositional layout
>Compositional layout을 도입하여 CollectionView의 Layout을 구현했습니다. List형태의 layout과 격자 형태의 layout을 구현해보았습니다.
    
:fire: **Section, Group, Item**
- Section
    - Section은 CollectionView에서 다양한 Cell형태를 하나의 CollectionView에 표현할 수 있도록 해줍니다.
- Group
    - Group은 표시하려는 데이터의 가장 작은 단위로 Item을 포함하고 있습니다.
- Item
    - Item은 Cell하나를 표현합니다.
    
:fire: **코드 구현**
- **List**
```swift
private func setUpCompositionalListLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
```
    
- **Grid**
```swift
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
```
</details>

<details>
    <summary><big>Calendarview 활용</big></summary> 
    
### Calendarview
>CalendarView를 사용하여 날짜를 선택하는 기능을 구현했습니다. 하지만 CalendarView는 iOS16 이상부터 사용할 수 있어 버전을 올려 사용했습니다. 현재 iOS16 이용자는 81%로 CalendarView를 현업에서 사용하는 것은 다소 어려움이 있을 것으로 보입니다. 
    
:fire: **코드 구현**

- **UICalendarView**
```swift
class CalendarView: UICalendarView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.availableDateRange = DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), end: Date(timeIntervalSinceNow: -86400))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

- **UICalendarSelectionSingleDateDelegate**
```swift
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
```
    
</details>
