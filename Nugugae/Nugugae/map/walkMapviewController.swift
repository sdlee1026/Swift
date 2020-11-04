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

class walkMapviewController: UIViewController{
    
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    let now = Date()
    let date = DateFormatter()
    
    var start_time:String = ""
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stop_walk_btn(_ sender: Any) {
        print("stop_walk")
        location_data.sharedInstance.stop_location()
        // 딜리게이트 메모리 할당 해제, UserDefault 토큰, 서버 쿼리 처리
        
    }
    // 산책 중지 버튼
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_Map_view Start")
        
        
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 위치
        print("토큰 : ",UserDefaults.standard.string(forKey: "walk_isrunning"))
        if UserDefaults.standard.string(forKey: "walk_isrunning") == "false"{
            start_time = date.string(from: now)
            print("시작시간 : ", start_time)
            location_data.sharedInstance.init_locationManager()
            // 산책 기록을 위한 위치 데이터 수집 시작, location_data.swift에 존재
            location_data.sharedInstance.init_update()
            // 서버에 산책 로그, 현재 사용자 추적 테이블 생성
        }
        else{
            print("산책 하기! 동작은, 이미 동작중일 것")
        }
        
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
