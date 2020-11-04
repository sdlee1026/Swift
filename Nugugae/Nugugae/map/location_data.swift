//
//  location_data.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/02.
//  Copyright © 2020 이성대. All rights reserved.
//
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class location_data:UIViewController,CLLocationManagerDelegate{
    let server_url:String = Server_url.sharedInstance.server_url
    // 외부 접속 url,ngrok
    let user:String = UserDefaults.standard.string(forKey: "userId")!
    // userid
    static let sharedInstance = location_data()
    
    var location_ary:[[Float]] = [[-1,-1],]
    var date_bylocation_ary:[String] = [""]
    
    
    var locationManager:CLLocationManager!
        // LocationManager 선언
    var latitude: Double?
    var longitude: Double?
    // 위도와 경도
    var img_latitude: Double = -1
    var img_longitude: Double = -1
    
    let date = DateFormatter()
    var start_time:String = ""
    var end_time:String = ""
    // 산책 시작, 종료 시간
    var init_location:String = ""
    
    func append_loctiondata_toary(inputdata: [Float]){
        self.location_ary.append(inputdata)
    }
    func append_date_bylocation_toary(inputdate: String){
        self.date_bylocation_ary.append(inputdate)
    }
    // ary append 동작
    
    func init_locationManager(){
        UserDefaults.standard.set("true",forKey: "walk_isrunning")
        // 포어그라운드, 백그라운드에서 산책 돌리기 위한 유저 디폴트 토큰 to true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.startUpdatingLocation()
        //위치업데이트
        locationManager.allowsBackgroundLocationUpdates = true
        // 백그라운드 동작 true
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if start_time == ""{
            print("첫 실행, start_time, first location 세팅")
            start_time = date.string(from: Date())
            print(start_time)
            init_location = String(latitude!)+","+String(longitude!)
            print(init_location)
        }
        // 시작 시간, 위치 설정
        
    }
    func init_update(){
        print("서버 쿼리 시작")
        postInitWalkdata(url: server_url+"/walkservice/init") { (ids) in
            print(ids)
        }
        // 산책 기록 (map data log_walksInfoTable)테이블에 넣기
        // 현재 산책하는 유저 테이블에 넣기
        
    }
    func stop_location(completion: @escaping ([String]) -> Void){
        UserDefaults.standard.set("false", forKey: "walk_isrunning")
        print("walk_isrunning false로 세팅")
        print("토큰 : ",UserDefaults.standard.string(forKey: "walk_isrunning")!)
        // walk_isrunning false로 세팅, 산책 종료 버튼을 누르거나, 백그라운드에서 or 포어그라운드에서
        // true로 산책 도중 종료 되었을 경우
        var endMsg = []
        
        deleteNowWalkdata(url: server_url+"/walkservice/stop/nowwalk") { (ids) in
            print("산책 종료로 인한 유저 추적 테이블 제거")
            print(ids)
            endMsg.append(contentsOf: ids)
        }
        // 현재 산책인원 추적 종료, nowWalking tabel del
        
        
        end_time = date.string(from: Date())
        print("종료 시간 세팅")
        // 종료 시간 세팅
        
        // 남은 큐에 있는 위치 데이터 서버로 전송
        
        locationManager = nil
        start_time = ""
        print("location manager, 변수들 메모리 할당 해제")
        location_data.sharedInstance.location_ary = [[-1,-1],]
        location_data.sharedInstance.date_bylocation_ary = [""]
        
        completion(endMsg)
        
    }// 산책 중지 버튼을 통해 동작하는 정리 api들, 현재 산책인원 정리, 남은 데이터 서버에 저장
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("위치 업데이트됨")
        let now = Date()
        print(date.string(from: now))
        if let coor = manager.location?.coordinate{
            let input_loction = [Float(coor.latitude), Float(coor.longitude)]
            print("ary_들어있는 위치값 갯수:")
            print(location_data.sharedInstance.location_ary.count)
            let last_index = location_data.sharedInstance.location_ary.endIndex - 1// 배열 마지막 인덱스
                
            if location_data.sharedInstance.location_ary[last_index] == [-1,-1]{
                location_data.sharedInstance.location_ary[last_index] = input_loction
                location_data.sharedInstance.date_bylocation_ary[last_index] = date.string(from: now)
            }// 첫번째 insert
                else if location_data.sharedInstance.location_ary[last_index] == input_loction{
                    // 위치 변동이 없었을 경우
                    print("위치 변동 x, not insert")
                }
                else{
                    print("위치 변동 o, insert to ary")
                    location_data.sharedInstance.append_loctiondata_toary(inputdata:input_loction)
                    // 위치값 배열에 넣기..
                    location_data.sharedInstance.append_date_bylocation_toary(inputdate: date.string(from: now))
                    // 그 위치에 있었을 때 시간 배열에 넣기
                    print("ary_들어있는 위치값 갯수:(추가한 후)")
                    print(location_data.sharedInstance.location_ary.count)
                    print(location_data.sharedInstance.date_bylocation_ary.count)
                }
                
            }
        
        if location_data.sharedInstance.location_ary.count == 10{
            let post_location_ary = location_data.sharedInstance.location_ary
            let post_date_bylocation_ary = location_data.sharedInstance.date_bylocation_ary
            location_data.sharedInstance.location_ary = [[-1,-1],]
            location_data.sharedInstance.date_bylocation_ary = [""]
            
            print("보낼 데이터 갯수 : ", post_location_ary.count)
            print("보낼 시간 데이터 갯수 : ", post_date_bylocation_ary.count)
            print("다시 준비할 데이터 갯수 : ", location_data.sharedInstance.location_ary.count)
            print("유저 마지막 좌표 : ", post_location_ary[post_location_ary.endIndex-1])
            print("마지막 좌표에 있었던 시간 : ", post_date_bylocation_ary[post_date_bylocation_ary.endIndex-1])
            
        }// 10개 모였을때 서버로 데이터 보냄, 이 때 맨 마지막 좌표는 산책 기록 테이블이 아닌, 현재 산책 인원 관리 테이블로..
    }

    func postInitWalkdata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
            "date":self.start_time,
            "starttime":self.start_time,
            "location_data":self.init_location,
            "date_bylocation":self.start_time
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let writedata = JSON(value)// 응답
                        print("\(writedata["content"])")
                        ids.append("\(writedata["content"])")
                    case .failure( _): break
                }
                completion(ids)
            }
        
    }// walk info init, DB
    
    func deleteNowWalkdata(url: String, completion: @escaping ([String]) -> Void){
        let parameters: [String:String] = [
            "id":self.user,
        ]
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody))
            .responseJSON{ response in
                var ids = [String]()
                switch response.result{
                    case .success(let value):
                        let writedata = JSON(value)// 응답
                        print("\(writedata["content"])")
                        ids.append("\(writedata["content"])")
                    case .failure( _): break
                }
                completion(ids)
            }
    }// nowWalking table delete, DB
}//class end
