//
//  location_data.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/02.
//  Copyright © 2020 이성대. All rights reserved.
//
import UIKit
import CoreLocation

class location_data:UIViewController,CLLocationManagerDelegate{
    static let sharedInstance = location_data()
    
    var location_ary:[[Float]] = [[-1,-1],]
    
    
    var locationManager:CLLocationManager!
        // LocationManager 선언
    var latitude: Double?
    var longitude: Double?
    // 위도와 경도
    var img_latitude: Double = -1
    var img_longitude: Double = -1
    
    func append_loctiondata_toary(inputdata: [Float]){
        self.location_ary.append(inputdata)
    }
    
    func initfunc(){
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
    }
    func stop_location(){
        locationManager = nil
        print("location manager 메모리 할당 해제")
        // 남은 큐에 있는 위치 데이터 서버로 전송
        // 현재 산책인원 추적 종료
        
        
    }// 산책 중지 버튼을 통해..
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
            print("위치 업데이트됨")
            if let coor = manager.location?.coordinate{
                let input_loction = [Float(coor.latitude), Float(coor.longitude)]
                print("ary_들어있는 위치값 갯수:")
                print(location_data.sharedInstance.location_ary.count)
                let last_index = location_data.sharedInstance.location_ary.endIndex - 1// 배열 마지막 인덱스
                
                if location_data.sharedInstance.location_ary[last_index] == [-1,-1]{
                    location_data.sharedInstance.location_ary[last_index] = input_loction
                }// 첫번째 insert
                else if location_data.sharedInstance.location_ary[last_index] == input_loction{
                    // 위치 변동이 없었을 경우
                    print("위치 변동 x, not insert")
                }
                else{
                    print("위치 변동 o, insert to ary")
                    location_data.sharedInstance.append_loctiondata_toary(inputdata:input_loction)
                    print("ary_들어있는 위치값 갯수:(추가한 후)")
                    print(location_data.sharedInstance.location_ary.count)
                }
                
            }
        
        if location_data.sharedInstance.location_ary.count == 10{
            
        }// 10개 모였을때 서버로 데이터 보냄, 이 때 맨 마지막 좌표는 산책 기록 테이블이 아닌, 현재 산책 인원 관리 테이블로..
    }

    
}
