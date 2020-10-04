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
class UserLogViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    // tabelview
    
    var isAvailable = true
    // view tabel 토큰
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    var table_content:[String] = []
    var table_date:[String] = []
    var offset = 0
    
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // query_스크롤 할때 더 불러오는 기준.. limit default 10
    
    override func viewDidLoad() {
        UserDefaults.standard.set(false,forKey: "new_walk")
        tableView.delegate = self
        tableView.dataSource = self
        print("UserLog Start")
        print("user : "+user)
        print("now offset : \(offset)")
        
        // 초기 0-10 오프셋 내용 불러옴
        super.viewDidLoad()
        Update_table()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view 호출")
        if UserDefaults.standard.bool(forKey: "new_walk"){
            print("새 게시물이 있습니다.")
            // 새 게시물 작성된 경우
            Update_table_one()
            UserDefaults.standard.set(false,forKey: "new_walk")
        }
        tableView.reloadData()
        print("now offset : \(offset)")
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("testing")
        print("now offset : \(offset)")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("dissapper")
        print("now offset : \(offset)")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤시작")
        if self.tableView.contentOffset.y > tableView.contentSize.height-tableView.bounds.size.height
            {
                if(isAvailable)
                {
                    isAvailable = false
                    offset += 10
                    // 스크롤 할때 마다 데이터 불러옴 10개
                    Update_table()
                    
                }
            tableView.reloadData()
        }
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
        isAvailable = true
        tableView.reloadData()
    }
    
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
    func getWalkcontentOne(url: String, completion: @escaping ([String],[String]) -> Void) {
        let parameters: [String:[String]] = [
            "id":[self.user]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids_content_one = [String]()
                var ids_date_one = [String]()
                switch response.result{
                case .success(let value):
                    let walkOneJson = JSON(value)
                    ids_content_one.append("\(walkOneJson["content"])")
                    ids_date_one.append("\(walkOneJson["date"])")
                case .failure(let error):
                    print(error)
                }
                completion(ids_content_one, ids_date_one)
                //closer 기법
            }
    }
//    curl -X POST '127.0.0.1:3000/walk/view/' -d id='test1001' -d offset=0
    // walktableDB (server(DB)<-> view_ http.POST, 성공시 ids안에 아이디 저장_closer기법)
    func getWalkcontent(url: String, completion: @escaping ([String],[String]) -> Void) {
        
        let parameters: [String:[String]] = [
            "id":[self.user],
            "offset":[String(offset)]
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids_content = [String]()
                var ids_date = [String]()
                switch response.result {
                    case .success(let value):
                        let walkJson = JSON(value)
                        // SwiftyJSON 사용
                        if (walkJson["err"]=="No item"){
                            print("!")
                            print("\(walkJson["err"])")
                            self.offset -= 10
                        }
                        else{
                            for w_json in walkJson{
                                // w_json.0 은 인덱스, w_json.1은 json 내용
                                ids_content.append("\(w_json.1["content"])")
                                ids_date.append("\(w_json.1["date"])")
                            }
                        }
                    case .failure(let error):
                        print(error)
                }
                completion(ids_content, ids_date)
                //closer 기법
            }
    }
    func Update_table(){
        self.getWalkcontent(url: server_url+"/walk/view")
        { (ids_content, ids_date) in
            print("get Walkcontent 동작")
            self.table_content.append(contentsOf: ids_content)
            self.table_date.append(contentsOf: ids_date)
            self.tableView.reloadData()// server와 비동기화
        }
    }
    func Update_table_one(){
        self.getWalkcontentOne(url: server_url+"/walk/viewone")
        { (ids_content_one, ids_date_one) in
            print("get WalkcontentOne 동작")
            print(ids_date_one[0])
            print(ids_content_one[0])
            self.table_content.insert(ids_content_one[0],at: 0)
            self.table_date.insert(ids_date_one[0], at: 0)
//            self.table_content.append(contentsOf: ids_content_one)
//            self.table_date.append(contentsOf: ids_date_one)
            self.tableView.reloadData()// 테이블뷰 리로드
            self.offset+=1
        }
    }// 글쓰기로 인해 1개의 값 받아오고, 테이블뷰에 넣고, 다시 로드
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
}
extension UserLogViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.table_content.count
    }// 한 섹션에 row가 몇개 들어갈 것인지
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ymd:String
        var hms:String
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath) as! walk_cell
        if table_date[indexPath.row] != "null"{
            (ymd, hms)=date_parsing(date: table_date[indexPath.row])
            cell.dateLabel.text = ymd
            cell.contentLabel.text = String(table_content[indexPath.row])
            
            return cell
        }
        // cell.dateLabel.text = String(table_date[indexPath.row])
        return cell
    }// cell 에 들어갈 데이터를 입력하는 function
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.tableView.rowHeight<=80){
            return 80
        }
        else{
            return self.tableView.rowHeight
        }
    }// 높이지정
    
    
    
}
