//
//  ViewController.swift
//  MapViewTest
//
//  Created by 이성대 on 2020/04/14.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var myMap: MKMapView!
    // map outlet(strong)
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    
    // label outlets(strong)
    @IBAction func sgChangeLocation(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // "현재 위치" 선택 - 현재 위치 표시
            let coor = locationManager.location?.coordinate
            let latitude = coor?.latitude
            let longitude = coor?.longitude
            print(latitude as Any)
            print(longitude as Any)
            setAnnotation(latitudeValue: latitude!, longitudeValue: longitude!, delta: 0.1, title: "현재위치", subtitle: "sub 설명")
            self.label1.text = ""
            self.label2.text = ""
            locationManager.startUpdatingLocation()
        } else if sender.selectedSegmentIndex == 1 {
            // "물왕저수지 정통밥집" 선택 - 핀을 설치하고 위치 정보 표시
            setAnnotation(latitudeValue: 37.3826616, longitudeValue: 126.840719, delta: 0.1, title: "물왕저수지 정통밥집", subtitle: "경기 시흥시 동서로857번길 6")
            self.label1.text = "보고 계신 위치"
            self.label2.text = "물왕저수지 정통밥집"
        } else if sender.selectedSegmentIndex == 2 {
            // "이디야 북한산점" 선택 - 핀을 설치하고 위치 정보 표시
            setAnnotation(latitudeValue: 37.6447360, longitudeValue: 127.005575, delta: 0.1, title: "이디야 북한산점", subtitle: "서울 강북구 4.19로 85")
                       self.label1.text = "보고 계신 위치"
                       self.label2.text = "이디야 북한산점"
        }
            
    }
    // Action segement, UISegmentedControl type
    
    let locationManager = CLLocationManager()
    
    // 위도와 경도, 스팬(영역 폭)을 입력받아 지도에 표시
    func goLocation(latitudeValue: CLLocationDegrees,
                    longtudeValue: CLLocationDegrees,
                    delta span: Double) -> CLLocationCoordinate2D {
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longtudeValue)
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        myMap.setRegion(pRegion, animated: true)
        return pLocation
    }
    // 특정 위도와 경도에 핀 설치하고 핀에 타이틀과 서브 타이틀의 문자열 표시
    func setAnnotation(latitudeValue: CLLocationDegrees,
                       longitudeValue: CLLocationDegrees,
                       delta span :Double,
                       title strTitle: String,
                       subtitle strSubTitle:String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = goLocation(latitudeValue: latitudeValue, longtudeValue: longitudeValue, delta: span)
        annotation.title = strTitle
        annotation.subtitle = strSubTitle
        myMap.addAnnotation(annotation)
    }
    // 위치 정보에서 국가, 지역, 도로를 추출하여 레이블에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let pLocation = locations.last
        _ = goLocation(latitudeValue: (pLocation?.coordinate.latitude)!,
                   longtudeValue: (pLocation?.coordinate.longitude)!,
                   delta: 0.01)
        CLGeocoder().reverseGeocodeLocation(pLocation!, completionHandler: {(placemarks, error) -> Void in
            let pm = placemarks!.first
            let country = pm!.country
            var address: String = ""
            if country != nil {
                address = country!
            }
            if pm!.locality != nil {
                address += " "
                address += pm!.locality!
            }
            if pm!.thoroughfare != nil {
                address += " "
                address += pm!.thoroughfare!
            }
            self.label1.text = "현재 위치"
            self.label2.text = address
        })
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label1.text = ""
        label2.text = ""
        locationManager.delegate = self
        
        // 정확도를 최고로 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 위치 데이터를 추적하기 위해 사용자에게 승인 요구
        locationManager.requestWhenInUseAuthorization()
        
        // 위치 업데이트를 시작
        locationManager.startUpdatingLocation()
        
        // 위치 보기 설정
        myMap.showsUserLocation = true
    }
    


}

