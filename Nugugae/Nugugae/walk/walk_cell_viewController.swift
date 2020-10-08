//
//  walk_cell_viewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/02.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class walk_cell_viewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    var segue_content:String = ""
    var segue_date:String = ""
    var ymd:String = ""
    var hms:String = ""
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // 외부 접속 url,ngrok
    let fix_btn_color = #colorLiteral(red: 1, green: 0.9727191329, blue: 0.8763390183, alpha: 1)
    // 컬러
    
    @IBOutlet weak var view_name_label: UILabel!
    // 상단 라벨
    
    @IBOutlet weak var content_text: UITextView!
    // 텍스트 필드
    
    @IBAction func back_btn(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    // 뒤로 가기 버튼
    
    
    @IBOutlet weak var fix_outlet: UIButton!
    // 수정 그 자체 아웃렛 변수
    @IBAction func fix_btn(_ sender: Any) {
        let fix_alert = UIAlertController(title: "수정",
                                                     message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_action = UIAlertAction(title:"OK!", style: .default){(action) in print("detail view_fix, ok누름")
            self.fix_btn_outlet.backgroundColor = self.fix_btn_color
            self.fix_btn_outlet.isEnabled = true
            // 수정버튼 컬러, 활성화
            self.content_text.isEditable = true
            self.content_text.becomeFirstResponder()
            // 커서 포커스 지정
            
            self.fix_outlet.isEnabled = false
            self.fix_outlet.setTitleColor(.white, for: .normal)
            self.fix_outlet.tintColor = UIColor.white
            // 수정 그 자체 버튼 비활성화
            // 아이콘, 텍스트 흰색으로 변경
            
            print("detail view_fix, 전처리 완료")
        }
        let fix_cancel_action = UIAlertAction(title: "cancel", style: .cancel, handler : nil)
        fix_alert.addAction(fix_cancel_action)
        fix_alert.addAction(fix_action)
        
        self.present(fix_alert, animated: true){
        }
    }
    // 수정 버튼, 동작
    
    @IBOutlet weak var fix_btn_outlet: UIButton!
    @IBAction func fix_action_btn(_ sender: Any) {
        // 텍스트 필드 테스트 출력
        let fix_update_alert = UIAlertController(title: "수정 완료!",
                                                 message: "게시물을 수정하시겠습니까?", preferredStyle: .alert)
        let fix_update_ok_action = UIAlertAction(title:"OK!", style: .default){(action) in
            print("fix_update ok btn")
            print(self.content_text.text!)
//            수정 쿼리  들어갈 곳
//
//
//
            
            self.dismiss(animated: true, completion: nil)
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
            UserDefaults.standard.set(true,forKey: "new_del_walk")
            print("local_token, new_del_walk - true")
            // 삭제 쿼리
            self.delWalkDetail(url: self.server_url+"/walk/delete") { (ids_msg) in
                print("delfunc : "+ids_msg[0])
            }
            self.dismiss(animated: true, completion: nil)
            print("detail view_fix, dismiss")
        }
        let cancel_action = UIAlertAction(title: "cancel", style: .cancel){(action) in
            print("detail view_fix, cancel")
        }
        del_alert.addAction(cancel_action)
        del_alert.addAction(del_action)
        
        self.present(del_alert, animated: true){
        }
    }
    // 삭제 버튼
    
    func date_parsing(date: String) -> (String, String){
        if (date != "null"){
            let arr = date.components(separatedBy: ["T","."])
            let endIndex = arr[0].index(before: arr[0].endIndex)
            // n번째 문자 index 구하는 법
            let index = arr[0].index(arr[0].startIndex, offsetBy: 2)
            let y_m_d = String(arr[0][index...endIndex])
            return (y_m_d, arr[1])
            
        }
        else{
            return ("","")
        }
    }// Date 전처리
    
    func getWalkDetail(url: String, completion: @escaping ([String]) -> Void) {
        
        let parameters: [String:[String]] = [
            "id":[self.user],
            "date":[self.segue_date]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids_content = [String]()
                switch response.result {
                    case .success(let value):
                        let walkJson = JSON(value)
                        // SwiftyJSON 사용
                        if (walkJson["err"]=="No item"){
                            print("!")
                            print("\(walkJson["err"])")
                        }
                        else{
                            ids_content.append("\(walkJson["content"])")
                        }
                    case .failure(let error):
                        print(error)
                }
                completion(ids_content)
                //closer 기법
            }
    }// 산책 세부 기록, 조회 api
    
    func delWalkDetail(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:[String]] = [
            "id":[self.user],
            "date":[self.segue_date]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids_content = [String]()
                switch response.result {
                    case .success(let value):
                        let walkJson = JSON(value)
                        // SwiftyJSON 사용
                        if (walkJson["err"]=="Incorrect id" ||
                            walkJson["err"]=="Incorrect date" ||
                            walkJson["err"]=="No User"){
                            print("!")
                            print("\(walkJson["err"])")
                        }
                        else if walkJson["content"]=="delete OK"{
                            ids_content.append("\(walkJson["content"])")
                        }
                    case .failure(let error):
                        print(error)
                }
                completion(ids_content)
                //closer 기법
            }
    }// 산책 세부 기록, 삭제 api
    
    func fixWalkDetail(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:[String]] = [
            "id":[self.user],
            "date":[self.segue_date]
        ]
    }// 산책 세부 기록, 수정 api
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_cell_view Start")
        print("외부접속 url : " + server_url)
        print(user)
        (ymd, hms)=date_parsing(date: segue_date)
        print("segue date : " + ymd)
        view_name_label.text = ymd
        getWalkDetail(url: server_url+"/walk/view/detail"){(ids_content) in
             print("get WalkDetail 동작")
             print(ids_content)
            self.content_text.text = ids_content[0]
        }
        self.content_text.isEditable = false
        
        self.fix_btn_outlet.isEnabled = false
        self.fix_outlet.isEnabled = true
        self.fix_btn_outlet.backgroundColor = UIColor.white
        // 수정시 버튼 비활성으로 초기화
        
        // 전처리
        
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view detail disappear")
        self.content_text.isEditable = false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
