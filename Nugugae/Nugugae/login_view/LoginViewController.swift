//
//  LoginViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/16.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class LoginViewController: UIViewController, UITextFieldDelegate {
    var idmaxLen:Int = 16;
    var pwmaxLen:Int = 20;
    // id, pw 텍스트필드 입력 제한
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    var sceneDelegate: SceneDelegate? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate else { return nil }
             return delegate
        }
    @IBOutlet var id_textfield: UITextField!
    @IBOutlet var pw_textfield: UITextField!
    var login_check: Bool = false
    var login_id: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Login Start")
        // Do any additional setup after loading the view.
        id_textfield?.delegate = self
        pw_textfield?.delegate = self
        print("외부접속 url : " + server_url)

    }
    // view override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginTomain"{
            print("segue test")
            print("loginview's username : \(self.login_id)")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? MainTapBarController {
                rvc.paramName = self.id_textfield.text
            }
        }
    }
    // segue override
    @IBAction func Login_btn(_ sender: UIButton) {
        // Alamofire 비동기 통신 - HTTP POST
        if (id_textfield.text!.count > 0) && (pw_textfield.text!.count > 0){
            getLoginToken(url: server_url+"/login"){(ids) in
                print("ID's received: \(ids)")
                if (ids.count != 0){
                    self.login_id=ids
                    print("\(self.login_id)로그인 성공!")
                    print("\(self.login_check), login token")
                    
                    // login -> tableview 화면 전환 동작
                    // segue 인자-> login_id
                    // custom segue
                    //self.performSegue(withIdentifier: "loginTomain", sender: self)
                    // 화면 전환
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(self.id_textfield.text, forKey: "userId")
                    print(UserDefaults.standard.string(forKey: "userId") as Any)
                    
                    self.view.window?.rootViewController?.dismiss(animated: false, completion: {
                        guard let mainVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MainTapBarController") as? MainTapBarController else {
                            fatalError("Could not instantiate HomeVC!")
                        }
                        self.view.window?.rootViewController = mainVC
                        self.view.window?.makeKeyAndVisible()
                        
                    })//현재 윈도우에 root뷰 컨트롤러에 접근, 하위 뷰 삭제, main 뷰로 화면 전환
                    // self.view.window?.rootViewController = mainVC 메인 뷰컨트롤러로 새롭게 설정
                    // ScencDelegate 18line 참조


                }// 로그인 한 아이디 저장, 로그인 환영 메세지, 창 전환
                else{
                    // 로그인 실패, 아이디 비밀번호 확인 경고창
                    print("로그인 실패, 아이디 비밀번호 확인 경고")
                    print("\(self.login_check), login token")
                    let login_false_alert = UIAlertController(title: "로그인이 실패했어요..",
                                                                   message: "아이디와 비밀번호를 확인해주세요!", preferredStyle: .alert)
                    let login_false_action = UIAlertAction(title:"OK!", style: .default){(action) in
                        // alert from action _ 클로저 동작
                    }
                
                    login_false_alert.addAction(login_false_action)
                    
                    self.present(login_false_alert, animated: true){
                        self.id_textfield.text = ""
                        self.pw_textfield.text = ""
                    }
                }
            }
        }
        else{
            print("id, pw not input")
            let login_textfield_alert = UIAlertController(title: "빈칸이 있어요!",
                                                         message: "아이디와 비밀번호를 입력해주세요!", preferredStyle: .alert)
            let login_textfield_action = UIAlertAction(title:"OK!", style: .default){(action) in
            }
            login_textfield_alert.addAction(login_textfield_action)
            
            self.present(login_textfield_alert, animated: true){
                self.id_textfield.text = ""
                self.pw_textfield.text = ""
            }
            // id or pw 입력 없을 때 경고
        }
    
    }

    // 로그인 (server(DB)<-> view_ http.POST, 성공시 ids안에 아이디 저장_closer기법)
    func getLoginToken(url: String, completion: @escaping ([String]) -> Void) {
        
        let parameters: [String:[String]] = [
            "id":[self.id_textfield.text!],
            "pw":[self.pw_textfield.text!]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids = [String]()
                switch response.result {
                    case .success(let value):
                        let loginjson = JSON(value)
                        // SwiftyJSON 사용
                        print("JSON:\(loginjson["content"])")
                        if (loginjson["content"] == "login OK!"){
                            self.login_check=true;
                            //login_token true
                            ids.append(self.id_textfield.text!)
                        }
                        else{
                            self.login_check=false;
                            //login_token false
                        }
                    case .failure(let error):
                        print(error)
                }
                completion(ids)
                //closer 기법
                
            }
        
    }
    
    @IBAction func SignIn_btn(_ sender: UIButton) {
        print("SingIn Btn click")
        
        // 회원가입 폼으로 이동
    }
    
    @IBAction func SignIssue_btn(_ sender: UIButton) {
        print("SignIssue Btn click")
        // 계정 이슈(아이디 or 비밀번호 이슈 폼 이동)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // 리턴키 델리게이트 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()//텍스트필드 비활성화
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if(textField == id_textfield){
            let currentText = textField.text! + string
            return currentText.count <= idmaxLen
            
        }
        else if (textField == pw_textfield){
            let currentText = textField.text! + string
            return currentText.count <= pwmaxLen
        }
      return true;
    }
    // 글자제한 델리게이트 처리
    

}

