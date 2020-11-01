//
//  UserMapViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/01.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
class UserMapViewController:UIViewController, CLLocationManagerDelegate{
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Map_view Start")
        
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
        
        // 수정시 버튼 비활성으로 초기화
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tMap_view")
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, Map_view")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, Map_view")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
            if let coor = manager.location?.coordinate{
                 //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
