//
//  UserSettingViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/16.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
class UserSettingViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    override func viewDidLoad() {
        print("UserSetting Start")
        print("user : "+user)
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear), UserSetting")
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후(view did appear), UserSetting")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("UserSetting dissapper")
    }
}
