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
    @IBAction func back_btn(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
    }
    // 뒤로 가기 버튼
    
    @IBAction func fix_btn(_ sender: Any) {
    }
    // 수정 버튼
    @IBAction func delete_btn(_ sender: Any) {
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
    }
    // Date 전처리
    
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
    }// 산책 세부 기록 api
    
    @IBOutlet weak var view_name_label: UILabel!
    // 상단 라벨
    
    @IBOutlet weak var content_text: UITextView!
    // 텍스트 필드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_cell_view Start")
        print("외부접속 url : " + server_url)
        (ymd, hms)=date_parsing(date: segue_date)
        print("segue date : " + ymd)
        view_name_label.text = ymd
        getWalkDetail(url: server_url+"/walk/view/detail"){(ids_content) in
             print("get WalkDetail 동작")
             print(ids_content)
            self.content_text.text = ids_content[0]
        }
        
        // 전처리
        
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
