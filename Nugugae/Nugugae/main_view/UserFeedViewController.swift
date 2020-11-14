//
//  UserFeedViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/14.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserFeedViewController : UIViewController, UITextFieldDelegate{
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
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
    
    
    @IBOutlet weak var search_text: UITextField!
    // id 검색 text field
    
    @IBAction func search_btn(_ sender: Any) {
        print("검색기능")
        if search_text.text!.count > 0{
            print("서칭 페이지로")
        }
        else{
            let input_alert = UIAlertController(title: "검색 ID가 비어있어요!", message: "검색하고자 하는 ID를 입력해주세요!", preferredStyle: .alert)
            let ok_btn = UIAlertAction(title: "네!", style: .default, handler: nil)
            input_alert.addAction(ok_btn)
            present(input_alert, animated: true) {
                self.search_text.becomeFirstResponder()
            }
        }
    }
    // id 검색 버튼
    override func viewDidLoad() {
        super.viewDidLoad()
        print("feed_view Start")
        print("server url : ", String(server_url))
        
        // 전처리
        self.search_text.text = ""
        self.search_text.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tfeed_view")
        
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tfeed_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tfeed_view")
        super.viewDidDisappear(true)
    }
    // 스크롤 func
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤시작")
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
