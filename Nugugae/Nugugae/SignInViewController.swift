//
//  SignInViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/24.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var id_signin_text: UITextField!
    @IBOutlet var pw_signin_text: UITextField!
    @IBOutlet var email_signin_text: UITextField!
    var id_val_token = false
    // id 중복확인 토큰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Signin Start")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func id_db_check_btn(_ sender: Any) {
        print("id중복확인 버튼")
    }
    // id 중복확인 버튼
    @IBAction func login_to_btn(_ sender: Any) {
        print("이전으로 화면 전환")
        self.dismiss(animated: true, completion: nil)
    }
    // 이전으로 버튼
    
    @IBAction func Sign_enter_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("서버로 데이터 전송")
        print("view dismiss")
        
    }
    // 회원가입 완료 버튼
    
}
