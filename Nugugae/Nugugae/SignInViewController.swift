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
    var check_str = [String]()
    var id_val_token = false
    // id 중복확인 토큰
    var verified_id = ""
    // 검증된 아이디
    
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
        getIDToken(url: "http://localhost:3000/users/check") { (ids) in
            print("checking\(ids)")
            if (ids[0] == "Id validation ok"){
                self.check_str = ids
                self.verified_id = self.id_signin_text.text!
                print("토큰 스트링 : \(self.check_str)")
                // 사용 가능한 아이디
                print("id val token true, 승인된 ID : \(self.verified_id)")
                let id_val_alert = UIAlertController(title: "사용 가능한 ID!",
                                                     message: "계속 입력해주세요 :)",
                                                     preferredStyle: .alert)
                let id_val_action = UIAlertAction(title:"OK!", style: .default)
                id_val_alert.addAction(id_val_action)
                self.present(id_val_alert, animated: true, completion: nil)
            }
            else{
                print("id val token false")
                let id_val_alert = UIAlertController(title: "사용 불가능한 ID!",
                                                     message: "ID를 다시 입력해주세요 :)",
                                                     preferredStyle: .alert)
                let id_val_action = UIAlertAction(title:"OK!", style: .default)
                id_val_alert.addAction(id_val_action)
                self.present(id_val_alert, animated: true){
                    self.id_signin_text.text = ""
                }
                
                // 사용 불가함
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
        else if (check_str.count==0){
            let id_val_alert = UIAlertController(title: "ID 중복 확인해주세요!",
                                                 message: "이미 있는 ID로는 회원가입 할 수 없어요 :(",
                                                 preferredStyle: .alert)
            let id_val_action = UIAlertAction(title:"OK!", style: .default)
            id_val_alert.addAction(id_val_action)
            self.present(id_val_alert, animated: true, completion: nil)
            print("id 중복확인 체크")
        }
        else if (id_signin_text.text! != verified_id){
            let id_val_alert = UIAlertController(title: "중복확인을 다시해주세요!",
                                                 message: "중복확인된 아이디만 사용 가능합니다 :(",
                                                 preferredStyle: .alert)
            let id_val_action = UIAlertAction(title:"OK!", style: .default)
            id_val_alert.addAction(id_val_action)
            self.present(id_val_alert, animated: true, completion: nil)
            print("id 중복 확인 후, 변경 생긴 경우")
        }
        else{
            print("서버로 데이터 전송")
            postUserInfo(url: "http://localhost:3000/users") { (ids) in
                if (ids.count == 0){
                    print("Server error")
                    // 서버에러 function(Server error) 차후에 추가 기능
                }
                else if (ids[0]==self.verified_id){
                    print("Sign in \(ids[0])")
                    let signin_success_alert = UIAlertController(title: "회원가입 완료!",
                                                                 message: "감사드립니다!, 로그인 부탁드려요 :)\nID:\(self.verified_id), pw:\(self.pw_signin_text.text!)",
                                                                preferredStyle: .alert)
                    let signin_success_action = UIAlertAction(title:"OK!", style: .default, handler: {(action:UIAlertAction!) in print("ok누름")
                        self.dismiss(animated: true, completion: nil)
                        print("view dismiss")
                    })
                    signin_success_alert.addAction(signin_success_action)
                    self.present(signin_success_alert, animated: true, completion: nil)
                }
            }
        }
        
    }// 회원가입 완료 버튼
    
    func getIDToken(url: String, completion: @escaping ([String]) -> Void) {
        
        let parameters: [String:[String]] = [
            "id":[self.id_signin_text.text!]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids = [String]()
                switch response.result {
                    case .success(let value):
                        let val_json = JSON(value)
                        // SwiftyJSON 사용
                        ids.append("Id validation \(val_json["content"])")
                        
                    case .failure(let error):
                        print("error:\(error)")
                }
                completion(ids)
                //closer 기법
            }
    }// id 중복 체크
    func postUserInfo(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.id_signin_text.text!,
            "pw":self.pw_signin_text.text!,
            "email":self.email_signin_text.text!
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let userInfo_json = JSON(value)// 응답
                        ids.append("\(userInfo_json["id"])")
                    case .failure(let error): print("error:\(error)")
                }
                completion(ids)
            }
        
    }// user info insert DB
    
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
