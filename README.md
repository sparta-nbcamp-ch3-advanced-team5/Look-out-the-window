
<img src ="https://github.com/user-attachments/assets/f0a85eda-b5f0-4a8c-b019-6da51bfe2277" height="90">


# 창밖을 보라(Look-out-the-window)
자신의 위치를 기반으로 등록 된 킥보드를 사용하고 반납이 가능하며 운영자는 킥보드를 등록할 수 있는 서비스

<br><br>
## 🪟 창밖을 보라 🪟
<img src="https://github.com/user-attachments/assets/80825440-8631-4f48-86cc-d6122e746fd1" width="200"> | <img src="https://github.com/user-attachments/assets/926566a3-d298-48c9-a37b-75330ce88f39" width="200"> | <img src="https://github.com/user-attachments/assets/dd6d1e55-3e88-499d-befe-cb58b799a83d" width="200"> | <img src="https://github.com/user-attachments/assets/e71aa939-a73d-4327-ba1c-cc8fc866234e" width="200"> | <img src="https://github.com/user-attachments/assets/4e606d56-de7e-441a-ada1-1a7c5a10b2a0" width="200"> |
:---------:|:----------:|:---------:|:---------:|:---------:|
이민재 | 정근호 | 윤주형 | 고욱현 | 서동환 |
[GitHub](https://github.com/minjae-L) | [GitHub](https://github.com/eightroutes) | [GitHub](https://github.com/YunJuHyung) | [GitHub](https://github.com/imo2k) | [GitHub](https://github.com/SNMac) |
<br>





## 💻 Development Environment

<img src ="https://img.shields.io/badge/Xcode-16.3-blue?logo=xcode" height="30"> <img src ="https://img.shields.io/badge/iOS-16.0-white.svg" height="30">

<br>

## 📖 Using Library

라이브러리 | 사용 목적 | Management Tool
:---------:|:----------:|:---------:
SnapKit | UI Layout | SPM
Then | UI 선언 | SPM
RxSwift | 데이터 바인딩을 통한 비동기 데이터 흐름 처리 | SPM
RxCoCoa | UI 컴포넌트(예: 버튼 `rx.tap`)의 반응형 이벤트 처리 | SPM
RxDataSources | `UITableView`, `UICollectionView`의 데이터 처리 | SPM
RiveRuntime | 날씨 아이콘 표시 | SPM
Alamofire | 네트워크 API 통신 | SPM

<br>

## 📂 Folder Architecture

<details>
<summary> 프로젝트 폴더 구조 </summary>
<div markdown="1">

```bash
Look-out-the-window
├── Look-out-the-window
│   ├── App
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Data
│   │   ├── CoreLocation
│   │   ├── DTO
│   │   ├── Error
│   │   ├── Model
│   │   ├── Network
│   │   └── PersistentStorages
│   ├── Presentation
│   │   ├── Common
│   │   ├── RegionList
│   │   ├── Register
│   │   ├── Shared
│   │   └── WeatherDetail
│   └── Resources
│       ├── Assets.xcassets
│       ├── Base.lproj
│       ├── Config.xcconfig
│       ├── Info.plist
│       ├── ko.lproj
│       └── Riv
└── Look-out-the-window.xcodeproj
    ├── project.pbxproj
    ├── project.xcworkspace
    │   ├── contents.xcworkspacedata
    │   ├── xcshareddata
    │   └── xcuserdata
    └── xcuserdata
```
  
</details>

<br>
	
## 🌷 역할 분담
<details>
<summary> 이민재 </summary>
<div markdown="1">
	
 - 네트워크 매니저
 - 데이터 모델링
 - 비동기 처리 프로세스 구현
 - 지역 등록 화면
 - 날씨 세부 UI 컴포넌트


</div>
</details>
	
<details>
<summary> 정근호 </summary>
<div markdown="1"> 

 - 전반적인 배경화면
 - 날씨 세부 화면 페이징 뷰
 - 날씨 아이콘(Rive Runtime)
 - 디자인, 애니메이션


</div>
</details>
  
<details>
<summary> 윤주형 </summary>
<div markdown="1">

 - `CoreDataManager` 구현
 - 앱 실행 시 화면 전환 로직


</div>
</details>

<details>
<summary> 고욱현 </summary>
<div markdown="1">
	
 - 날씨 세부 화면 레이아웃 구성
 - 날씨 세부 UI 컴포넌트
 - 하단 날씨 정보 `UICollectionView`

 

</div>
</details>

<details>
<summary> 서동환 </summary>
<div markdown="1">
	
 - `CoreLocationManager` 구현
 - 지역 검색 화면

</div>
</details>
  
<br>
	
## 💭 트러블 슈팅
<details>
<summary> 이민재 </summary>
<div markdown="1">
</br>
	
**Date, TimeOffset**
	
- 문제
  - 각 나라별 시차(TimeOffset)을 고려하지 않고DateFormatter, Date가 사용되어 해당 나라의 시차가 아닌 한국 시차, 또는 시뮬레이터의 위치 기반 시차로 적용되는 문제
  - BezierPath로 현재위치를 구해서 적용할 때, 시차가 적용되지 않아서 Index out of range 에러 발생
- 해결
  - DTO에서만  TimeZone, TimeOffset을 설정해주고 변환하여 리턴
  - 다른 곳에서 Date 생성하여 시간을 설정하지 않도록 수정

</br>
</div>
</details>

<details>
<summary> 정근호 </summary>
<div markdown="1">
</br>
	
**Rive Runtime 최적화 문제**

- 문제
  - `UIScrollView` 내부에 존재하는 Rive Runtime이 화면 표시에 상관없이 모두 재생되는 문제 발생
- 해결
  - 초기 로드 시 Rive 애니메이션을 Stop한 후, Rx를 이용하여 페이징 후에 Play가 되도록 함

</br>
</div>
</details>

  
<details>
 <summary> 윤주형 </summary>
<div markdown="1">
 </br>
	
 **앱 실행시 화면 전환 로직**
 
- 문제
  - UserDefaults.set 값으로 클릭했던 화면 접속,없다면 첫번째 cell 화면 접속
  - 오토 레이아웃 뷰계층 문제가 있었고, 데이터가 들어오지 않는 현상이 있었습니다.
- 해결
  - 데이터 릴레이를 PublishRelay를 behavior로 바꾸어 nil값이 들어오는 현상을 임시적으로 방지했습니다.

</br>
</div>
</details>

<details>
<summary> 고욱현 </summary>
<div markdown="1">
</br>
	
**Progress Bar, Indicator**

- 문제
  - Indicator 기능 추가를 후순위로 미뤄두고 Model과 DTO, CoreData를 구현해버려서 대대적인 수정이 필요해졌습니다.
- 해결
  - 해당 문제를 인지한 시점에 HOTFIX 하여 구현 완료하였습니다.

</br>
</div>
</details>

<details>
<summary> 서동환 </summary>
<div markdown="1">
</br>
	
**UIBezierPath & CALayer mask**

- 문제
  - `UITableViewCell`의 배경으로 모서리가 둥근 사다리꼴을 구현하기 위해 `UIBezierPath`를 사용하였는데, 빗변의 모서리를 잇는 과정에서 선이 날카롭게 이어지는 문제가 발생했습니다.
- 해결
  - Bezier 곡선의 기울기를 통일시키는 과정을 직접 기울기 계산 및 비율에 맞는 `CornerRadius` 사용을 통해 거치면서 빗변 모서리를 부드럽게 잇는 데에 성공하였습니다.

</br>
</div>
</details>
