//
//  UserGalleryViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserGalleryViewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserGallery Start")
        // Do any additional setup after loading the view.
    }
}
