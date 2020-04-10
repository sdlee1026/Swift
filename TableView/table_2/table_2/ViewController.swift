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
    
    // 테이블 뷰 : 테이블로 이루어진 뷰
    // 여러개의 행이 모여있는 목록 뷰(화면)
        // 고려사항
        // 1. 테이블 내의 데이터가 무엇인가
        // 2. 데이터는 몇개가 들어가는가
        // 3. 그 행을 눌렀을때 행동은?
    
    @IBOutlet weak var tableMain: UITableView!
    
    // 구현체
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 데이터 몇개?
        return 10
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
            
        cell.LabelText.text = "\(indexPath.row)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 테이블 클릭
        print(indexPath.row)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableMain.delegate = self
        tableMain.dataSource = self
    }
    
}

