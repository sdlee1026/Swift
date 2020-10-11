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

class NewImgViewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let img_picker = UIImagePickerController()
    // img picker 이미지를 선택을 더 수월하게 할 수 있게 Delegate 사용
    @IBOutlet weak var selected_img_view: UIImageView!
    // 앨범 or 카메라에서 선택된 이미지뷰
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
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
        present(img_picker, animated: false, completion: nil)
    }

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            img_picker.sourceType = .camera
            present(img_picker, animated: false, completion: nil)
            
        }
        else{
            print("Camera not available")
        }// 시뮬레이터로 돌릴시 오류
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("New img view Start")
        img_picker.delegate = self
        img_picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        
        
        // 이미지 피커 딜리게이터 사용
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear)\tNew img View")
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후\tNew img View")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("view dissapper\tNew img View")
    }
}
extension NewImgViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selected_img_view.image = image
            // origianl 이미지를 imageview에 넣음
            if img_picker.sourceType == .camera{
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
            }
            // 사진 찍으면 앨범 저장
            
        }
        dismiss(animated: true, completion: nil)
    }
    @objc
    func savedImage(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?){
        if let error = error{
            print(error)
            return
        }
        print("save success")
    }
    // 미디어 픽이 끝났을 때, (사진을 선택하고 무엇을 할거냐)
}
// UIImagePickerControllerDelegate의 delegate 속성은 UIImagePickerControllerDelegate와 UINavigationControllerDelegate 프로토콜을 모두 구현하는 객체로 정의되어있다.

// (위에서 해준 picker.delegate =  self) self를  picker.delegate에 할당하려면 self는 UINavigationControllerDelegate 타입이어야 한다.

// 지금, picker의 델리게이트를 UINavigationControllerDelegate에 위임해준 것인데, 대리자는 사용자가 이미지나 동영상을 선택하거나 picker화면을 종료할 때, 알림을 받는다.

