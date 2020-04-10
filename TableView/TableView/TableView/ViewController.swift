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
        // 방법 2가지
            // 1번 방법, 임의의 셀 만들기
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "TableCellType1")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
        
            // 2번 방법 : 스토리보드 + identifier
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableMain.delegate = self
        tableMain.dataSource = self
    }
    
}

