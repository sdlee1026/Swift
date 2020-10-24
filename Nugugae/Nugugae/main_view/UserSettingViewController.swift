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
    var temp_nickname:String = ""
    var temp_introtext:String = ""
    // 내용 변경 비교할 temp_string들
    
    @IBOutlet weak var id_label: UILabel!
    // id_label outlet
    
    @IBOutlet weak var nickname_btn_outlet: UIButton!
    // 닉네임 수정 버튼 outlet
    @IBOutlet weak var nickname_text: UITextField!
    // nickname_text outlet

    @IBOutlet weak var intro_textview: UITextView!
    // intro_textview outlet
    @IBOutlet weak var intro_btn_outlet: UIButton!
    // 자기소개 수정 버튼 outlet
    override func viewDidLoad() {
        print("UserSetting Start")
        print("user : "+user)
        super.viewDidLoad()
        
        // 서버 쿼리 보내서 정보 기입 동작.. 시간 좀 걸리는데 비동기로 해야함. 일단은
        id_label.text = user
        
        
        self.intro_textview.delegate = self
        // textview 딜리게이트
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출(view will appear), UserSetting")
        nickname_btn_outlet.setTitle("수정", for: .normal)
        intro_btn_outlet.setTitle("수정", for: .normal)
        // 자기 소개, 수정 버튼 title "수정"으로
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후(view did appear), UserSetting")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("UserSetting dissapper")
        nickname_text.isEnabled = false
        // 뷰 끝날때 수정 가능하게 되었던 라벨들 false로 다시 조정
        print("edit token : \(edit_token)")
        
        if edit_token{
            print("서버 쿼리 동기로 동작")
        }// 바뀐게 있는 경우에 서버 쿼리 전송
    }
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
        intro_btn_outlet.setTitle("확인", for: .normal)
    }
    // 자기소개 수정 버튼
    
    @IBAction func profile_img_btn(_ sender: Any) {
        print("profile_img_update btn")
    }
    // 프로필 사진 수정 버튼
    
    @IBAction func new_dogs_btn(_ sender: Any) {
        print("new_dogs_btn function!")
    }
    // 강아지 정보 추가 버튼
}
