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
    }// 입력 완료(글쓰기)
    override func viewDidLoad() {
        print("walk_write Start")
        print("user : "+user)
        
        // 초기 0-10 오프셋 내용 불러옴
        super.viewDidLoad()
        text_view.delegate = self
        
        //textViewDidChange(text_view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
extension walk_writeController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        print(text_view.text)
//        let size = CGSize(width: view.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        textView.constraints.forEach { (constraint) in
//            if constraint.firstAttribute == .height {
//                constraint.constant = estimatedSize.height
//            }
//        }
//    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text_view.text == "입력해주세요!"{
            text_view.text = ""
            text_view.textColor = self.color_1
        }
    }
}
