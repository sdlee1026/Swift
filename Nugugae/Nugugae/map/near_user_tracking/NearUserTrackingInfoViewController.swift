//
//  NearUserTrackingInfoViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/08.
//  Copyright © 2020 이성대. All rights reserved.
//

// near_user_tracking < identifier seg's, walkMap <-> NearUserTracking

import UIKit
import Alamofire
import SwiftyJSON

class NearUserTrackingInfoViewController: UIViewController {
    
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var tracking_user:String = ""
    // 추적할 유저의 아이디, seg 로 전송받을 것
    
    let temp_img: UIImage = UIImage(named: "안내_사진없음2.png")!
    
    @IBOutlet weak var profile_img: UIImageView!
    // 프로필 이미지
    
    @IBOutlet weak var userid_label: UILabel!
    // 유저 아이디로 표시할 라벨
    @IBOutlet weak var nick_name_label: UILabel!
    // 닉네임
    @IBOutlet weak var intro_textview: UITextView!
    
    @IBOutlet weak var dog_info_table: UITableView!
    
    
    
    var table_img:[UIImage] = []
    var table_name:[String] = []
    var table_breed:[String] = []
    var table_age:[String] = []
    // 개들 테이블 이미지,이름,품종,나이 들어갈 곳
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로 가기 버튼
    override func viewDidLoad() {
        super.viewDidLoad()
        print("near_user_tracking_info_view Start")
        print("tracking User id : ", tracking_user)
        dog_info_table.delegate = self
        dog_info_table.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tnear_user_tracking_info_view")
        self.userid_label.text = tracking_user
        // label 변경 <- User id로
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view did appear \tnear_user_tracking_info_view")
        
        viewUserinfodata(url: server_url+"/walkservice/near_user/view") { (ids) in
            print(ids)
        }
        getDogscontent(url: server_url+"/setting/doginfo/all/view") { (ids_name, ids_age, ids_breed, ids_image) in
            print("개 정보 db에서 부름")
            self.table_name=[]
            self.table_age=[]
            self.table_breed=[]
            self.table_img=[] // 초기화
            
            self.table_name.append(contentsOf: ids_name)
            self.table_age.append(contentsOf: ids_age)
            self.table_breed.append(contentsOf: ids_breed)
            self.table_img.append(contentsOf: ids_image)
            self.dog_info_table.reloadData()
            // 테이블 새로고침
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear, \tnear_user_tracking_info_view")
    }
    func viewUserinfodata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.tracking_user,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let viewdata = JSON(value)// 응답
                        self.nick_name_label.text = viewdata["nickname"].string!
                        self.intro_textview.text = viewdata["introduce"].string!
                        //print(viewdata["image"].rawString())
                        if viewdata["image05"].rawString() != Optional("null"){
                            print("이미지 db에서 로드")
                            let rawData = viewdata["image05"].rawString()
                            let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                            print(decodedimage)
                            self.profile_img.image = decodedimage
                            ids.append("work complete!")
                        }
                        
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// user info view DB
    
    func getDogscontent(url: String, completion: @escaping ([String],[String],[String],[UIImage]) -> Void) {
        
        let parameters: [String:[String]] = [
            "id":[self.tracking_user],
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON { response in
                var ids_name = [String]()
                var ids_age = [String]()
                var ids_breed = [String]()
                var ids_image = [UIImage]()
                switch response.result {
                    case .success(let value):
                        let dogsJson = JSON(value)
                        // SwiftyJSON 사용
                        if (dogsJson["err"]=="No dogs"){
                            print("!")
                            print("\(dogsJson["err"])")
                        }
                        else{
                            for d_json in dogsJson{
                                // d_json.0 은 인덱스, d_json.1은 json 내용
                                ids_name.append("\(d_json.1["dogname"])")
                                ids_age.append("\(d_json.1["age"]) 개월")
                                ids_breed.append("\(d_json.1["breed"])")
                                if d_json.1["image"].rawString() != Optional("null"){
                                    print("개 프로필, db로드")
                                    let rawData = d_json.1["image"].rawString()
                                    let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                                    print(decodedimage)// 불러온 이미지, 디코딩
                                    ids_image.append(decodedimage)
                                }
                                else{
                                    print("이미지 없는 경우,")
                                    ids_image.append(self.temp_img)// 사진 없음
                                }
                                // 이미지 처리
                            }
                        }
                    case .failure(let error):
                        print(error)
                }
                completion(ids_name, ids_age,ids_breed,ids_image)
                //closer 기법
            }
    }
    // 개정보 테이블 불러오기
}
extension NearUserTrackingInfoViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("테이블 넣기")
        print(self.table_name)
        print(self.table_age)
        print(self.table_breed)
        return self.table_name.count
    }// 한 섹션에 row가 몇개 들어갈 것인지
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dog_cell", for: indexPath) as! dog_cell
        cell.breed_label.text! = self.table_breed[indexPath.row]
//        if self.table_img[indexPath.row] != nil{
        cell.img.image = self.table_img[indexPath.row]
//        }
        cell.age_label.text! = self.table_age[indexPath.row]
        cell.name_label.text! = self.table_name[indexPath.row]
        print("cell dequeue 동작 완료")
        return cell
    }// cell 에 들어갈 데이터를 입력하는 function
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.dog_info_table.rowHeight != 100){
            return 100
        }
        else{
            return self.dog_info_table.rowHeight
        }
    }// 높이지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("\n\n\n!!!!!!table_cell click")
        // 작업 인덱스 저장
//        print(indexPath.row)
//        print(self.table_name[indexPath.row])
//        self.seg_name = self.table_name[indexPath.row]
//        if seg_name.count > 0{
//            print("!!!!seg 실행")
//            self.performSegue(withIdentifier: "dogtable_to_detail_seg", sender: seg_name)
//
//
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }// 클릭 이벤트 발생, segue 호출
    
}
