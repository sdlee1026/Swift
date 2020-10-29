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
import Photos
class EditdoginfoViewController: UIViewController, UITextFieldDelegate{
    var keyboardShown:Bool = false // 키보드 상태 확인
    let server_url:String = Server_url.sharedInstance.server_url
    // url
    var keyboardToken:Bool = false
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // user id
    var dogname:String = ""
    // 인자로 전해받을 것
    
    let img_picker = UIImagePickerController()
    // img picker 이미지를 선택을 더 수월하게 할 수 있게 Delegate 사용
    var img_view: UIImage?
    // 선택된 이미지
    var img_change_token:Bool = false
    // 이미지 바뀌는 토큰
    @IBAction func new_image_btn(_ sender: Any) {
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
    // 새 이미지 누르는 버튼
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
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    @IBAction func delete_btn(_ sender: Any) {
        let del_alert = UIAlertController(title: "삭제!", message: "강아지 정보를 삭제하시겠습니까?", preferredStyle: .alert)
        let del_action =  UIAlertAction(title: "OK", style: .default) { (action) in
            // delete func
            self.delDoginfodata(url: self.server_url+"/setting/doginfo/detail/delete") { (ids) in
                print(ids)
                if ids.count != 0 && ids[0] as! String == "delete OK"{
                    UserDefaults.standard.set(true, forKey: "new_del_dogtable")
                    // local 벨류 설정
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        let cancel = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        del_alert.addAction(del_action)
        del_alert.addAction(cancel)
        
        present(del_alert, animated: true, completion: nil)
    }// 삭제버튼 동작
    @IBOutlet weak var send_outlet: UIButton!
    @IBAction func send_btn(_ sender: Any) {
        // 수정 발생 api
        self.send_outlet.isEnabled = false
        if img_change_token == false{
            print("이미지 포함x, 수정 api")
            postDoginfodata(url: server_url+"/setting/doginfo/detail/update") { (ids) in
                print(ids)
                if ids[0].count != 0 {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }// 이미지 변경 없었을 경우
        else{
            print("이미지 포함, 수정 api")
            postDoginfodataImg(url: server_url+"/setting/doginfo/detail/updateimg"){ (ids) in
                print(ids)
                if ids[0].count != 0 {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
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
    @IBOutlet weak var image_profile: UIImageView!
    // 프로필 이미지
    
    override func viewDidLoad() {
        print("UserSetting of edit doginfo Start")
        print("개 이름 : ",dogname)
        intro_text.delegate = self
        
        img_picker.delegate = self
        img_picker.sourceType = .savedPhotosAlbum
        img_picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? Optional(["public.image", "public.movie"])!
        
        viewDoginfodata(url: server_url+"/setting/doginfo/detail/view") { (ids) in
            print(ids)
            
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
                        self.name_text.text = viewdata["dogname"].string!
                        let temp_int:String = "\(viewdata["age"])"
                        self.age_text.text = temp_int
                        self.breed_text.text = viewdata["breed"].string!
                        self.activity_slider.setValue(viewdata["activity"].float! , animated: true)
                        self.intro_text.text = viewdata["introduce"].string!
                        //print(viewdata["image"].rawString())
                        if viewdata["image"].rawString() != Optional("null"){
                            print("이미지 db에서 로드")
                            let rawData = viewdata["image"].rawString()
                            let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                            print(decodedimage)

                            self.image_profile.image = decodedimage
                        }
                        
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
                        print("\(writedata["content"])")
                        ids.append("\(writedata["content"])")
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// dog info write DB, 이미지 미포함
    func postDoginfodataImg(url: String, completion: @escaping ([String]) -> Void){
        let image_view = self.img_view
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.dogname,
            "age":self.age_text.text!,
            "breed":self.breed_text.text!,
            "activity":String(self.activity_slider.value),
            "introduce":self.intro_text.text!,
        ]
        if let imageData=image_view!.jpegData(compressionQuality: 0.5){
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        imageData, withName: "image",
                        fileName:self.user+self.name_text.text!+"_Q5.png",
                        mimeType: "image/png")
                    // 50% 이미지
                    multipartFormData.append(
                        (image_view?.jpegData(compressionQuality: 0.25))!,
                        withName: "image05",
                        fileName: self.user+self.name_text.text!+"_Q25.png",
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
    
    func delDoginfodata(url: String, completion: @escaping ([Any]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "dogname":self.dogname,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [Any]()
                switch response.result{
                    case .success(let value):
                        let deldata = JSON(value)// 응답
                        ids.append("\(deldata["content"])")
                        
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
extension EditdoginfoViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image_profile.image = image
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
        self.img_change_token = true
        // 이미지 체인지 토큰 true로
        dismiss(animated: true, completion: nil)
    }//이미지 피커 종료
    
}

