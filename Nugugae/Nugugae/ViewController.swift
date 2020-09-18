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
        // Do any additional setup after loading the view.
        id_textfield.delegate = self
        pw_textfield.delegate = self
    }
    @IBOutlet var id_textfield: UITextField!
    @IBOutlet var pw_textfield: UITextField!
    
    @IBAction func Login_btn(_ sender: Any) {
        if (id_textfield.text!.count >= 0){
            print(id_textfield.text!)
        }
        else{
            print("x")
        }
        print(pw_textfield.text!)
    }
    
    @IBAction func SignIn_btn(_ sender: Any) {
        
    }
    
    @IBAction func SignIssue_btn(_ sender: Any) {
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

