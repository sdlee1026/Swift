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
        print("비동기 서버(DB쿼리 동작)")
        
        if (id_val_token == true){
            // 중복확인 OK!
            print("id val token true")
            let id_val_alert = UIAlertController(title: "사용 가능한 ID!",
                                                 message: "계속 입력해주세요 :)",
                                                 preferredStyle: .alert)
            let id_val_action = UIAlertAction(title:"OK!", style: .default)
            id_val_alert.addAction(id_val_action)
            self.present(id_val_alert, animated: true, completion: nil)
        }
        else{
            // 중복된 아이디
            print("id val token false")
            let id_val_alert = UIAlertController(title: "사용 불가능한 ID!",
                                                 message: "ID를 다시 입력해주세요 :)",
                                                 preferredStyle: .alert)
            let id_val_action = UIAlertAction(title:"OK!", style: .default)
            id_val_alert.addAction(id_val_action)
            self.present(id_val_alert, animated: true){
                self.id_signin_text.text = ""
            }
        }
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
            let login_textfield_alert = UIAlertController(title: "빈칸이 있어요!",
                                                      message: "빈칸을 확인해주세요!", preferredStyle: .alert)
            let login_textfield_action = UIAlertAction(title:"OK!", style: .default){(action) in
            }
            login_textfield_alert.addAction(login_textfield_action)
            self.present(login_textfield_alert, animated: true, completion: nil)
            // 빈칸 경고창
        }
        else if (id_val_token == false){
            let id_val_alert = UIAlertController(title: "ID 중복 확인해주세요!",
                                                 message: "뀨뀨",
                                                 preferredStyle: .alert)
            let id_val_action = UIAlertAction(title:"OK!", style: .default)
            id_val_alert.addAction(id_val_action)
            self.present(id_val_alert, animated: true, completion: nil)
            print("id 중복확인 체크")
        }
        else{
            let signin_success_alert = UIAlertController(title: "회원가입 완료!",
                                                        message: "감사드립니다!, 로그인 부탁드려요 :)",
                                                        preferredStyle: .alert)
            let signin_success_action = UIAlertAction(title:"OK!", style: .default, handler: {(action:UIAlertAction!) in print("ok누름")
                self.dismiss(animated: true, completion: nil)
                print("서버로 데이터 전송")
                print("view dismiss")
            })
            signin_success_alert.addAction(signin_success_action)
            self.present(signin_success_alert, animated: true, completion: nil)
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
