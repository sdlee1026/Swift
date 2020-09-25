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
        id_signin_text.delegate = self
        pw_signin_text.delegate = self
        email_signin_text.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func id_db_check_btn(_ sender: Any) {
        print("id중복확인 버튼")
    }
    // id 중복확인 버튼
    @IBAction func login_to_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // 이전으로 버튼
    
    @IBAction func Sign_enter_btn(_ sender: Any) {
        if ((id_signin_text.text!.count==0) ||
                (pw_signin_text.text!.count==0) || (email_signin_text.text!.count==0)
        ){
            print("빈 칸이 있습니다")
        }
        else if (id_val_token == false){
            
            print("id 중복확인 체크")
        }
        else{
            self.dismiss(animated: true, completion: nil)
            print("서버로 데이터 전송")
            print("view dismiss")
        }
        
    }
    // 회원가입 완료 버튼
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // 리턴키 델리게이트 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()//텍스트필드 비활성화
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if(textField == id_signin_text){
            let currentText = textField.text! + string
            return currentText.count <= 16
            
        }
        else if (textField == pw_signin_text){
            let currentText = textField.text! + string
            return currentText.count <= 20
        }
      return true;
    }
    // 글자제한 델리게이트 처리
}
