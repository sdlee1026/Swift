//
//  UserGalleryViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/26.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserGalleryViewController: UIViewController, UITextFieldDelegate{
    var public_private_ary:[String] = []
    var image_ary:[UIImage] = []
    // api로 받아올 이미지와 프라이빗 토큰 정보 배열
    var date_ary_forseg:[String] = []
    var imgdate_ary_forseg:[String] = []
    // seg를 위한 데이터 저장 배열
    var isAvailable = true
    // view tabel 토큰, scoll 기능
    var api_end_token = false
    // api_end token <- 스크롤 동작시 api 쿼리 요청 여러개 안보내게끔하는 토큰
    var offset:Int = 0
    // 오프셋
    var segue_pu_pr:String = ""
    var segue_date:String = ""
    var segue_imgdate:String = ""
    // 세그먼트로 보낼 데이터, seg id = my_gallery_to_item
    var cell_width:CGFloat = 0
    var cell_height:CGFloat = 0
    
    @IBOutlet weak var my_gallery_collection: UICollectionView!
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    var img_view: UIImage?
    let temp_img: UIImage = UIImage(named: "안내_사진없음2.png")!// 사진 없음
    
    @IBAction func logout_btn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userId")
        print("로그아웃 버튼 클릭")
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            guard let mainVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                fatalError("Could not instantiate HomeVC!")
            }
            self.view.window?.rootViewController = mainVC
            self.view.window?.makeKeyAndVisible()
            
        })//현재 윈도우에 root뷰 컨트롤러에 접근, 하위 뷰 삭제, main 뷰로 화면 전환
        // self.view.window?.rootViewController = mainVC 메인 뷰컨트롤러로 새롭게 설정
        // ScencDelegate
    }
    // 로그 아웃 버튼
    
    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var profile_id: UILabel!
    @IBOutlet weak var profile_nick: UILabel!
    @IBOutlet weak var profile_intro: UITextView!
    // profile img, label, outlet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserGallery Start")
        self.profile_id.text = user
        
        UserDefaults.standard.set(false, forKey: "fixed_gallery")
        UserDefaults.standard.set(false, forKey: "deleted_gallery")
        UserDefaults.standard.set(false, forKey: "new_gallery")
        // 관련 유저 디폴트 선언
        
        viewUserinfodata(url: server_url+"/setting/userinfo/detail/view") { (ids) in
            print("유저 정보 첫 로드")
            // 개이름, 나이(개월), 품종, 활동량, 자기소개
        }
        viewMyGallerydata(url: server_url+"/gallery/my/view") { (ids_image, ids_pu_pr, ids_date, ids_imgdate) in
            print("컬렉션 뷰 로드, 첫 로드")
            self.public_private_ary.append(contentsOf: ids_pu_pr)// 라벨에 들어갈 t/f
            self.image_ary.append(contentsOf: ids_image)    // 이미지 파일
            self.date_ary_forseg.append(contentsOf: ids_date)
            self.imgdate_ary_forseg.append(contentsOf: ids_imgdate)
            // seg를 위한 데이터 배열
            self.my_gallery_collection.reloadData()
        }
        self.my_gallery_collection.delegate = self
        self.my_gallery_collection.dataSource = self
        setupFlowLayout()
        // 레이아웃 세팅
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        
        let halfWidth = UIScreen.main.bounds.width / 3
        flowLayout.itemSize = CGSize(width: halfWidth * 0.9 , height: halfWidth * 0.9)
        self.my_gallery_collection.collectionViewLayout = flowLayout
    }
    // 컬렉션뷰 레이아웃
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tGalley view")
        
        if UserDefaults.standard.bool(forKey: "fixed_userinfo"){
            // 유저 정보 상태값 변동이 있었다면?
            viewUserinfodata(url: server_url+"/setting/userinfo/detail/view") { (ids) in
                print("유저 정보 상태 변경으로 인한 재로드")
                // 개이름, 나이(개월), 품종, 활동량, 자기소개
            }
            UserDefaults.standard.set(false, forKey: "fixed_userinfo")
            // 유저 정보 상태값 다시 false
        }
        
        
        
        // 갤러리 삽입/수정/삭제 동작 있을 경우
        if UserDefaults.standard.bool(forKey: "fixed_gallery") || UserDefaults.standard.bool(forKey: "deleted_gallery") ||
            UserDefaults.standard.bool(forKey: "new_gallery"){
            self.offset = 0
            // offset 0부터 재탐색
            viewMyGallerydata(url: server_url+"/gallery/my/view") { (ids_image, ids_pu_pr, ids_date, ids_imgdate) in
                print("컬렉션 뷰 로드, 갤러리 상태 변화로 인한 재로드")
                self.public_private_ary = []
                self.image_ary = []
                self.date_ary_forseg = []
                self.imgdate_ary_forseg = []
                
                self.public_private_ary.append(contentsOf: ids_pu_pr)// 라벨에 들어갈 t/f
                self.image_ary.append(contentsOf: ids_image)    // 이미지 파일
                self.date_ary_forseg.append(contentsOf: ids_date)
                self.imgdate_ary_forseg.append(contentsOf: ids_imgdate)
                // seg를 위한 데이터 배열
                self.my_gallery_collection.reloadData()
            }
            
            UserDefaults.standard.set(false, forKey: "fixed_gallery")
            UserDefaults.standard.set(false, forKey: "deleted_gallery")
            UserDefaults.standard.set(false, forKey: "new_gallery")
            
        }// 갤러리 수정/삭제 동작 있을 경우
        
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(true)
        print("view 호출 후\tGalley view")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("view dissapper\tGalley view")
    }
    // 스크롤 func
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤시작")
        if self.my_gallery_collection.contentOffset.y > my_gallery_collection.contentSize.height-my_gallery_collection.bounds.size.height
            {
                if(isAvailable){// 조건문에 api_end_token 이 true일때만 동작하도록
                    print("스크롤 캐치, 예전 내용load")
                    isAvailable = false
                    offset += 9
                    // 스크롤 할때 마다 데이터 불러옴 9개
                    self.viewMyGallerydata(url: server_url+"/gallery/my/view") { (ids_image, ids_pu_pr, ids_date, ids_imgdate) in
                        print("컬렉션 뷰 로드, 스크롤로 인한 재로드")
                        self.public_private_ary.append(contentsOf: ids_pu_pr)// 라벨에 들어갈 t/f
                        self.image_ary.append(contentsOf: ids_image)    // 이미지 파일
                        self.date_ary_forseg.append(contentsOf: ids_date)
                        self.imgdate_ary_forseg.append(contentsOf: ids_imgdate)
                        // seg를 위한 데이터 배열
                        
                        self.my_gallery_collection.reloadData()
                        self.api_end_token = true
                        
                    }
                    // api 로드
                    // 로드 클로저에서 api_end_token = true로 바꾸고,, 선언부터 해야됨 1030일
                        // api_end_token << 한번에 여러쿼리 안보내게끔 락킹..
                    
                }
            //my_gallery_collection.reloadData()
            // 아마 안쓸듯, 스크롤 종료시에만 리로드 하기로
        }
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
        // api_end_token이 true일때만 다시 동작하도록
        if api_end_token == true{
            isAvailable = true
            api_end_token = false
        }
        // api_end_token을 false로 다시 세팅하고, 리로드
        //my_gallery_collection.reloadData()
        
    }
    func viewUserinfodata(url: String, completion: @escaping ([Any]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [Any]()
                switch response.result{
                    case .success(let value):
                        let viewdata = JSON(value)// 응답
                        self.profile_nick.text = viewdata["nickname"].string!
                        self.profile_intro.text = viewdata["introduce"].string!
                        //print(viewdata["image"].rawString())
                        if viewdata["image"].rawString() != Optional("null"){
                            print("이미지 db에서 로드")
                            let rawData = viewdata["image"].rawString()
                            let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!

                            print(decodedimage)
                            self.profile_img.image = decodedimage
                        }
                        
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// user info view DB
    func viewMyGallerydata(url: String, completion: @escaping ([UIImage],[String],[String],[String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "offset":String(self.offset)
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids_image = [UIImage]()
                var ids_pu_pr = [String]()
                var ids_date = [String]()
                var ids_imgdate = [String]()
                switch response.result{
                case .success(let value):
                    let mygallerydata = JSON(value)// 응답
                    if (mygallerydata["err"]=="No item"){
                        print("!")
                        print("\(mygallerydata["err"])")
                        self.offset -= 9
                    }
                    else{
                        for m_json in mygallerydata{
                            // w_json.0 은 인덱스, w_json.1은 json 내용
                            if m_json.1["image01"].rawString() != Optional("null"){
                                print("img load, index : ", m_json.0)
                                let rawData = m_json.1["image01"].rawString()
                                // 썸네일용 10% 퀄리티
                                let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                                print(decodedimage)
                                ids_image.append(decodedimage)
                            }
                            else{
                                ids_image.append(self.temp_img)
                            }
                            ids_pu_pr.append("\(m_json.1["ispublic"])")
                            ids_date.append("\(m_json.1["date"])")
                            ids_imgdate.append("\(m_json.1["imgdate"])")
                        }
                    }
                case .failure( _): break
                    
                }
                completion(ids_image, ids_pu_pr, ids_date, ids_imgdate)
            }
        
    }// mygallery View DB (컬렉션 뷰)
    
    func viewGallerydata(url: String, completion: @escaping ([UIImage]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids_image = [UIImage]()
                switch response.result{
                case .success(let value):
                    let mygallerydata = JSON(value)// 응답
                    if (mygallerydata["err"]=="No item"){
                        print("!")
                        print("\(mygallerydata["err"])")
                        self.offset -= 9
                    }
                    else{
                        for m_json in mygallerydata{
                            // w_json.0 은 인덱스, w_json.1은 json 내용
                            if m_json.1["image01"].rawString() != Optional("null"){
                                print("img load, index : ", m_json.0)
                                let rawData = m_json.1["image01"].rawString()
                                // 썸네일용 10% 퀄리티
                                let dataDecoded:NSData = NSData(base64Encoded: rawData!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                                print(decodedimage)
                                ids_image.append(decodedimage)
                            }
                            else{
                                ids_image.append(self.temp_img)
                            }
                        }
                    }
                case .failure( _): break
                    
                }
                completion(ids_image)
            }
        
    }// gallery View DB (하나 갤러리 뷰)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "my_gallery_to_item"{
            print("segue data prepare")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? GalleryItemViewController {
                rvc.date = self.segue_date
                rvc.imgdate = self.segue_imgdate
                rvc.pu_pr = self.segue_pu_pr
            }
        }
    }
    // segue 데이터전송시 준비
    
}
extension UserGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 이미지의 갯수
        print("이미지 갯수 세팅 : ", public_private_ary.count)
        return public_private_ary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 이미지의 내용
        print("컬렉션뷰 내용 삽입중, ", indexPath.row)
        print(public_private_ary[indexPath.row])
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mygallery_cell", for: indexPath) as! mygallery_cell
        if public_private_ary[indexPath.row] == "true"{
            cell.public_private_label.text = "공개"
        }
        else{
            cell.public_private_label.text = "비공개"
        }
        cell.content_image.image = image_ary[indexPath.row]
        return cell
    }
}
extension UserGalleryViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width / 3 - 1 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
        print("collectionView width=\(collectionView.frame.width)")
        print("cell하나당 width=\(width)")
        print("root view width = \(self.view.frame.width)")
        self.cell_height = width+17
        self.cell_width = width
        return CGSize(width: width, height: width+17)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("컬렉션 선택, ", indexPath.row)
        print("seg 인자, 유저 이름, 게시글 날짜, 사진의 날짜, 공개_비공개")
        print(self.user,self.date_ary_forseg[indexPath.row],self.imgdate_ary_forseg[indexPath.row], self.public_private_ary[indexPath.row])
        
        self.segue_date = self.date_ary_forseg[indexPath.row]
        self.segue_imgdate = self.imgdate_ary_forseg[indexPath.row]
        self.segue_pu_pr = self.public_private_ary[indexPath.row]
        self.performSegue(withIdentifier: "my_gallery_to_item", sender: nil)
    }
}
