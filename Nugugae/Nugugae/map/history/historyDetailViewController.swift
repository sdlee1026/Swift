//
//  historyDetailViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/10.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NMapsMap
// "walk_detail_seg", history -> detail
class historyDetailViewController:UIViewController{
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var seg_date:String = ""
    // seg로 전송 받을 데이터
    var prepare_location_str:String = ""
    var prepare_byloc_time_str:String = ""
    
    var prepared_location_ary:[String] = []
    
    var start_page = ""
    
    @IBOutlet weak var distance_label: UILabel!
    
    @IBOutlet weak var select_history_btn: UIButton!
    // 산책기록(텍스트) -> 여기로 온 페이지 일 경우 활성할 버튼
    @IBAction func select_history_btn_action(_ sender: Any) {
        print("맵 데이터 선택 완료")
        UserDefaults.standard.setValue("true", forKey: "map_select_token")
        // 맵 데이터 선택 완료 토큰
        self.start_page = ""
        self.select_history_btn.isEnabled = false
        self.dismiss(animated: true, completion: nil)
    }
    // 선택하기 버튼
    
    @IBOutlet weak var del_btn: UIButton!
    @IBAction func del_btn_action(_ sender: Any) {
        
        let del_alert = UIAlertController(title: "산책 경로 삭제!", message: "연관된 일지들도 삭제됩니다!", preferredStyle: .alert)
        let yes = UIAlertAction(title: "네!", style: .default) { (action) in
            self.delMapData(url: self.server_url+"/history/delete") { (ids) in
                print(ids)
                self.dismiss(animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "취소!", style: .cancel, handler: nil)
        del_alert.addAction(yes)
        del_alert.addAction(cancel)
        present(del_alert, animated: true, completion: nil)
        
        
        
    }
    @IBOutlet weak var history_map: NMFNaverMapView!
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history_detail_view Start")
        
        print("seg_date : ", seg_date)
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\thistory_detail_view")
        super.viewWillAppear(true)
        if start_page == "walk_history"{
            self.select_history_btn.isEnabled = true
            // 선택 가능하게
            self.del_btn.isEnabled = false
        }else{
            self.select_history_btn.isEnabled = false
            self.del_btn.isEnabled = true
        }
        // 시작 페이지 구분으로 버튼 세팅
        getMapData(url: server_url+"/history/detail/view") { (ids_location_data, ids_date_bylocation) in
            if ids_location_data.count > 0{
                self.prepare_location_str = ids_location_data[0]
                self.prepare_byloc_time_str = ids_date_bylocation[0]
                
                
                self.prepared_location_ary = self.prepare_location_str.components(separatedBy: "|")
                var temp_ary:[NMGLatLng] = []
                for str in self.prepared_location_ary {
                    let temp_a = str.components(separatedBy: ",")
                    if temp_a != [""]{
                        let temp_latlng = NMGLatLng(lat: Double(temp_a[0])!, lng: Double(temp_a[1])!)
                        temp_ary.append(temp_latlng)
                    }
                    else{
                        print("배열 스플릿 끝")
                    }
                    
                }// 전처리
                
                self.history_map.mapView.latitude = temp_ary[0].lat
                self.history_map.mapView.longitude = temp_ary[0].lng
                self.history_map.mapView.zoomLevel = 18
                self.history_map.mapView.maxZoomLevel = 20
                self.history_map.mapView.minZoomLevel = 16
                // map setting
                // 맵 카메라 줌 레벨, min max setting
                print(self.history_map.mapView.cameraPosition.zoom)
                // default 14
                self.history_map.showLocationButton = true
                // 현위치 설정 스위치 활성화
                self.history_map.showScaleBar = true
                // 축적바 활성화
                self.history_map.mapView.touchDelegate = self
                
//                    let pathOverlay = NMFPath()
                let pathOverlay = NMFArrowheadPath()
//                    pathOverlay.path = NMGLineString(points: temp_ary)
                pathOverlay.points = temp_ary
                pathOverlay.mapView = self.history_map.mapView
                pathOverlay.width = 7
                pathOverlay.outlineWidth = 1
                pathOverlay.headSizeRatio = 4
                pathOverlay.color = #colorLiteral(red: 0.9328386188, green: 0.6050601006, blue: 0.8566624522, alpha: 1)
                pathOverlay.outlineColor = #colorLiteral(red: 1, green: 0.7487370372, blue: 0.7549846768, alpha: 1)
                // 테두리 두께 1으로  ('아웃라인')
            }
            else{
                print("정보없음")
            }
            //맵 로드, 클로저 내부
        }// 요청 클로저 종료
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \thistory_detail_view")
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \thistory_detail_view")
        self.history_map.mapView.touchDelegate = nil
        self.history_map.removeFromSuperview()
        self.history_map = nil
        // memory 초기화
    }
    // 스크롤 func
    
    func getMapData(url: String, completion:@escaping ([String], [String])->Void){
        
        let parameters: [String:String] = [
            "id": self.user,
            "date":self.seg_date
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).responseJSON{ response in
            var ids_location_data = [String]()
            var ids_date_bylocation = [String]()
            
            switch response.result{
            case .success(let value):
                let historyJson = JSON(value)
                // SwiftyJSON 사용
                if (historyJson["err"] == "No history" || historyJson["err"] == "No item"){
                    print("!")
                    print("\(historyJson["err"])")
                }
                else{
                    ids_location_data.append("\(historyJson["location_data"])")
                    ids_date_bylocation.append("\(historyJson["date_bylocation"])")
                    self.distance_label.text = "\(historyJson["distance"])"
                }
            case.failure(let error):
                print(error)
            
            }
            completion(ids_location_data, ids_date_bylocation)
            // closer, 동기
        }
        
    }// 산책기록 detail 불러오기
    
    func delMapData(url: String, completion:@escaping ([String])->Void){
        
        let parameters: [String:String] = [
            "id": self.user,
            "date":self.seg_date,
            "distance":self.distance_label.text!
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).responseJSON{ response in
            var ids = [String]()
            switch response.result{
            case .success(let value):
                let historyJson = JSON(value)
                // SwiftyJSON 사용
                if (historyJson["err"] == "No history" || historyJson["err"] == "No item"){
                    print("!")
                    print("\(historyJson["err"])")
                }
                else{
                    ids.append("delete OK!")
                }
            case.failure(let error):
                print(error)
                
            }
            completion(ids)
        }
    }
    
}
extension historyDetailViewController : NMFMapViewTouchDelegate{
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("지도를 터치했을 경우")
//        for (id,info) in self.near_user_infoary{
//            info.close()
//            // 열린 정보창들 다 닫음
//        }
    }
    
}
