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
    static var sharedInstance = walk_writeController()
    // seg date, distance 
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    let color_1 = #colorLiteral(red: 1, green: 0.7608325481, blue: 0.7623851895, alpha: 1)
    
    var seg_time = ""
    var seg_distance = ""
    
    
    @IBOutlet weak var text_view: UITextView!
    
    @IBAction func select_history_btn(_ sender: Any) {
        print("산책경로 불러오기")
    }// 산책 경로 정보 불러오기 버튼
    
    @IBOutlet weak var history_time_label: UILabel!
    
    @IBOutlet weak var history_distance_label: UILabel!
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "history_select_seg"{
            print("segue test")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? walk_history {
                rvc.start_page = "walk_writeController"
            }
        }
    }
    // segue 데이터전송시 준비
    override func viewDidLoad() {
        print("walk_write Start")
        print("user : "+user)
        
        super.viewDidLoad()
        text_view.delegate = self
        history_time_label.text = ""
        history_distance_label.text =
        ""
        // 라벨 초기화
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("walk_write_willAppear")
        print(walk_writeController.sharedInstance.seg_distance)
        print(walk_writeController.sharedInstance.seg_time)
        if walk_writeController.sharedInstance.seg_distance == ""{
            history_time_label.text = "아직 산책 경로 정보를"
            history_distance_label.text = "불러오지 않았습니다."
        }
        else{
            history_time_label.text = walk_writeController.sharedInstance.seg_time
            history_distance_label.text =
                "\( walk_writeController.sharedInstance.seg_distance.split(separator: ".")[0] ) 미터"
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func postWalkdata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "content":self.text_view.text,
            "distance":walk_writeController.sharedInstance.seg_distance,
            "time":walk_writeController.sharedInstance.seg_time,
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
