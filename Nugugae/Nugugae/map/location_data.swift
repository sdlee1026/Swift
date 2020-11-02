//
//  location_data.swift
//  Nugugae
//
//  Created by 이성대 on 2020/11/02.
//  Copyright © 2020 이성대. All rights reserved.
//
class location_data{
    static let sharedInstance = location_data()
    var location_ary:[[Float]] = [[-1,-1],]
    
    func append_loctiondata_toary(inputdata: [Float]){
        self.location_ary.append(inputdata)
    }
    
}
