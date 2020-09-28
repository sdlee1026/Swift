//
//  MainTapBarController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class MainTapBarController: UITabBarController {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    var paramName:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("tap bar Start")
        // Do any additional setup after loading the view.
        print("외부접속 url : " + server_url)
        print("로그인 토큰 : ")
        print(UserDefaults.standard.bool(forKey: "isLoggedIn"))
//        print("유지 ID"+paramName)
        print(self.tabBarItem as Any)

    }
    // view override
}
