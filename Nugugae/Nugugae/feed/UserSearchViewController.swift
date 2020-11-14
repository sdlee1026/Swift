//
//  UserSearchViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/15.
//  Copyright © 2020 이성대. All rights reserved.
//
// feed_to_user_search_seg, UserFeedViewController -> UserSearchViewController
import UIKit
import Alamofire
import SwiftyJSON

class UserSearchViewController: UIViewController {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    var seg_search_str = ""
    // seg 인자로 받을 검색어
    
    var seg_userid:String = ""
    // seg로 보낼, 타인의 userid
    var result_id_ary:[String] = []
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    @IBOutlet weak var search_label: UILabel!
    // 화면 상단, 검색 결과 label
    @IBOutlet weak var result_table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user_search_view Start")
        print("segue data : ", seg_search_str)
        self.result_table.delegate = self
        self.result_table.dataSource = self
        
        self.search_label.text = "'" + seg_search_str + "' 에 대한 검색결과"
        searchUserData(url: server_url+"/feed/search/user") { (ids) in
            if ids[0] == "No user"{
                print("결과 없음, 결과없음 페이지 로드")
                self.result_id_ary.append("결과가 없습니다.")
            }
            self.result_table.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tuser_search_view")
        
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tuser_search_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tuser_search_view")
        super.viewDidDisappear(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "user_search_to_other_seg"{
            print("segue other_user_gallery")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? OtherUserGalleryViewController {
                rvc.seg_userid = self.seg_userid
            }
        }
    }
    
    func searchUserData(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.seg_search_str
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let userdata = JSON(value)// 응답
                    if (userdata["err"]=="No user"){
                        ids.append("\(userdata["err"])")
                    }
                    else{
                        for u_json in userdata{
                            self.result_id_ary.append("\(u_json.1["id"])")
                        }
                        print("http 완료, data : ", self.result_id_ary)
                        ids.append("Load ok")
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
        
    }// search user id, loginDB
    
}
extension UserSearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result_id_ary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_search_cell", for: indexPath) as! user_search_cell
        
        cell.userid.text = self.result_id_ary[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.rowHeight<=80){
            return 80
        }
        else{
            return tableView.rowHeight
        }
    }// 높이지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("table_cell click")
        // 작업 인덱스 저장
        print("id : ", self.result_id_ary[indexPath.row])
        if self.result_id_ary[indexPath.row] == "결과가 없습니다."{
            print("아무동작x")
        }
        else{
            print("seg -> ")
            self.seg_userid = self.result_id_ary[indexPath.row]
            self.performSegue(withIdentifier: "user_search_to_other_seg", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }// 클릭 이벤트 발생, segue 호출
    
}
