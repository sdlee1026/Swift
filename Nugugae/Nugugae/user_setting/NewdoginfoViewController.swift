//
//  NewdoginfoViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class NewdoginfoViewController: UIViewController, UITextFieldDelegate{
    
    var keyboardShown:Bool = false // 키보드 상태 확인
    let server_url:String = Server_url.sharedInstance.server_url
    // url
    var keyboardToken:Bool = false
    
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // user id
    
    @IBOutlet weak var name_text: UITextField!
    // 이름 텍스트 필드 outlet
    @IBOutlet weak var age_text: UITextField!
    // 나이 텍스트 필드 outlet
    
    @IBOutlet weak var breed_text: UITextField!
    // 품종 텍스트 필드 outlet
    @IBAction func breed_text_start_action(_ sender: Any) {
       // keyboardToken = true
    }
    // 품종 텍스트필드 활성시 버튼 이벤트
    
    @IBOutlet weak var act_slider: UISlider!
    // 활동력 슬라이더
    @IBOutlet weak var social_slider: UISlider!
    // 사회성 슬라이더
    @IBOutlet weak var intro_textView: UITextView!
    // 자기소개 텍스트 뷰
    
    @IBOutlet weak var send_outlet: UIButton!
    @IBAction func send_btn(_ sender: Any) {
        self.send_outlet.isEnabled = false
        print("값들")
        print(self.act_slider.value)
        print(self.social_slider.value)
        postDoginfodata(url: server_url+"/setting/doginfo/write") { (ids) in
            if ids==["write OK"]{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 입력 완료 버튼
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    override func viewDidLoad() {
        print("UserSetting of new doginfo Start")
        super.viewDidLoad()
        act_slider.setValue(5.0, animated: true)
        social_slider.setValue(5.0, animated: true)
        name_text.becomeFirstResponder()
        intro_textView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear), UserSetting of new doginfo")
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, UserSetting of new doginfo, 키보드 옵저버 등록")
        registerForKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("dissapper, UserSetting of new doginfo, 키보드 옵저버 등록 해제")
        unregisterForKeyboardNotifications()
    }
    
    func postDoginfodata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.name_text.text!,
            "age":self.age_text.text!,
            "breed":self.breed_text.text!,
            "activity":String(self.act_slider.value),
            "Sociability":String(self.social_slider.value),
            "introduce":self.intro_textView.text!,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let writedata = JSON(value)// 응답
                        print("\(writedata["content"])")
                        ids.append("\(writedata["content"])")
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
extension NewdoginfoViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        self.keyboardToken = true
    }// TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        self.keyboardToken = false
    }
}
