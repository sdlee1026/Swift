//
//  LikeUserViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/14.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//gallery_like_user_seg, GalleryItemViewController -> LikeUserViewController
class LikeUserViewController: UIViewController {
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var segue_userlist:[Substring] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("like_user_view Start")
        // 전처리
        print("seg_userList : ", segue_userlist)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tlike_user_view, cell")
        
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tlike_user_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tlike_user_view")
        super.viewDidDisappear(true)
    }

}
