//
//  walk_cell_viewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/10/02.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class walk_cell_viewController: UIViewController, UITextFieldDelegate {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    @IBAction func back_btn(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walk_cell_view Start")
        print("외부접속 url : " + server_url)
        // Do any additional setup after loading the view.
    }
}
