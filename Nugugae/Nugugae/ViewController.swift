//
//  ViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/16.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var idmaxLen:Int = 16;
    var pwmaxLen:Int = 20;
    // id, pw 텍스트필드 입력 제한
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Login Start")
        // Do any additional setup after loading the view.
        id_textfield.delegate = self
        pw_textfield.delegate = self
    }
    @IBOutlet var id_textfield: UITextField!
    @IBOutlet var pw_textfield: UITextField!
    
    @IBAction func Login_btn(_ sender: UIButton) {
        if (id_textfield.text!.count > 0) && (pw_textfield.text!.count > 0){
            print(id_textfield.text!)
            print(pw_textfield.text!)
            // 로그인 기능 수행
            // server(db)요청
                // 로그인 실패시 다시 이 화면, 아이디 비밀번호 확인 경고창
                // 성공시 다음 화면으로 전환
            
        }
        else{
            print("id, pw not input")
            // id or pw 입력 없을 때 경고
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

