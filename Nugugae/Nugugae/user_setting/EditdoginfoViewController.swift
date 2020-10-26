//
//  EditdoginfoViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class EditdoginfoViewController: UIViewController, UITextFieldDelegate{
    var keyboardShown:Bool = false // 키보드 상태 확인
    let server_url:String = Server_url.sharedInstance.server_url
    // url
    var keyboardToken:Bool = false
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // user id
    var dogname:String = "뽀뽀"
    // 인자로 전해받을 것
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    @IBAction func send_btn(_ sender: Any) {
        // 수정 발생 api
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        print("UserSetting of edit doginfo Start")
        super.viewDidLoad()
        postDoginfodata(url: server_url+"/setting/doginfo/detail/view") { (ids) in
            print(ids)
            // 개이름, 나이(개월), 품종, 활동량, 자기소개
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear), UserSetting of edit doginfo")
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, UserSetting of edit doginfo, 키보드 옵저버 등록")
        registerForKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("dissapper, UserSetting of edit doginfo, 키보드 옵저버 등록 해제")
        unregisterForKeyboardNotifications()
    }
    func postDoginfodata(url: String, completion: @escaping ([Any]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.dogname,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [Any]()
                switch response.result{
                    case .success(let value):
                        var viewdata = JSON(value)// 응답
                        ids.append(viewdata["dogname"])
                        ids.append(viewdata["age"])
                        ids.append(viewdata["breed"])
                        ids.append(viewdata["activity"])
                        ids.append(viewdata["introduce"])
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// dog info insert DB
    
    
    func registerForKeyboardNotifications() {
        // 옵저버 등록
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    func unregisterForKeyboardNotifications() {
      // 옵저버 등록 해제
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 키보드 사이즈를 받아옴
            if keyboardSize.height == 0.0 || keyboardShown == true {
                return
            }
            if (keyboardToken == true){
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height) })
            }
        }
    }
    @objc func keyboardWillHide(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.transform = .identity

        }
        keyboardToken=false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
