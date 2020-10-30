//
//  GalleryItemViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/30.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GalleryItemViewController: UIViewController {
    var keyboardShown:Bool = false // 키보드 상태 확인
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    var pu_pr:String = ""
    var date:String = ""
    var imgdate:String = ""
    
    let fix_btn_color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    // 컬러
    
    var temp_text_for_fix = ""
    // text필드 템프값
    
    var keyboardToken:Bool = false
    
    
    @IBOutlet weak var main_image: UIImageView!
    // 메인 이미지
    @IBAction func like_btn(_ sender: Any) {
        print("좋아요 누름버튼")
    }
    @IBOutlet weak var like_btn_outlet: UIButton!
    // 좋아요 버튼 액션, 아웃렛
    @IBAction func reply_btn(_ sender: Any) {
        print("댓글 버튼 누름")
    }
    
    
    @IBOutlet weak var like_text_label: UILabel!
    // ~님 외의 몇명이 좋아합니다 텍스트..
    @IBOutlet weak var userId_label: UILabel!
    @IBOutlet weak var main_text: UITextView!
    // 메인 텍스트
    @IBOutlet weak var day_label: UILabel!
    // 날짜 텍스트
    
    
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBOutlet weak var fix_outlet: UIButton!
    // 수정 그 자체 아웃렛 변수
    
    @IBAction func fix_btn(_ sender: Any) {
        let fix_alert = UIAlertController(title: "수정",
                                                     message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_action = UIAlertAction(title:"OK!", style: .default){(action) in print("detail view_fix, ok누름")
            self.fix_btn_outlet.setTitleColor(.lightGray, for: .normal)
            self.fix_btn_outlet.backgroundColor = self.fix_btn_color
            self.fix_btn_outlet.isEnabled = true
            // 수정버튼 컬러, 활성화
            self.main_text.isEditable = true
            self.temp_text_for_fix = self.main_text.text
            
            self.fix_outlet.isEnabled = false
            self.fix_outlet.setTitleColor(.white, for: .normal)
            self.fix_outlet.tintColor = UIColor.white
            // 수정 그 자체 버튼 비활성화
            // 아이콘, 텍스트 흰색으로 변경
            
            print("fix버튼, 전처리 완료")
        }
        let fix_cancel_action = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
        fix_alert.addAction(fix_cancel_action)
        fix_alert.addAction(fix_action)
        
        self.present(fix_alert, animated: true){
        }
    }
    // 수정 버튼, 동작 액션 함수
    
    @IBAction func delete_btn(_ sender: Any) {
        let del_alert = UIAlertController(title: "삭제",
                                                     message: "게시물을 삭제하시겠습니까?", preferredStyle: .alert)
        let del_action = UIAlertAction(title:"OK!", style: .default){(action) in print("deleted_gallery view_delete, ok누름")
            // 삭제 쿼리
            self.deleteGalleryData(url: self.server_url+"/gallery/delete") { (ids) in
                if ids.count != 0{
                    if ids[0] == "delete OK"{
                        UserDefaults.standard.set(true,forKey: "deleted_gallery")
                        print("local_token, deleted_gallery - true")
                        self.dismiss(animated: true, completion: nil)
                        print("Gallery item view_fix, dismiss")
                    }
                }
            }// delete 클로저
        }
        let cancel_action = UIAlertAction(title: "cancel", style: .cancel){(action) in
            print("Gallery item view_fix, cancel")
        }
        del_alert.addAction(cancel_action)
        del_alert.addAction(del_action)
        
        self.present(del_alert, animated: true){
        }
    }
    // 삭제 버튼
    @IBOutlet weak var fix_btn_outlet: UIButton!
    @IBAction func fix_action_btn(_ sender: Any) {
        
        let fix_update_alert = UIAlertController(title: "수정 완료!",
                                                 message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_update_ok_action = UIAlertAction(title:"OK!", style: .default){(action) in
            print("fix_update ok btn")
            if self.main_text.text == self.temp_text_for_fix{
                UserDefaults.standard.set(false,forKey: "fixed_gallery")
                // 수정 로컬 토큰
                self.dismiss(animated: true, completion: nil)
            }// 수정 사항이 없을 경우
            else{
                print("텍스트 뷰 변동 있었음, fix api 쿼리 필요")
                UserDefaults.standard.set(true,forKey: "fixed_gallery")
                // 수정 로컬 토큰
            }
            //print(self.content_text.text!)
//            수정 쿼리  들어갈 곳
//            self.fixWalkDetail(url: self.server_url+"/walk/edit") { (ids_msg) in
//                print("fix func")
//                print(ids_msg)
//                UserDefaults.standard.set(self.content_text.text!,forKey: "fix_data")
//                self.dismiss(animated: true, completion: nil)
//            }
            
        }
        let fix_update_cancel_action = UIAlertAction(title: "cancel", style: .cancel){(action) in
            print("fix_update cancel btn")
        }
        fix_update_alert.addAction(fix_update_cancel_action)
        fix_update_alert.addAction(fix_update_ok_action)
        
        self.present(fix_update_alert, animated: true)
    }// 수정 내의 입력 완료 버튼_맨아래 입력완료 버튼, (아웃렛 변수, 액션 함수)
    
    func loadGalleryData(url: String, completion: @escaping ([UIImage]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "date":self.date,
            "imgdate":self.imgdate
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids_image = [UIImage]()
                switch response.result{
                case .success(let value):
                    let gallerydata = JSON(value)// 응답
                    if (gallerydata["err"]=="No gallery"){
                        print("!")
                        print("\(gallerydata["err"])")
                    }
                    else{
                        if gallerydata["image05"].rawString() != Optional("null"){
                            print("이미지 db에서 로드")
                            let rawData = gallerydata["image05"].rawString()
                            let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                            print(decodedimage)

                            self.main_image.image = decodedimage
                        }
                        self.userId_label.text = self.user
                        self.main_text.text = "\(gallerydata["content"])"
                        self.day_label.text = "\(gallerydata["date"])"
                    }
                case .failure( _): break
                    
                }
                completion(ids_image)
            }
        
    }// mygallery View DB
    
    func deleteGalleryData(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "date":self.date,
            "imgdate":self.imgdate
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let gallerydata = JSON(value)// 응답
                    if (gallerydata["err"]=="No gallery"){
                        print("!")
                        print("\(gallerydata["err"])")
                    }
                    else{
                        ids.append("\(gallerydata["content"])");
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
        
    }// mygallery Delete DB

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery item Start")
        print("인자 : ", date,imgdate,pu_pr)
        self.fix_btn_outlet.isEnabled = false
        self.fix_outlet.isEnabled = true
        self.fix_btn_outlet.backgroundColor = UIColor.white
        self.fix_btn_outlet.setTitleColor(UIColor.white, for: .normal)
        
        self.main_text.delegate = self
        loadGalleryData(url: server_url+"/gallery/view") { (ids) in
            print("load, 갤러리 데이터")
        }
        // 수정시 버튼 비활성으로 초기화
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tGallery item")
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear, Gallery item, 키보드 옵저버 등록")
        registerForKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("Gallery item view detail disappear, 키보드 옵저버 등록 해제")
        unregisterForKeyboardNotifications()
        self.main_text.isEditable = false
    }
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
extension GalleryItemViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.keyboardToken = true
    }// TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        self.keyboardToken = false
    }
}
