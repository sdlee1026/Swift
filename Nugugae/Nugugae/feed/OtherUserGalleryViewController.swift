//
//  OtherUserGalleryViewController.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/15.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
// seg : user_search_to_other_seg, UserSearchViewController -> OtherUserGalleryViewController
// seg : like_user_to_other_seg, LikeUserViewController -> OtherUserGalleryViewController

// to seg : other_to_gallery_seg
// OtherUserGalleryViewController -> GalleryItemViewController
class OtherUserGalleryViewController: UIViewController {
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    
    var seg_userid:String = ""
    // seg로 받고, 보낼 userid
    
    var seg_date:String = ""
    var seg_imgdate:String = ""
    // seg로 보낼 date, imgdate
    
    var cell_width:CGFloat = 0
    var cell_height:CGFloat = 0
    // cell w,h 설정 값
    
    var image_ary:[UIImage] = []
    // api로 받아올 이미지와 프라이빗 토큰 정보 배열
    var id_ary:[String] = []
    // 유저들의 아이디 받아올 배열
    var date_ary_forseg:[String] = []
    // seg로 보내야 해서 받아올 data 배열
    var imgdate_ary_forseg:[String] = []
    // seg로 보내야 해서 받아올 img의 date 배열
    
    var isAvailable = true
    // view tabel 토큰, scoll 기능
    var api_end_token = false
    // api_end token <- 스크롤 동작시 api 쿼리 요청 여러개 안보내게끔하는 토큰
    var offset:Int = 0
    // 오프셋
    
    @IBAction func back_btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }// 뒤로가기
    
    @IBOutlet weak var userid_label: UILabel!
    // 유저 아이디 label, 화면 상단
    
    @IBOutlet weak var gallery_collection: UICollectionView!
    
    override func viewDidLoad() {
        print("other_user_gallery_view Start")
        print("segue data : ", seg_userid)
        userid_label.text = seg_userid
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view 호출(view will appear)\tother_user_gallery_view")
        self.gallery_collection.delegate = self
        self.gallery_collection.dataSource = self
        self.image_ary = []
        self.id_ary = []
        self.date_ary_forseg = []
        self.imgdate_ary_forseg = []
        // 초기화
        self.offset = 0
        otherUserLoadData(url: server_url+"/feed/otheruser/load/public") { (ids_image, ids_id, ids_date, ids_imgdate) in
            print("other public 컬렉션 로드")
            
            self.image_ary.append(contentsOf: ids_image)
            self.id_ary.append(contentsOf: ids_id)
            self.date_ary_forseg.append(contentsOf: ids_date)
            self.imgdate_ary_forseg.append(contentsOf: ids_imgdate)
            self.gallery_collection.reloadData()
        }
        setupFlowLayout()
        super.viewWillAppear(true)
    }
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        let halfWidth = UIScreen.main.bounds.width / 3
        flowLayout.itemSize = CGSize(width: halfWidth * 0.9 , height: halfWidth * 0.9)
        self.gallery_collection.collectionViewLayout = flowLayout
    }
    // 컬렉션뷰 아이템 레이아웃
    override func viewDidAppear(_ animated: Bool) {
        print("view didAppear\tother_user_gallery_view")
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view disappear\tother_user_gallery_view")
        self.image_ary = []
        self.id_ary = []
        self.date_ary_forseg = []
        self.imgdate_ary_forseg = []
        self.gallery_collection.reloadData()
        super.viewDidDisappear(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.gallery_collection.contentOffset.y > self.gallery_collection.contentSize.height-self.gallery_collection.bounds.size.height
            {
                if(isAvailable){// 조건문에 api_end_token 이 true일때만 동작하도록
                    print("스크롤 캐치, 예전 내용load")
                    isAvailable = false
                    self.otherUserLoadData(url: server_url+"/feed/otheruser/load/public") { (ids_image, ids_id, ids_date, ids_imgdate) in
                        print("피드 로드, 스크롤로 인한 재로드")
                        self.image_ary.append(contentsOf: ids_image)
                        self.id_ary.append(contentsOf: ids_id)
                        self.date_ary_forseg.append(contentsOf: ids_date)
                        self.imgdate_ary_forseg.append(contentsOf: ids_imgdate)
                        self.gallery_collection.reloadData()
                        self.api_end_token = true
                        
                    }
                    // api 로드
                    // 로드 클로저에서 api_end_token = true로 바꾸고,, 선언부터 해야됨 1030일
                        // api_end_token << 한번에 여러쿼리 안보내게끔 락킹..
                    
                }
        }
    }// func scrollViewDidScroll : 스크롤 할때마다 계속 호출
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("스크롤 종료")
        // api_end_token이 true일때만 다시 동작하도록
        if api_end_token == true{
            isAvailable = true
            api_end_token = false
        }
        // api_end_token을 false로 다시 세팅
    }
    func otherUserLoadData(url: String, completion: @escaping ([UIImage],[String],[String],[String]) -> Void){
        let parameters: [String:String] = [
            "id":self.seg_userid,
            "offset":String(self.offset)
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids_image = [UIImage]()
                var ids_id = [String]()
                var ids_date = [String]()
                var ids_imgdate = [String]()
                switch response.result{
                case .success(let value):
                    let mygallerydata = JSON(value)// 응답
                    if (mygallerydata["err"]=="No item"){
                        print("!")
                        print("\(mygallerydata["err"])")
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
                                ids_id.append("\(m_json.1["id"])")
                                ids_date.append("\(m_json.1["date"])")
                                ids_imgdate.append("\(m_json.1["imgdate"])")
                            }
                            else{
                                print("이미지 없음 or 비공개 게시물.. 논리적 에러, 아예 추가하지 않는다.")
                            }
                            
                            if Int("\(m_json.1["likecount"])") != -1{
                                print("offset 이벤트 발생!")
                                print("\(m_json.1["likecount"])")
                                self.offset = Int("\(m_json.1["likecount"])")!
                                break
                            }// likecount 에 offset 적재해서 임시로 전송, offset의 증가는 서버에서 관리
                        }
                    }
                case .failure( _): break
                    
                }
                completion(ids_image, ids_id, ids_date, ids_imgdate)
            }
    }// other User load DB (컬렉션 뷰)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "other_to_gallery_seg"{
            print("segue other_to_gallery_seg")
            
            let dest = segue.destination
            print("dest : \(dest)")
            if let rvc = dest as? GalleryItemViewController {
                rvc.seg_userid = self.seg_userid
                rvc.seg_start_page = "OtherUserGalleryViewController"
                // 두개는 고정값
                rvc.seg_imgdate = self.seg_imgdate
                rvc.seg_date = self.seg_date
                // 두개는 컬렉션 뷰 선택에 따라 달라지는 값
            }
        }
    }
}
extension OtherUserGalleryViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.image_ary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feed_cell", for: indexPath) as! feed_cell
        
        cell.date.text = String(self.date_ary_forseg[indexPath.row].split(separator: "T")[0])
        cell.other_img.image = self.image_ary[indexPath.row]
        
        return cell
    }
    
    
    
}
extension OtherUserGalleryViewController:UICollectionViewDelegateFlowLayout {
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
//        print("collectionView width=\(collectionView.frame.width)")
//        print("cell하나당 width=\(width)")
//        print("root view width = \(self.view.frame.width)")
        self.cell_height = width+33
        self.cell_width = width
        return CGSize(width: width, height: width+53)
    }
    // 컬렉션 뷰 선택시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("컬렉션 선택, ", indexPath.row)
        print("seg 인자: 유저 이름, 게시글 날짜, 사진의 날짜")
        print(self.id_ary[indexPath.row], self.date_ary_forseg[indexPath.row], self.imgdate_ary_forseg[indexPath.row])
        self.seg_date = self.date_ary_forseg[indexPath.row]
        self.seg_imgdate = self.imgdate_ary_forseg[indexPath.row]
        self.performSegue(withIdentifier: "other_to_gallery_seg", sender: nil)
    }
}

