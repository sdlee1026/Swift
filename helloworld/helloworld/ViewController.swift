//
//  ViewController.swift
//  helloworld
//
//  Created by 이성대 on 2020/04/07.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // Click Btn
    @IBAction func Click_move(_ sender: Any) {
        // story_board find controller, 'DetailController'
        // '옵셔널 바인딩'  기법으로 선언
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailController")
        {
             // push controller = navi
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
}

