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

class walkMapviewController: UIViewController, CLLocationManagerDelegate{
    
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var locationManager:CLLocationManager!
        // LocationManager 선언
    var latitude: Double?
    var longitude: Double?
    // 위도와 경도
    var img_latitude: Double = -1
    var img_longitude: Double = -1
    
    let now = Date()
    
    let date = DateFormatter()
    
    var start_time:String = ""
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_Map_view Start")
        
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        start_time = date.string(from: now)
        print("시작시간 : ", start_time)
        // 위치
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.startUpdatingLocation()
        //위치업데이트
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\twalk_Map_view")
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, walk_Map_view")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, walk_Map_view")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
            print("위치 업데이트됨")
            if let coor = manager.location?.coordinate{
                let input_loction = [Float(coor.latitude), Float(coor.longitude)]
                print("ary_들어있는 위치값 갯수:")
                print(location_data.sharedInstance.location_ary.count)
                let last_index = location_data.sharedInstance.location_ary.endIndex - 1// 배열 마지막 인덱스
                
                if location_data.sharedInstance.location_ary[last_index] == [-1,-1]{
                    location_data.sharedInstance.location_ary[last_index] = input_loction
                }// 첫번째 insert
                else if location_data.sharedInstance.location_ary[last_index] == input_loction{
                    // 위치 변동이 없었을 경우
                    print("위치 변동 x, not insert")
                }
                else{
                    print("위치 변동 o, insert to ary")
                    location_data.sharedInstance.append_loctiondata_toary(inputdata:input_loction)
                    print("ary_들어있는 위치값 갯수:(추가한 후)")
                    print(location_data.sharedInstance.location_ary.count)
                }
                
                 //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
