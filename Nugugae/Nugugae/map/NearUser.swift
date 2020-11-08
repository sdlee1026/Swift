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
    var marker_ary:Dictionary = [String:NMFMarker]()
    
}// 근처 유저 딕셔너리 관리클래스
