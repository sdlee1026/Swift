//
//  UserSettingViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/16.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
class UserSettingViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var edit_token:Bool = false
    // 내용 수정 있는 지 확인하는 토큰
    var img_edit_token:Bool = false
    // 프로필 이미지 변화토큰
    var temp_nickname:String = ""
    var temp_introtext:String = ""
    // 내용 변경 비교할 temp_string들
    let img_picker = UIImagePickerController()
    // img picker 이미지를 선택을 더 수월하게 할 수 있게 Delegate 사용
    var img_view: UIImage?
    // 선택된 이미지
    
    @IBOutlet weak var id_label: UILabel!
    // id_label outlet
    
    @IBOutlet weak var nickname_btn_outlet: UIButton!
    // 닉네임 수정 버튼 outlet
    @IBOutlet weak var nickname_text: UITextField!
    // nickname_text outlet

    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var intro_textview: UITextView!
    // intro_textview outlet
    @IBOutlet weak var intro_btn_outlet: UIButton!
    // 자기소개 수정 버튼 outlet
    override func viewDidLoad() {
        print("UserSetting Start")
        print("user : "+user)
        // 서버 쿼리 보내서 정보 기입 동작.. 시간 좀 걸리는데 비동기로 해야함. 일단은
        id_label.text = user
        
        nickname_text.delegate = self
        
        
        img_picker.delegate = self
        img_picker.sourceType = .savedPhotosAlbum
        img_picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? Optional(["public.image"])!
        super.viewDidLoad()
        
        self.intro_textview.delegate = self
        // textview 딜리게이트
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear), UserSetting")
        nickname_btn_outlet.setTitle("수정", for: .normal)
        intro_btn_outlet.setTitle("수정", for: .normal)
        self.img_edit_token = false
        self.edit_token = false
        // 토큰 초기화
        viewUserinfodata(url: server_url+"/setting/userinfo/detail/view") { (ids) in
            print("view_user_info api")
            print("view willappear 종료, userSetting")
            
            // 개이름, 나이(개월), 품종, 활동량, 자기소개
            super.viewWillAppear(true)
            
        }
        // 자기 소개, 수정 버튼 title "수정"으로
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후(view did appear), UserSetting")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("view (사라질 것이다)will disappear, UserSetting")
        print("edit token : \(edit_token)")
        
        if edit_token{
            print("서버 쿼리 동기로 동작")
            if img_edit_token{
                // 이미지 변경 있는 경우
                postUserinfodataImg(url: server_url+"/setting/userinfo/detail/updateimg") { (ids) in
                    print(ids)
                }
            }
            else{
                // 이미지 변경 없는 경우
                postUserinfodata(url: server_url+"/setting/userinfo/detail/update") { (ids) in
                    print(ids)
                }
            }
        }// 바뀐게 있는 경우에 서버 쿼리 전송
        super.viewWillDisappear(true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("UserSetting dissapper")
        nickname_text.isEnabled = false
        intro_textview.isEditable = false
        // 뷰 끝날때 수정 가능하게 되었던 라벨들 false로 다시 조정
    }
    func viewUserinfodata(url: String, completion: @escaping ([Any]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [Any]()
                switch response.result{
                    case .success(let value):
                        let viewdata = JSON(value)// 응답
                        self.nickname_text.text = viewdata["nickname"].string!
                        self.intro_textview.text = viewdata["introduce"].string!
                        //print(viewdata["image"].rawString())
                        if viewdata["image"].rawString() != Optional("null"){
                            print("이미지 db에서 로드")
                            let rawData = viewdata["image"].rawString()
                            let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                            print(decodedimage)
                            self.profile_img.image = decodedimage
                        }
                        
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// user info view DB
    
    func postUserinfodata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "nickname":self.nickname_text.text!,
            "introduce":self.intro_textview.text!,
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
        
    }// dog info write DB, 이미지 미포함
    
    func postUserinfodataImg(url: String, completion: @escaping ([String]) -> Void){
        let image_view = self.img_view
        let parameters: [String:String] = [
            "id":self.user,
            "nickname":self.nickname_text.text!,
            "introduce":self.intro_textview.text!,
        ]
        if let imageData=image_view!.jpegData(compressionQuality: 0.5){
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData, withName: "image",
                        fileName:self.user+"_Q5.png",
                        mimeType: "image/png")
                    // 50% 이미지
                    multipartFormData.append(
                        (image_view?.jpegData(compressionQuality: 0.25))!,
                        withName: "image05",
                        fileName: self.user+"_Q25.png",
                        mimeType: "image/png")
                    // 25% 이미지
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                    // parameter form 적재
                    
                },to: url).responseJSON(completionHandler: { (response) in
                    var ids = [String]()
                    switch response.result{
                        case .success(let value):
                            let writedata = JSON(value)// 응답
                            print("\(writedata["content"])")
                            ids.append("\(writedata["content"])")
                        case .failure( _): break
                    }
                    completion(ids)
                })
        }
        
    }// dog info view DB, 이미지 포함
    
    @IBAction func logout_btn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userId")
        print("로그아웃 버튼 클릭")
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            guard let mainVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                fatalError("Could not instantiate HomeVC!")
            }
            self.view.window?.rootViewController = mainVC
            self.view.window?.makeKeyAndVisible()
            
        })//현재 윈도우에 root뷰 컨트롤러에 접근, 하위 뷰 삭제, main 뷰로 화면 전환
        // self.view.window?.rootViewController = mainVC 메인 뷰컨트롤러로 새롭게 설정
        // ScencDelegate
    }
    // 로그 아웃 버튼
    
    
    @IBAction func nickname_update_btn(_ sender: Any) {
        if(nickname_btn_outlet.titleLabel?.text == "수정"){        nickname_btn_outlet.setTitle("확인", for: .normal)
            nickname_text.isEnabled = true
            // 버튼 라벨 바꾸고, 라벨 입력 가능하게끔 변경
            temp_nickname = nickname_text.text!
            // 라벨에 있던 과거 텍스트, 수정 토큰을 위해 임시 변수 저장
            nickname_text.becomeFirstResponder()
            // 키보드 포커스, 이쪽으로 이동시킴.. 입력 유도
        }
        // 눌렀을 때, 수정 버튼 일 시에
        else{
            nickname_btn_outlet.setTitle("수정", for: .normal)
            if (temp_nickname != nickname_text.text){
                // 변경이 있었을 경우, edit_token true로
                edit_token = true
            }
            nickname_text.isEnabled = false
        }
        // 눌렀을 때, 확인 버튼 일 시에
    }
    // 닉네임 수정 버튼
    
    @IBAction func intro_update_btn(_ sender: Any) {
        if(intro_btn_outlet.titleLabel?.text == "수정"){
            intro_btn_outlet.setTitle("확인", for: .normal)
            intro_textview.isEditable = true
            temp_introtext = intro_textview.text!
            intro_textview.becomeFirstResponder()
        }
        else{
            intro_btn_outlet.setTitle("수정", for: .normal)
            if (temp_introtext != intro_textview.text){
                edit_token = true
            }
            intro_textview.isEditable = false
        }
        
    }
    // 자기소개 수정 버튼
    
    @IBAction func profile_img_btn(_ sender: Any) {
        print("profile_img_update btn")
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
    }
    // 프로필 사진 수정 버튼
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
    
    @IBAction func new_dogs_btn(_ sender: Any) {
        print("new_dogs_btn function!")
    }
    // 강아지 정보 추가 버튼
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }// 키보드 다른곳 클릭
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()//텍스트필드 비활성화
        return true
    }// 엔터버튼 클릭시..
}
extension UserSettingViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profile_img.image = image
            img_view = image
            // origianl 이미지를 imageview에 넣음
        }
        if img_picker.sourceType == .camera
        {
            if let PHP_image = info[.originalImage] as? UIImage{
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: PHP_image)
                }, completionHandler: { (success, error) in
                    if success{
                        print("사진 저장 성공")
                    }
                    else{
                        print("사진 저장 에러 발생")
                    }
                })
            }
        }
        // 피커가 카메라를 기준으로 사진을 선택한 경우
        self.img_edit_token = true
        self.edit_token = true
        // 내용, 이미지 체인지 토큰 true로
        dismiss(animated: true, completion: nil)
    }//이미지 피커 종료
    
}

