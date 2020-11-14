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
import Photos

class GalleryItemViewController: UIViewController, CLLocationManagerDelegate {
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
    var temp_pr_pu = -1
    
    let img_picker = UIImagePickerController()
    // img picker 이미지를 선택을 더 수월하게 할 수 있게 Delegate 사용
    var img_change_token:Bool = false
    // 이미지 변경 체크 토큰
    
    var locationManager:CLLocationManager!
    // LocationManager 선언
    var latitude: Double?
    var longitude: Double?
    // 위도와 경도
    var img_latitude: Double = -1
    var img_longitude: Double = -1
    // 서버로 보내는 위도 경도 값
    
    var img_view: UIImage?
    let now = Date()
    
    let dateFormatter = DateFormatter()
    var kr:String = ""
    var img_date:String = ""
    var is_public:String = ""
    
    var pr_pu_change_token:Bool = false
    // 공개 범위 변경 체크 토큰
    @IBOutlet weak var public_private: UISegmentedControl!
    
    var keyboardToken:Bool = false
    // 키보드 상태 토큰
    let unlike_img = UIImage(systemName: "heart")
    let like_img = UIImage(systemName: "heart.fill")
    
    var like_user_str:String = ""
    var like_user_ary:[Substring] = []
    // 좋아요 누른 유저
    
    @IBOutlet weak var main_image: UIImageView!
    // 메인 이미지
    var like_check = false
    // 좋아요 토큰
    @IBAction func like_btn(_ sender: Any) {
        if like_btn_outlet.image(for: .normal) == unlike_img{
            print("unlike 상태일때 클릭")
            self.like_btn_outlet.setImage(self.like_img, for: .normal)
            self.like_check = true
            // 좋아요
            
            self.like_user_ary.append(Substring(self.user))
            self.like_text_btn.isEnabled = true
            // 버튼 선택 가능
            if self.like_user_ary.count == 0{
                print("좋아하는 사람 없음, 그냥 넘김")
                self.like_text_btn.setTitle("", for: .normal)
            }
            else if self.like_user_ary.count == 1{
                if String(self.like_user_ary[0]) == self.user{
                    self.like_text_btn.isEnabled = false
                    // 자기 자신만 좋아할 때는 버튼 비활성화
                }
                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님이 좋아합니다", for: .normal)
            }// 한명 있을 경우
            else if self.like_user_ary.contains(Substring(self.user)){
                self.like_text_btn.setTitle(String(self.user)+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
            }// 자신이 포함되있는 경우
            else{
                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
            }// 자신 포함x, 다른 여러명이 좋아하는 경우
            // ~외의 몇명이 좋아합니다 btn text setting
        }
        else{
            print("like 상태일때 클릭")
            self.like_btn_outlet.setImage(self.unlike_img, for: .normal)
            self.like_check = false
            // 좋아요 해제(안좋아요)
            
            if let index = self.like_user_ary.firstIndex(of: Substring(self.user)) {
                self.like_user_ary.remove(at: index)
            }
            if self.like_user_ary.count == 0{
                self.like_text_btn.isEnabled = false // 버튼 선택 비활성화
                print("좋아하는 사람 없음, 그냥 넘김, 버튼 선택 불가능으로")
                self.like_text_btn.setTitle("", for: .normal)
            }
            else if self.like_user_ary.count == 1{
                if String(self.like_user_ary[0]) == self.user{
                    self.like_text_btn.isEnabled = false
                    // 자기 자신만 좋아할 때는 버튼 비활성화
                }
                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님이 좋아합니다", for: .normal)
            }// 한명 있을 경우
            else if self.like_user_ary.contains(Substring(self.user)){
                self.like_text_btn.setTitle(String(self.user)+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
            }// 자신이 포함되있는 경우
            else{
                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
            }// 자신 포함x, 다른 여러명이 좋아하는 경우
            // ~외의 몇명이 좋아합니다 label text setting
        }
    }
    @IBOutlet weak var like_btn_outlet: UIButton!
    // 좋아요 버튼 액션, 아웃렛
    
    @IBAction func reply_btn(_ sender: Any) {
        print("댓글 버튼 누름")
    }
    
    
    @IBOutlet weak var like_text_btn: UIButton!
    @IBAction func like_text_btn_action(_ sender: Any) {
        print("~ 명이 좋아합니다 버튼 누름")
        performSegue(withIdentifier: "gallery_like_user_seg", sender: nil)
    }
    // ~님 외의 몇명이 좋아합니다 텍스트 버튼 액션
    
    @IBOutlet weak var userId_label: UILabel!
    @IBOutlet weak var main_text: UITextView!
    // 메인 텍스트
    @IBOutlet weak var day_label: UILabel!
    // 날짜 텍스트
    
    
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBOutlet weak var fix_outlet: UIButton!
    // 화면 상단 수정 아웃렛 변수
    
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
            
            self.public_private.isHidden = false
            self.public_private.isEnabled = true
            
            self.image_change_btn_outlet.isEnabled = true
            self.image_change_btn_outlet.setTitleColor(UIColor.black, for: .normal)
            // 사진 변경 버튼 활성화, 텍스트 흰색(기본값) -> 검은색으로 변경
            
            print("fix버튼, 전처리 완료")
        }
        let fix_cancel_action = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
        fix_alert.addAction(fix_cancel_action)
        fix_alert.addAction(fix_action)
        
        self.present(fix_alert, animated: true){
        }
    }
    // 화면 상단 수정 버튼, 동작 액션 함수
    
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
    
    @IBOutlet weak var image_change_btn_outlet: UIButton!
    @IBAction func image_change_btn(_ sender: Any) {
        print("image change btn event")
        print("photo lib call")
        let new_img_alert =  UIAlertController(title: "올릴 곳 선택", message: "원하는 방법을 선택해주세요", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        new_img_alert.addAction(library)
        new_img_alert.addAction(camera)
        new_img_alert.addAction(cancel)

        present(new_img_alert, animated: true, completion: nil)
        self.img_change_token = true
        // 이미지 체인지 토큰 true
    }
    // 사진 변경 버튼, 화면 중간
    func openLibrary(){
        img_picker.sourceType = .photoLibrary
        present(img_picker, animated: true, completion: nil)
    }
    // 앨범 선택

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            img_picker.sourceType = .camera
            present(img_picker, animated: true, completion: nil)
            
        }
        else{
            print("Camera not available")
        }// 시뮬레이터로 돌릴시 오류
    }
    // 카메라 선택
    
    @IBOutlet weak var fix_btn_outlet: UIButton!
    @IBAction func fix_action_btn(_ sender: Any) {
        
        let fix_update_alert = UIAlertController(title: "수정 완료!",
                                                 message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_update_ok_action = UIAlertAction(title:"OK!", style: .default){(action) in
            print("fix_update ok btn")
            self.fix_btn_outlet.isHidden = true;
            // 버튼 비활성화, 일단은 히든으로 해왔음
            
            if self.img_change_token == true{
                print("이미지 변동 있음")
                if self.public_private.selectedSegmentIndex == 0{
                    print("세그멘트 컨트롤 다같이 볼래요")
                    self.pu_pr = "1"
                    // public_img api
                    self.updateGalleryData_img(url: self.server_url+"/gallery/update/img/public") { (ids) in
                        print(ids)
                        UserDefaults.standard.set(true,forKey: "fixed_gallery")
                        print("업데이트 완료,local_token, fixed_gallery - true")
                        self.dismiss(animated: true, completion: nil)
                        // 수정 로컬 토큰
                    }
                }
                else{
                    print("세그멘트 컨트롤 혼자 볼래요")
                    self.pu_pr = "0"
                    // private_img api
                    self.updateGalleryData_img(url: self.server_url+"/gallery/update/img/private"){ (ids) in
                        print(ids)
                        UserDefaults.standard.set(true,forKey: "fixed_gallery")
                        print("업데이트 완료,local_token, fixed_gallery - true")
                        self.dismiss(animated: true, completion: nil)
                        // 수정 로컬 토큰
                    }
                }
                
            }
            // 이미지 변동 있었을 경우
            else{
                if (self.main_text.text == self.temp_text_for_fix)
                    && (self.temp_pr_pu != self.public_private.selectedSegmentIndex){
                    // 텍스트 변동x && 공개 범위 변동 x -> 아무것도 안바뀐 경우
                    UserDefaults.standard.set(false,forKey: "fixed_gallery")
                    // 수정 로컬 토큰
                    self.dismiss(animated: true, completion: nil)
                    print("아무것도 바뀌지 않음")
                }
                else{
                    print("이미지는 변동 x, text or public/private 변동 o")
                    if self.public_private.selectedSegmentIndex == 0{
                        print("세그멘트 컨트롤 다같이 볼래요")
                        self.pu_pr = "1"
                    }
                    else{
                        print("세그멘트 컨트롤 혼자 볼래요")
                        self.pu_pr = "0"
                    }
                    // 세그멘트 파라미터 벨류 세팅
                    self.updateGalleryData(url: self.server_url+"/gallery/update/noimg") { (ids) in
                        if ids.count != 0{
                            if ids[0] == "Update OK"{
                                UserDefaults.standard.set(true,forKey: "fixed_gallery")
                                // 수정 로컬 토큰
                                print("업데이트 완료,local_token, fixed_gallery - true")
                                self.dismiss(animated: true, completion: nil)
                                print("Gallery item view_update, dismiss")
                            }
                        }
                    }// Update_api
                }
                
            }
            // 이미지는 변동 없었을 경우
            
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
        self.like_user_str = ""
        self.like_user_ary = []
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
                        print("\(gallerydata["ispublic"])")
                        if gallerydata["ispublic"] == true{// 공개 일 경우
                            print("공개 게시물")
                            self.public_private.selectedSegmentIndex = 0
                            self.temp_pr_pu = 1
                        }
                        else{// 비공개 일 경우
                            print("비공개 게시물")
                            self.public_private.selectedSegmentIndex = 1
                            self.temp_pr_pu = 0
                        }
                        self.like_user_str += "\(gallerydata["like"])"
                        print("split user 동작")
                        if self.like_user_str.count > 0{
                            print("like_exist_user setting")
                            self.like_user_ary = self.like_user_str.split(separator: ",")
                            print("유저 리스트",self.like_user_ary)
                            if self.like_user_ary.contains(Substring(self.user)){
                                print("자기 있음")
                                self.like_btn_outlet.setImage(self.like_img, for: .normal)
                                self.like_check = true
                                // 좋아요 체크
                            }
                            self.like_text_btn.isEnabled = true
                            if self.like_user_ary.count == 0{
                                print("좋아하는 사람 없음, 그냥 넘김")
                                self.like_text_btn.isEnabled = false
                                self.like_text_btn.setTitle("", for: .normal)
                            }
                            else if self.like_user_ary.count == 1{
                                if String(self.like_user_ary[0]) == self.user{
                                    self.like_text_btn.isEnabled = false
                                    // 자기 자신만 좋아할 때는 버튼 비활성화
                                }
                                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님이 좋아합니다", for: .normal)
                            }// 한명 있을 경우
                            else if self.like_user_ary.contains(Substring(self.user)){
                                self.like_text_btn.setTitle(String(self.user)+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
                            }// 자신이 포함되있는 경우
                            else{
                                self.like_text_btn.setTitle(String(self.like_user_ary[0])+"님 외의 " + String(self.like_user_ary.count - 1) + "명이 좋아합니다", for: .normal)
                            }// 자신 포함x, 다른 여러명이 좋아하는 경우
                            // ~외의 몇명이 좋아합니다 label text setting
                        }
                        else{
                            print("like_no_user setting")
                            self.like_btn_outlet.setImage(self.unlike_img, for: .normal)
                            self.like_check = false
                            self.like_text_btn.isEnabled = false
                            // ~명 좋아합니다 버튼, 선택 불가로
                        }// 유저 아무도 없을시
                        
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

    func updateGalleryData(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "date":self.date,
            "imgdate":self.imgdate,
            "pu_pr":self.pu_pr,
            "content":self.main_text.text,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let updatedata = JSON(value)// 응답
                    if (updatedata["err"]=="Incorrect name'"){
                        print("!")
                        print("\(updatedata["err"])")
                    }
                    else{
                        ids.append("\(updatedata["content"])");
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
        
    }// mygallery update DB
    
    func updateGalleryData_img(url: String, completion: @escaping ([String]) -> Void){
        let image_view = self.img_view
        var parameters: [String:String]
        
        if self.img_longitude != -1 && self.img_latitude != -1{
            print("위치값 존재 parameter insert")
            parameters = [
                "id":self.user,
                "pu_pr":self.pu_pr,
                "date":self.date, // 게시물 자체의 날짜는 바뀌지 않으므로, 로드할때 썻던 Date그대로
                "imgdate_before": self.imgdate, // 로드할때 썻던 imgdate
                "imgdate":self.img_date, // 바뀔 메타데이터
                "content":self.main_text.text,
                "location":String(self.img_longitude)+","+String(self.img_latitude)
            ]
            
        }
        else{
            parameters = [
                "id":self.user,
                "date":self.date,// 게시물 자체의 날짜는 바뀌지 않으므로, 로드할때 썻던 Date그대로
                "imgdate_before": self.imgdate, // 로드할때 썻던 imgdate
                "imgdate":self.img_date, // 바뀔 메타데이터
                "pu_pr":self.pu_pr,
                "content":self.main_text.text,
            ]
            
        }
        print(parameters)
        if let imageData=image_view!.jpegData(compressionQuality: 1){
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData, withName: "image", fileName: self.user+"_Q1.png", mimeType: "image/png")
                    // 원본 이미지
                    multipartFormData.append((image_view?.jpegData(compressionQuality: 0.5))!, withName: "image05", fileName: self.user+"_Q05.png", mimeType: "image/png")
                    // 50% 이미지
                    multipartFormData.append((image_view?.jpegData(compressionQuality: 0.1))!, withName: "image01", fileName: self.user+"_Q01.png", mimeType: "image/png")
                    // 썸네일용 10% 이미지
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                    // parameter form 적재
                    
                },
                to: url)
                .responseJSON(completionHandler: { (response) in
                    var ids = [String]()
                    switch response.result{
                        case .success(let value):
                            let updatedata = JSON(value)// 응답
                            if (updatedata["err"]=="Incorrect name'"){
                                print("!")
                                print("\(updatedata["err"])")
                            }
                            else{
                                ids.append("\(updatedata["content"])");
                            }
                        case .failure( _): break
                    }
                    completion(ids)
                })
        }
    }// mygallery img포함 update DB
    
    func updatelike(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "date":self.date,
            "imgdate":self.imgdate,
            "like_self":String(self.like_check)
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let updatedata = JSON(value)// 응답
                    if (updatedata["err"]=="Incorrect name'"){
                        print("!")
                        print("\(updatedata["err"])")
                    }
                    else{
                        ids.append("\(updatedata["content"])");
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery item Start")
        print("인자 : ", date,imgdate,pu_pr)
        self.fix_btn_outlet.isEnabled = false
        self.fix_outlet.isEnabled = true
        self.fix_btn_outlet.backgroundColor = UIColor.white
        self.fix_btn_outlet.setTitleColor(UIColor.white, for: .normal)

        self.public_private.isHidden = true
        self.public_private.isEnabled = false
        self.main_text.delegate = self
        
        
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        kr = dateFormatter.string(from: now)
        print(now)
        print(kr)
        
        img_picker.delegate = self
        img_picker.sourceType = .savedPhotosAlbum
        img_picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? Optional(["public.image"])!
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.startUpdatingLocation()
        //위치업데이트
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        
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
        updatelike(url: server_url+"/gallery/like/update") { (ids) in
            print("좋아요 값 업데이트")
            print(ids)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gallery_like_user_seg"{
            print("segue like_user")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? LikeUserViewController {
                rvc.segue_userlist = self.like_user_ary
            }
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
            if let coor = manager.location?.coordinate{
                 //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            }
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
extension GalleryItemViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let now_location = self.locationManager.location
        // 현재 위치 세팅
        
        if let test_reffer = info[.referenceURL] as? URL{
            _ = PHAsset.fetchAssets(withALAssetURLs: [test_reffer], options: nil).firstObject
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            main_image.image = image
            img_view = image
            // origianl 이미지를 imageview에 넣음
        }
        
        //print(info)
        if img_picker.sourceType == .photoLibrary{
            print("phAsset 정보")
            if let test = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset{
                print("시간 정보")
                //print((test.creationDate!) as Date)
                let kr_creationDate = self.dateFormatter.string(from: test.creationDate!)
                // UTC 시간으로 나옴
                self.img_date = kr_creationDate
                print(kr_creationDate)
                // KST 으로 변경
            }
            
            if let photoAsset = info[.phAsset] as? PHAsset{
                if photoAsset.location?.coordinate.latitude != nil{
                    print("위치 정보")
                    self.img_latitude = (photoAsset.location?.coordinate.latitude)!
                    self.img_longitude = (photoAsset.location?.coordinate.longitude)!
                    print(img_latitude as Any)
                    print(img_longitude as Any)
                }
            }
        }
        // picker 가 앨범을 기준하여 선택한 경우
        else if img_picker.sourceType == .camera
        {
            if let PHP_image = info[.originalImage] as? UIImage{
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: PHP_image)
                    creationRequest.location = now_location
                    
                }, completionHandler: { (success, error) in
                    if success{
                        print("사진 저장 성공")
                        let meta_dict = info[.mediaMetadata] as! NSDictionary
                        let exif_dict = meta_dict["{Exif}"] as! NSDictionary
                        print("시간 정보")
                        self.img_date = exif_dict["DateTimeDigitized"] as! String
                        let dateFormatter = DateFormatter()

                        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                        let temp_date:Date = dateFormatter.date(from: self.img_date)!
                        // string -> date
                        
                        let dateFormatter1 = DateFormatter()
                        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        // date -> string
                        let dateString:String = dateFormatter1.string(from: temp_date)
                        self.img_date = dateString
                        print(self.img_date)
                        print("위치 정보")
                        self.img_latitude = (now_location?.coordinate.latitude)!
                        self.img_longitude = (now_location?.coordinate.longitude)!
                        print(self.img_latitude as Any)
                        print(self.img_longitude as Any)
                    }
                    else{
                        print("사진 저장 에러 발생")
                    }
                })
                // 사진 찍으면 앨범 저장 2
            }
        }
        // 피커가 카메라를 기준으로 사진을 선택한 경우
        
        self.img_change_token = true
        // 이미지 체인지 토큰 true로
        dismiss(animated: true, completion: nil)
    }//이미지 피커 종료
    
}
