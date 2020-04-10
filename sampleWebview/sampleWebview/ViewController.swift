//
//  ViewController.swift
//  sampleWebview
//
//  Created by 이성대 on 2020/04/10.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import WebKit
// delegate 필요, 어떠한 동작을 하게 해주는 구현을 해야하는 인터페이스, 동작들을 도와주는
class ViewController: UIViewController, WKNavigationDelegate {
        

    @IBOutlet weak var webViewMain: WKWebView!
    
    // webView 사용법
        // 1. url을 찾는다(string)
        // 2. url 주소를 request로 만든다
        // 3. request 주소를 load한다
    func loadURL(){
//        view.addSubview(webViewMain)
        let naverString = "https://www.google.com"
        if let naver_url = URL(string: naverString){
            // unwrapping 필요
            // optional 바인딩
            let naverReq = URLRequest(url: naver_url)
            webViewMain.load(naverReq)
            webViewMain.navigationDelegate = self
        }
        print("str url -> request, request -> load url")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("view Did Load Call")
        loadURL()
    }
}

