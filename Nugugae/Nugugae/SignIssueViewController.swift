//
//  SignIssueViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignIssueViewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    
    @IBAction func login_to_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // 이전으로 버튼
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SignIssue Start")
        // Do any additional setup after loading the view.
    }
}
