//
//  walk_writeController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/04.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class walk_writeController: UIViewController, UITextFieldDelegate{
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    let color_1 = #colorLiteral(red: 1, green: 0.7608325481, blue: 0.7623851895, alpha: 1)
    
    
    @IBOutlet weak var text_view: UITextView!
    
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBAction func write_walk_btn(_ sender: Any) {
        postWalkdata(url: server_url+"/walk/write") { (ids) in
            if ids==["write OK"]{
                self.dismiss(animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: "new_walk")
            }
        }
        
    }
    // 입력 완료(글쓰기)
    override func viewDidLoad() {
        print("walk_write Start")
        print("user : "+user)
        
        super.viewDidLoad()
        text_view.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func postWalkdata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "content":self.text_view.text
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
        
    }// user info insert DB
}
extension walk_writeController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text_view.text == "입력해주세요!"{
            text_view.text = ""
            text_view.textColor = self.color_1
        }
    }
}
