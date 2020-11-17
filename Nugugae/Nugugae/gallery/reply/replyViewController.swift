//
//  replyViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/17.
//  Copyright © 2020 이성대. All rights reserved.
//

// seg : gallery_reply_seg
// GalleryItemViewController -> replyViewController
// q!split_content!댓글입니다!split_id!hi!split_content!댓글입니다2!split_id!

import UIKit
import Alamofire
import SwiftyJSON
class replyViewController : UIViewController
{
    var keyboardShown:Bool = false // 키보드 상태 확인
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var keyboardToken:Bool = false
    // 키보드 상태 토큰
    
    var seg_gallery_id = "" // 게시물의 id
    var seg_date = ""
    var seg_imgdate = ""
    // seg 로 받을 데이터
    var post_msg = ""
    // api로 보낼 댓글 메세지
    var raw_string_reply = ""
    
    var id_ary:[String] = []
    var content_ary:[String] = []
    
    @IBOutlet weak var reply_table: UITableView!
    
    @IBOutlet weak var my_id_label: UILabel!
    
    @IBOutlet weak var reply_content_text: UITextView!
    
    @IBAction func new_reply_btn(_ sender: Any) {
        print("새로운 댓글 입력 버튼")
        if reply_content_text.text != ""{
            self.post_msg = self.raw_string_reply+self.user+"!split_content!"+self.reply_content_text.text!+"!split_id!"
            view.endEditing(true)
            self.id_ary = []
            self.content_ary = []
            // 일단 초기화.. 나중에 동작 개선해야함
            postReplyLoadReply(url: server_url+"/gallery/reply/new"){(ids) in
                print("댓글 보냄, 새로 받기")
                self.reply_content_text.text = ""
                self.reply_table.reloadData()
            }
        }
        else{
            let no_content_alert = UIAlertController(title: "내용이 없어요!", message: "댓글엔 내용이 반드시 들어가야 합니다!", preferredStyle: .alert)
            let ok_action = UIAlertAction(title: "네!", style: .default) { (action) in
                self.reply_content_text.becomeFirstResponder()
            }
            no_content_alert.addAction(ok_action)
            
            present(no_content_alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("reply_view Start")
        print("seg data : ", seg_gallery_id, seg_date, seg_imgdate)
        // 전처리
        loadReplyData(url: server_url+"/gallery/reply") { (ids) in
            print("리플 로드")
            print(self.id_ary)
            print(self.content_ary)
            self.reply_table.reloadData()
        }
        self.reply_table.delegate = self
        self.reply_table.dataSource = self
        self.reply_content_text.delegate = self
        self.my_id_label.text = self.user
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("view 호출(view will appear)\treply_view")
    }
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\treply_view")
        registerForKeyboardNotifications()
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\treply_view")
        unregisterForKeyboardNotifications()
        super.viewDidDisappear(true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "like_user_to_other_seg"{
//            print("segue other_user_gallery")
//
//            let dest = segue.destination
//            print("dest : \(dest)")
//            if let rvc = dest as? OtherUserGalleryViewController {
//                rvc.seg_userid = self.seg_userid
//            }
//        }
//    }
    
    func loadReplyData(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.seg_gallery_id,
            "reply_user":self.user, // 접근 유저
            "date":self.seg_date,
            "imgdate":self.seg_imgdate,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let replydata = JSON(value)// 응답
                    if (replydata["err"]=="Incorrect name'"){
                        print("!")
                        print("\(replydata["err"])")
                    }
                    else{
                        if "\(replydata["content"])" != "null"{
                            self.raw_string_reply = "\(replydata["content"])"
                            
                        }
                        let reply_ary = "\(replydata["content"])".components(separatedBy: "!split_id!")
                        for reply in reply_ary {
                            print(reply)
                            if reply.count > 1 && reply != "null" {
                                let temp_ary = reply.components(separatedBy: "!split_content!")
                                self.id_ary.append(temp_ary[0])
                                self.content_ary.append(temp_ary[1])
                            }
                        }
                        self.id_ary = Array(self.id_ary.reversed())
                        self.content_ary = Array(self.content_ary.reversed())
                        ids.append("\(replydata["content"])");
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
        
    }// load reply
    
    func postReplyLoadReply(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.seg_gallery_id,
            "reply_user":self.user, // 접근 유저
            "date":self.seg_date,
            "imgdate":self.seg_imgdate,
            "reply":self.post_msg
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                case .success(let value):
                    let replydata = JSON(value)// 응답
                    if (replydata["err"]=="Incorrect name'"){
                        print("!")
                        print("\(replydata["err"])")
                    }
                    else{
                        let reply_ary = "\(replydata["content"])".components(separatedBy: "!split_id!")
                        for reply in reply_ary {
                            print(reply)
                            if reply.count > 1 && reply != "null" {
                                let temp_ary = reply.components(separatedBy: "!split_content!")
                                self.id_ary.append(temp_ary[0])
                                self.content_ary.append(temp_ary[1])
                            }
                        }
                        self.id_ary = Array(self.id_ary.reversed())
                        self.content_ary = Array(self.content_ary.reversed())
                        ids.append("\(replydata["content"])");
                    }
                case .failure( _): break
                    
                }
                completion(ids)
            }
        
    }// mygallery update DB
    
    func registerForKeyboardNotifications() {
        // 옵저버 등록
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    func unregisterForKeyboardNotifications() {
      // 옵저버 등록 해제
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 키보드 사이즈를 받아옴
            if keyboardSize.height == 0.0 || keyboardShown == true {
                return
            }
            if (keyboardToken == true){
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height) })
            }
        }
    }
    @objc func keyboardWillHide(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.transform = .identity

        }
        keyboardToken=false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
extension replyViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.id_ary.count
    }// 한 섹션에 row가 몇개 들어갈 것인지
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reply_cell", for: indexPath) as! reply_cell
        
        cell.userid.text = String(self.id_ary[indexPath.row])
        cell.content.text = String(self.content_ary[indexPath.row])
        
        return cell
    }// cell 에 들어갈 데이터를 입력하는 function
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.reply_table.rowHeight<=80){
            return 80
        }
        else{
            return self.reply_table.rowHeight
        }
    }// 높이지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("table_cell click")
        view.endEditing(true)
        // 작업 인덱스 저장
//        if self.table_user[indexPath.row].count > 0{
//            print("id : ", self.table_user[indexPath.row])
//
//            self.seg_userid = String(self.table_user[indexPath.row])
//            // seg로 보낼 id
//            self.performSegue(withIdentifier: "like_user_to_other_seg", sender: nil)
//        }
//
//        tableView.deselectRow(at: indexPath, animated: true)
    }// 클릭 이벤트 발생, segue 호출
}
extension replyViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("텍스트 뷰 수정시작")
        self.keyboardToken = true
    }// TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        self.keyboardToken = false
    }
}
