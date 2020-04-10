//
//  NewsDetailController.swift
//  table_2
//
//  Created by 이성대 on 2020/04/10.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class NewsDetailController : UIViewController
{
    
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var textContent: UILabel!
    // 1. image url
    // 2. desc
    var imageURL:String?
    var desc:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = imageURL{
        // 이미지 주소 가져와서 뿌림 URL(string:주소), URL입력일 경우 Data는 throw기때문 try
            if let imgdata = try? Data(contentsOf: URL(string : img)!){
                // main_thread 에서 일하게끔
                DispatchQueue.main.async {
                    self.imageContent.image = UIImage(data: imgdata)
                }
            }
            
        }
        
        if let de = desc{
            // 뉴스 본문 보여준다
            self.textContent.text = de
        }
    }
}
