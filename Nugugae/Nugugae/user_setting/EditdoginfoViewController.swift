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
    var dogname:String = "ㅁ"
    // 인자로 전해받을 것
    
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    @IBAction func send_btn(_ sender: Any) {
        // 수정 발생 api
        postDoginfodata(url: server_url+"/setting/doginfo/detail/update") { (ids) in
            print(ids)
        }
        self.dismiss(animated: true, completion: nil)
    }// 입력완료
    
    @IBOutlet weak var name_text: UITextField!
    // 이름 텍스트
    
    @IBOutlet weak var age_text: UITextField!
    // 나이 텍스트
    @IBOutlet weak var breed_text: UITextField!
    // 품종 텍스트
    @IBAction func breed_action(_ sender: Any) {
//        self.keyboardToken = true
        // 키보드 위로 올리기
    }
    // 품종 칸 입력 시작시, 액션
    @IBOutlet weak var activity_slider: UISlider!
    // 활동력 슬라이더
    @IBOutlet weak var intro_text: UITextView!
    // 자기소개 텍스트
    override func viewDidLoad() {
        print("UserSetting of edit doginfo Start")
        intro_text.delegate = self
        
        viewDoginfodata(url: server_url+"/setting/doginfo/detail/view") { (ids) in
            print(ids)
            self.name_text.text = ids[0] as? String
            let temp_int:String = "\(ids[1])"
            self.age_text.text = temp_int
            self.breed_text.text = ids[2] as? String
            self.activity_slider.setValue(ids[3] as! Float, animated: true)
            self.intro_text.text = ids[4] as? String
            // 개이름, 나이(개월), 품종, 활동량, 자기소개
            super.viewDidLoad()
            
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
    func viewDoginfodata(url: String, completion: @escaping ([Any]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.dogname,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [Any]()
                switch response.result{
                    case .success(let value):
                        let viewdata = JSON(value)// 응답
                        ids.append(viewdata["dogname"].string!)
                        ids.append(viewdata["age"].int!)
                        ids.append(viewdata["breed"].string!)
                        ids.append(viewdata["activity"].float!)
                        ids.append(viewdata["introduce"].string!)
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// dog info view DB
    
    func postDoginfodata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.dogname,
            "age":self.age_text.text!,
            "breed":self.breed_text.text!,
            "activity":String(self.activity_slider.value),
            "introduce":self.intro_text.text!,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let writedata = JSON(value)// 응답
                        print(writedata)
                        ids.append("\(writedata[0])")
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// dog info view DB
    
    
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
extension EditdoginfoViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.keyboardToken = true
    }// TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        self.keyboardToken = false
    }
}

