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

class GalleryItemViewController: UIViewController {
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    var pu_pr:String = ""
    var date:String = ""
    var imgdate:String = ""
    
    let fix_btn_color = #colorLiteral(red: 1, green: 0.9727191329, blue: 0.8763390183, alpha: 1)
    // 컬러
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery item Start")
        print("인자 : ", date,imgdate,pu_pr)
        self.fix_btn_outlet.isEnabled = false
        self.fix_outlet.isEnabled = true
        self.fix_btn_outlet.backgroundColor = UIColor.white
        // 수정시 버튼 비활성으로 초기화
    }
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBOutlet weak var fix_outlet: UIButton!
    // 수정 그 자체 아웃렛 변수
    
    @IBAction func fix_btn(_ sender: Any) {
        let fix_alert = UIAlertController(title: "수정",
                                                     message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_action = UIAlertAction(title:"OK!", style: .default){(action) in print("detail view_fix, ok누름")
            self.fix_btn_outlet.backgroundColor = self.fix_btn_color
            self.fix_btn_outlet.isEnabled = true
            // 수정버튼 컬러, 활성화
//            self.content_text.isEditable = true
//            self.content_text.becomeFirstResponder()
            // 커서 포커스 지정
            
            self.fix_outlet.isEnabled = false
            self.fix_outlet.setTitleColor(.white, for: .normal)
            self.fix_outlet.tintColor = UIColor.white
            // 수정 그 자체 버튼 비활성화
            // 아이콘, 텍스트 흰색으로 변경
            
            print("fix버튼, 전처리 완료")
        }
        let fix_cancel_action = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
        fix_alert.addAction(fix_cancel_action)
        fix_alert.addAction(fix_action)
        
        self.present(fix_alert, animated: true){
        }
    }
    // 수정 버튼, 동작 액션 함수
    
    @IBOutlet weak var fix_btn_outlet: UIButton!
    @IBAction func fix_action_btn(_ sender: Any) {
        // 텍스트 필드 테스트 출력
        let fix_update_alert = UIAlertController(title: "수정 완료!",
                                                 message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_update_ok_action = UIAlertAction(title:"OK!", style: .default){(action) in
            UserDefaults.standard.set(true,forKey: "fixed_gallery")
            // 수정 로컬 토큰
            print("fix_update ok btn")
            //print(self.content_text.text!)
//            수정 쿼리  들어갈 곳
//            self.fixWalkDetail(url: self.server_url+"/walk/edit") { (ids_msg) in
//                print("fix func")
//                print(ids_msg)
//                UserDefaults.standard.set(self.content_text.text!,forKey: "fix_data")
//                self.dismiss(animated: true, completion: nil)
//            }
            
        }
        let fix_update_cancel_action = UIAlertAction(title: "cancel", style: .cancel){(action) in
            print("fix_update cancel btn")
        }
        fix_update_alert.addAction(fix_update_cancel_action)
        fix_update_alert.addAction(fix_update_ok_action)
        
        self.present(fix_update_alert, animated: true)
    }// 수정 내의 입력 완료 버튼(아웃렛 변수, 액션 함수)
    
    @IBAction func delete_btn(_ sender: Any) {
        let del_alert = UIAlertController(title: "삭제",
                                                     message: "게시물을 삭제하시겠습니까?", preferredStyle: .alert)
        let del_action = UIAlertAction(title:"OK!", style: .default){(action) in print("detail view_fix, ok누름")
            UserDefaults.standard.set(true,forKey: "deleted_gallery")
            print("local_token, deleted_gallery - true")
            // 삭제 쿼리
//            self.delWalkDetail(url: self.server_url+"/walk/delete") { (ids_msg) in
//                print("delfunc : "+ids_msg[0])
//            }
            self.dismiss(animated: true, completion: nil)
            print("Gallery item view_fix, dismiss")
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
