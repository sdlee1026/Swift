//
//  walkMapviewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/02.
//  Copyright © 2020 이성대. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import NMapsMap

class walkMapviewController: UIViewController, CLLocationManagerDelegate{
    
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var userdict = NearUser.sharedInstance.userdic
    var near_user_markerary = NearUser.sharedInstance.marker_ary
    var near_user_infoary = NearUser.sharedInstance.infowindow_ary
    // 근처 유저 관리 dict
    
    var selected_marker_id:String = ""
    // 마커 선택했을 때, 그 유저 아이디 저장할 스트링
    
    let now = Date()
    let date = DateFormatter()
    
    var start_time:String = ""
    
    // 맵 위치를 위한 값들
    
    var now_map_locationManager:CLLocationManager!
        // LocationManager 선언
    var now_latitude: Double?
    var now_longitude: Double?
    var now_coord_forNM: NMGLatLng?
    
    var tracking_user_index = 0
    // 주변 유저를 탐색하기 위한 동작 체킹 인덱스
    
    @IBOutlet weak var now_walk_map: NMFNaverMapView!
    // map View
    @IBOutlet weak var walk_start_label: UILabel!
    // 산책 시작 시간 label
    
    @IBOutlet weak var pass_dog_count_label: UILabel!
    // 지나쳤던 강아지 카운트 label
    // near user label 거리가 10미터 이내였던 경우에 올라간다.
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로 가기 버튼
    
    
    @IBOutlet weak var near_user_buttom_out: UIButton!
    
    @IBAction func near_user_btn(_ sender: Any) {
        print("근처 유저 리스트")
        if near_user_buttom_out.titleLabel!.text == String(0){
            print("아직 발견된 유저 없음")
        }
        else{
            print("유저 있음")
        }
    }
    @IBAction func stop_walk_btn(_ sender: Any) {
        print("stop_walk")
        location_data.sharedInstance.stop_location(completion: { (ids) in
            print(ids)
        })
        // location_data class의 중단 기능 함수 작동 _ 위치 데이터 저장, 현재 산책 유저 테이블에서 유저 삭제
        
    }
    // 산책 중지 버튼
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_Map_view Start")
        
        
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 날짜
        now_map_locationManager = CLLocationManager()
        now_map_locationManager.delegate = self
        now_map_locationManager.requestWhenInUseAuthorization()
        //포그라운드 상태에서 위치 추적 권한 요청
        now_map_locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //배터리에 맞게 권장되는 최적의 정확도
        now_map_locationManager.startUpdatingLocation()
        // 위치
        let coor = now_map_locationManager.location?.coordinate
        now_latitude = coor?.latitude
        now_longitude = coor?.longitude
        
        print("토큰 : ",UserDefaults.standard.string(forKey: "walk_isrunning")!)
        if UserDefaults.standard.string(forKey: "walk_isrunning") == "false"{
            start_time = date.string(from: now)
            print("시작시간 : ", start_time)
            location_data.sharedInstance.init_locationManager()
            // 산책 기록을 위한 위치 데이터 수집 시작, location_data.swift에 존재
            
            location_data.sharedInstance.init_update()
            // 서버에 산책 로그, 현재 사용자 추적 테이블 생성
        }
        else{
            print("산책 하기! 동작은, 이미 동작중일 것 -> 토큰 true일 경우.")
        }
        walk_start_label.text = start_time
        // start label setting
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\twalk_Map_view, walk_map_isrunning UserDefault -> true")
        super.viewWillAppear(true)
        // 현재 사용자가 산책하기 실시간 맵뷰를 켜놓았을 경우의 체크값(UserDefault)
        UserDefaults.standard.set("true", forKey: "walk_map_isrunning")
            // 쓰는 이유 : 이 화면이 보일 시에는 주변 유저들에 대한 정보 서칭을 이 클래스에서 수행하지만,
            // 백그라운드로 돌아가거나, 다른 뷰를 보고 있을때 또한 다른 유저들에 대한 정보 또한 location_data 클래스에서
            // 백그라운드 동작으로 잡아내고, 알림(진동 혹은 팝업 메시지)를 보내기 위함에 있음
            // view will appear 에서 true로 바뀌고, disapper 될때, false로 바뀜.. 값은 여기와 sceneDelegate에서만 바뀐다.
        
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, walk_Map_view")
        // 맵 데이터 로드 서버로 부터 요청, 맵 그리기 시작
        // 여기서 보여주는 데이터는 지금 까지 산책 경로 그리는건 필요없다, 일단은
        // 보여줄 정보, 1. 실시간으로 내 반경 100m 안에 있는 유저의 정보 피커
            // 1-1. 그 정보 피커 클릭시.. 동작 구현해야함
        now_walk_map.mapView.latitude = now_latitude!
        now_walk_map.mapView.longitude = now_longitude!
        // 맵 초기 위치값 현재값으로 고정
        now_walk_map.mapView.positionMode = .compass
        // 맵 카메라 모드 -> 사용자 시점 따라가기 기본으로 세팅
        now_walk_map.mapView.zoomLevel = 18
        now_walk_map.mapView.maxZoomLevel = 20
        now_walk_map.mapView.minZoomLevel = 16
        // 맵 카메라 줌 레벨, min max setting
        print(now_walk_map.mapView.cameraPosition.zoom)
        // default 14
        now_walk_map.showLocationButton = true
        // 현위치 설정 스위치 활성화
        now_walk_map.showScaleBar = true
        // 축적바 활성화
        now_walk_map.mapView.touchDelegate = self
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, walk_Map_view, walk_map_isrunning UserDefault -> false")
        UserDefaults.standard.set("false", forKey: "walk_map_isrunning")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "near_user_tracking"{
            print("marker click, segue prepare")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? NearUserTrackingInfoViewController {
                rvc.tracking_user = self.selected_marker_id
            }
        }
    }
    // segue 데이터전송시 준비
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("위치 업데이트됨, now map data")
        if let coor = manager.location?.coordinate{
            self.now_coord_forNM = NMGLatLng(lat: coor.latitude, lng: coor.longitude)
        }
        // walk_map <- 산책하기 맵이 동작하고 있을 경우에만.. 백그라운드 and 다른뷰 일때 동작 x
        if UserDefaults.standard.string(forKey:"walk_map_isrunning") == "true"{
            self.tracking_user_index += 1
            if self.tracking_user_index == 10{
                print("\t\t\tmap 뷰에 있는 상태의, 주변 유저 트래킹 이벤트 발생")
                getNearUserData(url: server_url+"/walkservice/near_user") { (ids_id, ids_lat, ids_lng) in
                    self.near_user_markerary = [:]
                    for (index, content) in ids_id.enumerated(){
                        self.near_user_markerary.updateValue(NMFMarker(), forKey: content)
                        self.near_user_infoary.updateValue(NMFInfoWindow(), forKey: content)
                        self.userdict.updateValue([ids_lat[index],ids_lng[index]], forKey: content)
                    }
                    for id in ids_id{
                        self.near_user_markerary[id]?.position = NMGLatLng(lat: self.userdict[id]![0], lng: self.userdict[id]![1])
                        let dataSource = NMFInfoWindowDefaultTextSource.data()
                        dataSource.title = id
                        self.near_user_infoary[id]?.dataSource = dataSource
                        
                        self.near_user_markerary[id]?.mapView = self.now_walk_map.mapView
                        self.near_user_markerary[id]?.iconImage = NMF_MARKER_IMAGE_PINK
                        self.near_user_markerary[id]?.captionText = id
                        self.near_user_markerary[id]?.captionRequestedWidth = 100
                        self.near_user_markerary[id]?.alpha = 0.8
                        self.near_user_markerary[id]?.touchHandler = {(overlay) -> Bool in
                            print("마커  터치됨, seg 동작될 것")
                            // seg ready
                            // 클릭 이벤트 발생, segue 호출
                            self.selected_marker_id = id
                            
                            self.performSegue(withIdentifier: "near_user_tracking", sender: nil)
                            return true
                        }
                        // 마커 핸들러 설정
                    }
                    self.tracking_user_index = 0
                }
            }
        }// 사용자 위치가 10번 추적 되었을 경우, 주변 유저 한번 탐색하는 쿼리 보낸다.
        // map 뷰에 주변 유저 피커 추가
        // lat, lng +-0.001, 값 이내에 있다 가정하면 근처에 있다고 일단 판단..
            // 서버로 userid랑, lat, lng 값 전송, db 에서 쿼리로 그 범위 안에 있는 유저들 좌표값을 통해 전송,
            // 전송 받고 난후에(userdict 클래스의 딕셔너리를 이용)
        
        //현재 멤 데이터에 피커 추가
        // 그 피커 선택시에 팝업창으로 유저의 정보 출력하기, 또한.. 그 유저와 나와의 거리 대략 출력하기?
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func getNearUserData(url: String, completion: @escaping ([String],[Double],[Double]) -> Void){
        let post_location = String(self.now_coord_forNM!.lat)+","+String(self.now_coord_forNM!.lng)
        print("유저 위치 전송, ",post_location)
        let parameters: [String:String] = [
            "id":self.user,
            "location_data":post_location
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids_id = [String]()
                var ids_lat = [Double]()
                var ids_lng = [Double]()
                
                switch response.result{
                    case .success(let value):
                        let nearUserData = JSON(value)// 응답
                        for U_json in nearUserData{
                            ids_id.append("\(U_json.1["id"])")
                            ids_lat.append(Double("\(U_json.1["last_location_lat"])")!)
                            ids_lng.append(Double("\(U_json.1["last_location_lng"])")!)
                        }
                        self.near_user_buttom_out.setTitle(String(nearUserData.count), for: .normal)
                    case .failure( _): break
                }
                completion(ids_id, ids_lat, ids_lng)
            }
        
    }// near User tracking api
    
    
        
}
extension walkMapviewController : NMFMapViewTouchDelegate{
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("지도를 터치했을 경우")
        for (id,info) in self.near_user_infoary{
            info.close()
            // 열린 정보창들 다 닫음
        }
    }
    
}
