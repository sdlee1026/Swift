//
//  NewImgViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/12.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
// metadata를 사용하기 위한 라이브러리
//
class NewImgViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    let img_picker = UIImagePickerController()
    // img picker 이미지를 선택을 더 수월하게 할 수 있게 Delegate 사용
    
    var locationManager:CLLocationManager!
    //LocationManager 선언
    var latitude: Double?
    var longitude: Double?
    //위도와 경도
    
    let now = Date()
    
    let date = DateFormatter()
    var kr:String = ""
    var img_date:String = ""

    
    
    var img_view: UIImage?
    
    @IBOutlet weak var selected_img_view: UIImageView!
    // 앨범 or 카메라에서 선택된 이미지뷰
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBOutlet weak var img_to_server_outlet: UIButton!
    @IBAction func img_to_server(_ sender: Any) {
        img_to_server_outlet.isEnabled = false
        updateImgData(url: server_url+"/gallery/upload") { (ids) in
            print(ids)
            if ids.count != 0{
                print("server to data, 비동기화 완료, dismiss")
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func new_img_btn(_ sender: Any) {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        print("New img view Start")
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        kr = date.string(from: now)
        print(now)
        print(kr)

        img_picker.delegate = self
        img_picker.sourceType = .savedPhotosAlbum
        img_picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? Optional(["public.image", "public.movie"])!
        
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


        // 이미지 피커 딜리게이터 사용
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear)\tNew img View")
        let dialog = UIAlertController(title: "주의", message: "일부 기능이 동작하지 않습니다. [설정] 에서 허용할 수 있습니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                dialog.addAction(action)
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                    if response {
                        print("카메라 권한 ok")
                        //권한 획득시 실행될 명령
                    } else {
                        print("카메라 권한 no")
                        self.present(dialog, animated: true, completion: nil)
                    }
                }
        let PHP_status = PHPhotoLibrary.authorizationStatus()
        if PHP_status == .authorized{
            print("앨범 권한 ok")
        }
        else if PHP_status == .denied{
            print("앨범 권한 no, setAuth")
            self.present(dialog, animated: true, completion: nil)
        }
        else if PHP_status == .notDetermined{
            print("앨범 권한 no, 아직 미정된 경우")
        }
        

        let status = CLLocationManager.authorizationStatus()

        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            print("위치권한 no")
            self.present(dialog, animated: true, completion: nil)
        }
        else if status == CLAuthorizationStatus.authorizedWhenInUse {
            print("위치권한 ok")
        }
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후\tNew img View")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("view dissapper\tNew img View")
    }
    func updateImgData(url: String, completion: @escaping ([String]) -> Void){
        let image_view = self.img_view
        let parameters: [String:String] = [
            "id":self.user,
            "ispublic":"false",
            "date":self.kr,
            "imgdate":self.img_date
        ]
        print(parameters)
        if let imageData=image_view!.jpegData(compressionQuality: 1){
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData, withName: "image", fileName: self.user+"_Q1.png", mimeType: "image/png")
                    // 원본 이미지
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
                            let writedata = JSON(value)// 응답
                            print("\(writedata["content"])")
                            ids.append("\(writedata["content"])")
                        case .failure( _): break
                    }
                    completion(ids)
                })
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
            if let coor = manager.location?.coordinate{
                 //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            }
    }
    
}
extension NewImgViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let now_location = self.locationManager.location
        // 현재 위치 세팅
        
        if let test_reffer = info[.referenceURL] as? URL{
            _ = PHAsset.fetchAssets(withALAssetURLs: [test_reffer], options: nil).firstObject
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selected_img_view.image = image
            img_view = image
            // origianl 이미지를 imageview에 넣음
        }
        
        //print(info)
        if img_picker.sourceType == .photoLibrary{
            print("phAsset 정보")
            if let test = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset{
                print("시간 정보")
                //print((test.creationDate!) as Date)
                let kr_creationDate = self.date.string(from: test.creationDate!)
                // UTC 시간으로 나옴
                self.img_date = kr_creationDate
                print(kr_creationDate)
                // KST 으로 변경
            }
            
            if let photoAsset = info[.phAsset] as? PHAsset{
                print("위치 정보")
                print(photoAsset.location?.coordinate.latitude as Any)
                print(photoAsset.location?.coordinate.longitude as Any)
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
//                        print(info[.mediaMetadata]! as! NSDictionary)
//                        let meta_dict:NSDictionary = info[.mediaMetadata] as! NSDictionary
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
                        print(now_location?.coordinate.latitude as Any)
                        print(now_location?.coordinate.longitude as Any)
                        // 사진 찍고 저장완료후, 서버로 보낼 메타데이터들 적재해야함
                        // 적재할 메타데이터 1. 사진 데이터를 찍은 시간(반드시 존재), 2. 찍은 장소값(일단은 없어도 가능, 차후에 산책기록과 비교해서 ..넣기..? ), 3. 퍼블릭or프라이빗 설정값
                        // 여러장씩 가능하게 할 것인가?.. +a 기능으로 남겨두자..
                    }
                    else{
                        print("사진 저장 에러 발생")
                    }
                })
                // 사진 찍으면 앨범 저장 2
            }
            if let PHP_video = info[.mediaURL] as? URL, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(PHP_video.path){
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: PHP_video)
                }, completionHandler: { (success, error) in
                    if success{
                        print("비디오 저장 성공")
                    }
                    else{
                        print("비디오 저장 에러 발생")
                    }
                })
                // 비디오 저장
            }
        }
        // 피커가 카메라를 기준으로 사진을 선택한 경우
        
        dismiss(animated: true, completion: nil)
    }
}
public func utcToLocale(utcDate : String, dateFormat: String) -> String
    {
        let dfFormat = DateFormatter()
        dfFormat.dateFormat = dateFormat
        dfFormat.timeZone = TimeZone(abbreviation: "UTC")
        let dtUtcDate = dfFormat.date(from: utcDate)
        
        dfFormat.timeZone = TimeZone.current
        dfFormat.dateFormat = dateFormat
        return dfFormat.string(from: dtUtcDate!)
    }
// UIImagePickerControllerDelegate의 delegate 속성은 UIImagePickerControllerDelegate와 UINavigationControllerDelegate 프로토콜을 모두 구현하는 객체로 정의되어있다.

// (위에서 해준 picker.delegate =  self) self를  picker.delegate에 할당하려면 self는 UINavigationControllerDelegate 타입이어야 한다.

// 지금, picker의 델리게이트를 UINavigationControllerDelegate에 위임해준 것인데, 대리자는 사용자가 이미지나 동영상을 선택하거나 picker화면을 종료할 때, 알림을 받는다.

