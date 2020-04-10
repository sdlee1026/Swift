//
//  ViewController.swift
//  TableView
//
//  Created by 이성대 on 2020/04/10.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    // date, 0410_1
    // 테이블 뷰 : 테이블로 이루어진 뷰
    // 여러개의 행이 모여있는 목록 뷰(화면)
    // 고려사항
    // 1. 테이블 내의 데이터가 무엇인가
    // 2. 데이터는 몇개가 들어가는가
    // 3. 그 행을 눌렀을때 행동은?
    
    // date, 0410_3
    // 1. http 통신 방법, Swift -> urlsesson 이용
    // info.plist 고쳐줘야함
    //    <key>NSAppTransportSecurity</key>
    //    <dict>
    //      <key>NSAllowsArbitraryLoads</key>
    //      <true/>
    //    </dict>
    // 2. JSON 데이터 형태(news_api), 통신 규약..{"key":"values", ... }
    // 3. 테이블 뷰의 데이터 매칭
    var newsData: Array<Dictionary<String, Any>>?
    
    func getNews()
    {
        let task = URLSession.shared.dataTask(with: URL(string: "http://newsapi.org/v2/top-headlines?country=kr&apiKey=921c719aa1f14dcb8847bd638a7cd820")!)
        {
            (data , response, error) in
            if let datajson = data{
                print(datajson)
                // json parsing
                // 오류상황 대처 throw .. : do. catch
                do {
                    let newsJson = try JSONSerialization.jsonObject(with: datajson, options: []) as! Dictionary<String, Any>
                    // json dict 변환(친자확인 강제)
                    let articles = newsJson["articles"] as! Array<Dictionary<String, Any>>
                    self.newsData = articles
                    
                    DispatchQueue.main.async { // 메인에서 일을하여라. sync비동기로
                        self.tableMain.reloadData()
                        // 데이터 통보 메인 테이블에
                        // 쓰레드들이 백그라운드에서 일함(데이터통신에서)
                    }
                }
                catch{
                    print("JSON LOAD error")
                }
            }
        }
        task.resume()
        // suspended(일시중지) 하다면 다시 시작하도록..
        // 여기서 시작
    }
    @IBOutlet weak var tableMain: UITableView!
    
    // date, 0410_2
    // 구현체
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 데이터 몇개?
        if let news = newsData{
            return news.count
        }
        else{return 0}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell
    {
        // 데이터 무엇?, 데이터의 갯수만큼 반복해서 리턴
        // 2번 방법 : 스토리보드 + identifier
        
        let cell = tableMain.dequeueReusableCell(withIdentifier: "Type1", for: indexPath) as! Type1
        // as?, as! 두가지 존재, 타입을 안전하게 추론하는 as?, 강제로 변환 as!
        // UITableView 를 상속받는 Type1(자식)을 향하기 위해서 친자확인..as
        // 하지 않으면 UITableView를 return 받기 때문에, cell의 label받을 수 없음(우리의 목표)
        // as! 를 통해서 Type1(UITableView를 상속받은) 클래스로 받환
        
        let idx = indexPath.row
        if let news = newsData
        {
            let row = news[idx]
            if let r = row as? Dictionary<String, Any>
            {
                // optional printing 벗겨내기
                if let title = r["title"] as? String{
                    cell.LabelText.text = title
                }
            }
        }
        return cell
    }
    // 1) 옵션 - 클릭 감지
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 테이블 클릭
//        print(indexPath.row)
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil) // main 스토리보드로 초기화
//        let controller = storyboard.instantiateViewController(identifier: "NewsDetailController") as! NewsDetailController
//        // 그 스토리 보드의 컨트롤러 _식별자따라간..(식별자는 NewsDetailController)
//        if let news = newsData{
//            let row = news[indexPath.row]
//            if let r = row as? Dictionary<String, Any>{
//                if let imgUrl = r["urlToImage"] as? String{
//                    controller.imageURL = imgUrl
//                }
//                if let desc = r["description"] as? String{
//                    controller.desc = desc
//                }
//            }
//        }
//        // 이동! -> 수동으로
//       showDetailViewController(controller, sender: nil)// 식별자의 컨트롤러로 이동
//    }
    //     2) 세그웨이 : 부모(a,b,c)-자식
    //     부모의 a,b,c class를 자식이 사용할 수 있음_상속
    //     override +알파 기능 가능
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "NewsDetail" == id{
            if let controller = segue.destination as? NewsDetailController{
                if let news = newsData{
                    if let indexPath = tableMain.indexPathForSelectedRow{
                        let row = news[indexPath.row]
                        if let r = row as? Dictionary<String, Any>{
                            if let imgUrl = r["urlToImage"] as? String{
                                controller.imageURL = imgUrl
                            }
                            if let desc = r["description"] as? String{
                                controller.desc = desc
                            }
                        }
                    }
                }
            }
        }
        // show segueway를 통해 이어졌으므로, 이동이 자동으로 이루어짐
        // (값은 override로 미리 준비)
    }
    
    // date, 0410_4
    // 1. 디테일 화면 만들기
    // 2. 값 보내는 방법 2가지
    // 1) TableView의 delegate, 2) storyboard(segue) 특정 컨트롤러에서 다른 컨트롤러로.
    // 3. 화면 이동 (화면을 이동하기 전에 세팅해야한다)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableMain.delegate = self
        tableMain.dataSource = self
        
        getNews()
        
    }
    
}

