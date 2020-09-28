//
//  UserLogViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserLogViewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    @IBAction func logoout_btn(_ sender: Any) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UserLog Start")
        print("user : \(String(describing: UserDefaults.standard.string(forKey: "userId")))")
        
        // Do any additional setup after loading the view.
    }
    
}
extension UIButton
{
    func setUpLayer(sampleButton: UIButton?) {
        sampleButton!.setTitle("GET STARTED", for: UIControl.State.normal)
        sampleButton?.tintColor =  UIColor.white
     sampleButton!.frame = CGRect(x:50, y:500, width:170, height:40)
     sampleButton!.layer.borderWidth = 1.0
        sampleButton!.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
     sampleButton!.layer.cornerRadius = 5.0

     sampleButton!.layer.shadowRadius =  3.0
        sampleButton!.layer.shadowColor =  UIColor.white.cgColor
     sampleButton!.layer.shadowOpacity =  0.3
    }

}
