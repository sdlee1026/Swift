//
//  walk_history.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/11.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class walk_history:UIViewController{
    
    let server_url:String = Server_url.sharedInstance.server_url
    var walk_write = walk_writeController.sharedInstance
    var walk_fix = walk_cell_viewController.sharedInstance
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var table_date:[String] = []
    var table_start:[String] = []
    var table_end:[String] = []
    var table_distance:[String] = []
    var isAvailable = true
    // view tabel 토큰, scoll 기능
    var api_end_token = false
    // api_end_token <- 스크롤 동작시, 요청 중복 요청 여러개 안하게끔 토큰
    var offset:Int = 0
    
    var start_page = ""
    
    @IBOutlet weak var history_table: UITableView!
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_history_select_view Start")
        history_table.delegate = self
        history_table.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\twalk_history_select_view")
        super.viewWillAppear(true)
        if UserDefaults.standard.string(forKey: "map_select_token") == "true"{
            print("도착지 label, 세팅")
            if self.start_page == "walk_writeController"{
                walk_write.seg_time = self.selected_table_date
                walk_write.seg_distance = self.selected_table_distance
            }
            if self.start_page == "walk_cell_viewController"{
                walk_fix.seg_time = self.selected_table_date
                walk_fix.seg_distance = self.selected_table_distance
            }

            UserDefaults.standard.setValue("false", forKey: "map_select_token")
            self.dismiss(animated: true, completion: nil)
            
        }

    }
    
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \twalk_history_select_view")
        self.offset = 0
        getHistorycontent(url: server_url+"/history/loadtable"){(ids_date, ids_start, ids_end, ids_distance) in
            print("산책 기록 불러오기")
            self.table_date = []
            self.table_start = []
            self.table_end = []
            self.table_distance = []
            // 초기화
            
            self.table_date.append(contentsOf: ids_date)
            self.table_start.append(contentsOf: ids_start)
            self.table_end.append(contentsOf: ids_end)
            self.table_distance.append(contentsOf: ids_distance)
            self.history_table.reloadData()
            // 테이블 새로고침
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \twalk_history_select_view")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤시작")
        if history_table.contentOffset.y > history_table.contentSize.height-history_table.bounds.size.height
            {
                if(isAvailable)
                {
                    print("스크롤 캐치, 과거 load")
                    isAvailable = false
                    offset += 10
                    // 스크롤 할때 마다 데이터 불러옴 10개
                    self.getHistorycontent(url: server_url+"/history/loadtable") { (ids_date, ids_start, ids_end, ids_distance) in
                        print("스크롤로 인한 테이블 로드")
                        self.table_date.append(contentsOf: ids_date)
                        self.table_start.append(contentsOf: ids_start)
                        self.table_end.append(contentsOf: ids_end)
                        self.table_distance.append(contentsOf: ids_distance)
                        self.history_table.reloadData()
                        self.api_end_token = true
                    }
                    
                }
        }
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
        if api_end_token == true{
            isAvailable = true
            api_end_token = false
        }
    }
    
    var selected_table_date = ""
    var selected_table_distance = ""
    
    func getHistorycontent(url: String, completion:@escaping ([String],[String],[String],[String])->Void){
        
        let parameters: [String:String] = [
            "id": self.user,
            "offset": String(self.offset)
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).responseJSON{ response in
            var ids_date = [String]()
            var ids_start = [String]()
            var ids_end = [String]()
            var ids_distance = [String]()
            
            switch response.result{
            case .success(let value):
                let historyJson = JSON(value)
                // SwiftyJSON 사용
                if (historyJson["err"] == "No history" || historyJson["err"] == "No item"){
                    print("!")
                    print("\(historyJson["err"])")
                    if self.offset>10{
                        self.offset -= 10
                    }
                }
                else{
                    for h_json in historyJson{
                        ids_date.append("\(h_json.1["date"])")
                        ids_start.append("\(h_json.1["starttime"])")
                        ids_end.append("\(h_json.1["endtime"])")
                        ids_distance.append("\(h_json.1["distance"])")
                    }
                }
            case.failure(let error):
                print(error)
            
            }
            completion(ids_date,ids_start,ids_end,ids_distance)
            // closer, 동기
        }
        
    }// 과거 산책기록 테이블 뷰 만들기
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "walk_write_history_detail_seg"{
            print("table click, segue prepare")
            UserDefaults.standard.setValue("false", forKey: "map_select_token")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? historyDetailViewController {
                rvc.seg_date = self.selected_table_date
                rvc.start_page = "walk_history"
                
            }
        }
        if segue.identifier == "walk_fix_history_detail_seg"{
            print("table click, segue prepare")
            UserDefaults.standard.setValue("false", forKey: "map_select_token")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? historyDetailViewController {
                rvc.seg_date = self.selected_table_date
                rvc.start_page = "walk_history"
                
            }
            
            
        }
    }
    // segue 데이터전송시 준비
}

extension walk_history: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("테이블 넣기")
        return self.table_date.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history_cell", for: indexPath) as! history_cell
        cell.date_label.text! = String(self.table_date[indexPath.row].split(separator: " ")[0])
        cell.start_time_label.text! = String(self.table_start[indexPath.row].split(separator: " ")[1])
        cell.end_time_label.text! = String(self.table_end[indexPath.row].split(separator: " ")[1])
        cell.distance_label.text! = self.table_distance[indexPath.row].split(separator: ".")[0]+"m"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.history_table.rowHeight != 100){
            return 100
        }
        else{
            return self.history_table.rowHeight
        }
    }// 높이지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\ttalbe_cell click, start page : ",self.start_page)
        self.selected_table_date = table_start[indexPath.row]
        self.selected_table_distance = table_distance[indexPath.row]
        if self.start_page == "walk_writeController"{
            performSegue(withIdentifier: "walk_write_history_detail_seg", sender: nil)
        }
        if self.start_page == "walk_cell_viewController"{
            performSegue(withIdentifier: "walk_fix_history_detail_seg", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // dismiss 하도록, seg 데이터로 보낸후에..
    }
    
    
}
