//
//  walkHistoryViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/09.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NMapsMap

class walkHistoryViewController:UIViewController{
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // 뒤로가기 버튼
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_history_view Start")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\twalk_history_view")
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \twalk_history_view")
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \twalk_history_view")
    }
    
}
