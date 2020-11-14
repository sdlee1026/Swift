//
//  LikeUserViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/14.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//gallery_like_user_seg, GalleryItemViewController -> LikeUserViewController
class LikeUserViewController: UIViewController {
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var isAvailable = true
    // view tabel 토큰, scoll 기능
    var api_end_token = false
    var data_end_token = false
    var offset:Int = 0
    
    @IBOutlet weak var user_table: UITableView!
    var segue_userlist:[Substring] = []
    var table_user:[Substring] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("like_user_view Start")
        // 전처리
        print("seg_userList : ", segue_userlist)
        user_table.delegate = self
        user_table.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tlike_user_view, cell")
        offset = 0
        
        super.viewWillAppear(true)
        if segue_userlist.count < 20{
            data_end_token = true
            table_user = segue_userlist
        }// 20명 이하 인 경우, 스크롤해도 더 이상 안불러오게끔
        else{
            data_end_token = false
            table_user.append(contentsOf: segue_userlist[0...19])
        }// 20명 이상인 경우
        user_table.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tlike_user_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tlike_user_view")
        super.viewDidDisappear(true)
    }
    // 스크롤 func
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤시작")
        if self.user_table.contentOffset.y > self.user_table.contentSize.height-self.user_table.bounds.size.height
        {
            if(isAvailable)
            {
                print("스크롤 캐치")
                isAvailable = false
                offset += 20
                if segue_userlist.count > offset+20{
                    data_end_token = false
                }
                else{
                    print("인덱스 끝 있음, 토큰 설정, offset : ",offset)
                    print("offset -20")
                    if data_end_token == false{
                        data_end_token = true
                        table_user.append(contentsOf: segue_userlist[offset...(segue_userlist.count-1)])
                        
                    }
                    offset -= 20
                }
                
                if data_end_token == false{
                    print("스크롤로 인한 데이터 로드")
                    table_user.append(contentsOf: segue_userlist[offset...offset+19])
                    //20개씩 늘어나나, 표기법 (offset ~ (offset + 20-1) )까지의 범위
                    
                }// 데이터 로드 끝나지 않았을 경우
                
                self.user_table.reloadData()
                self.api_end_token = true
                // 스크롤 할때 마다 데이터 불러옴 20개
            }
        }
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
        if api_end_token == true{
            isAvailable = true
            api_end_token = false
        }
        self.user_table.reloadData()
    }

}
extension LikeUserViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.table_user.count
    }// 한 섹션에 row가 몇개 들어갈 것인지
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "like_user_cell", for: indexPath) as! like_user_cell
        
        cell.userid.text = String(self.table_user[indexPath.row])
        
        return cell
    }// cell 에 들어갈 데이터를 입력하는 function
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.user_table.rowHeight<=80){
            return 80
        }
        else{
            return self.user_table.rowHeight
        }
    }// 높이지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("table_cell click")
        // 작업 인덱스 저장
        print("id : ", self.table_user[indexPath.row])
//        self.segue_content = self.table_content[indexPath.row]
//        self.segue_date = self.table_date[indexPath.row]
//        self.performSegue(withIdentifier: "walk_view_seg", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }// 클릭 이벤트 발생, segue 호출
}
