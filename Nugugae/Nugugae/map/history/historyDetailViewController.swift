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
        
        getMapData(url: server_url+"/history/detail/view") { (ids_location_data, ids_date_bylocation) in
            if ids_location_data.count > 0{
                self.prepare_location_str = ids_location_data[0]
                self.prepare_byloc_time_str = ids_date_bylocation[0]
            }
            else{
                print("정보없음")
            }
        }
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \thistory_detail_view")
        
        self.prepared_location_ary = self.prepare_location_str.components(separatedBy: "|")
        var temp_ary:[NMGLatLng] = []
        for str in self.prepared_location_ary {
            let temp_a = str.components(separatedBy: ",")
            if temp_a != [""]{
                var temp_latlng = NMGLatLng(lat: Double(temp_a[0])!, lng: Double(temp_a[1])!)
                temp_ary.append(temp_latlng)
            }
            else{
                print("배열 스플릿 끝")
            }
        }
        
        // map setting
        history_map.mapView.latitude = temp_ary[0].lat
        history_map.mapView.longitude = temp_ary[0].lng
        history_map.mapView.zoomLevel = 18
        history_map.mapView.maxZoomLevel = 20
        history_map.mapView.minZoomLevel = 16
        // 맵 카메라 줌 레벨, min max setting
        print(history_map.mapView.cameraPosition.zoom)
        // default 14
        history_map.showLocationButton = true
        // 현위치 설정 스위치 활성화
        history_map.showScaleBar = true
        // 축적바 활성화
        history_map.mapView.touchDelegate = self
        
//        let pathOverlay = NMFPath()
        let pathOverlay = NMFArrowheadPath()
//        pathOverlay.path = NMGLineString(points: temp_ary)
        pathOverlay.points = temp_ary
        pathOverlay.mapView = history_map.mapView
        pathOverlay.width = 7
        pathOverlay.outlineWidth = 1
        pathOverlay.headSizeRatio = 4
        pathOverlay.color = #colorLiteral(red: 0.9328386188, green: 0.6050601006, blue: 0.8566624522, alpha: 1)
        pathOverlay.outlineColor = #colorLiteral(red: 1, green: 0.7487370372, blue: 0.7549846768, alpha: 1)
        // 테두리 두께 1으로  ('아웃라인')
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
                }
            case.failure(let error):
                print(error)
            
            }
            completion(ids_location_data, ids_date_bylocation)
            // closer, 동기
        }
        
    }// 산책기록 detail 불러오기
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
