//
//  NearUserTrackingInfoViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/08.
//  Copyright © 2020 이성대. All rights reserved.
//

// near_user_tracking < identifier seg's, walkMap <-> NearUserTracking

import UIKit
import Alamofire
import SwiftyJSON

class NearUserTrackingInfoViewController: UIViewController {
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var tracking_user:String = ""
    // 추적할 유저의 아이디, seg 로 전송받을 것
    @IBOutlet weak var userid_label: UILabel!
    // 유저 아이디로 표시할 라벨
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로 가기 버튼
    override func viewDidLoad() {
        super.viewDidLoad()
        print("near_user_tracking_info_view Start")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tnear_user_tracking_info_view")
        self.userid_label.text = tracking_user
        // label 변경 <- User id로
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \tnear_user_tracking_info_view")
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \tnear_user_tracking_info_view")
    }
}
