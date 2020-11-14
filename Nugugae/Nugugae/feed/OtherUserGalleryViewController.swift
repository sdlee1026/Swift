//
//  OtherUserGalleryViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/15.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
// seg : user_search_to_other_seg, UserSearchViewController -> OtherUserGalleryViewController
// seg : like_user_to_other_seg, LikeUserViewController -> OtherUserGalleryViewController
class OtherUserGalleryViewController: UIViewController {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    var seg_userid:String = ""
    // seg로 받을 userid
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    @IBOutlet weak var userid_label: UILabel!
    override func viewDidLoad() {
        print("other_user_gallery_view Start")
        print("segue data : ", seg_userid)
        userid_label.text = seg_userid
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tother_user_gallery_view")
        
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tother_user_gallery_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tother_user_gallery_view")
        super.viewDidDisappear(true)
    }
}
