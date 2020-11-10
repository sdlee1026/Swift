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
    var seg_date:String = "" // seg로 전송 받을 데이터
    
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
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \thistory_detail_view")
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \thistory_detail_view")
    }
    // 스크롤 func
}
