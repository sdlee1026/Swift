//
//  NearUser.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/07.
//  Copyright © 2020 이성대. All rights reserved.
//

import Foundation
import NMapsMap
class NearUser{
    static let sharedInstance = NearUser()
    var userdic:Dictionary = [String:[Double]]()
    // 유저 아이디: 위치값
    var marker_ary:Dictionary = [String:NMFMarker]()
    // 유저 마커
    var infowindow_ary:Dictionary = [String:NMFInfoWindow]()
    // 유저 마커-정보창
}// 근처 유저 딕셔너리 관리클래스
