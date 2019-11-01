//
//  ALMapService.swift
//  AirportLocatorApp
//
//  Created by Bhagyashree Haresh Khatri on 01/11/2019.
//  Copyright © 2019 Bhagyashree Haresh Khatri. All rights reserved.
//

import Foundation

class ALMapService {
    
    public func callAPIAirportList(latitude:String,longitude:String,onSuccess successCallback: ((_ list: AirportListModel) -> Void)?, onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        APICallManager.instance.callAPIAirportList(latitude:latitude,longitude:longitude,
            onSuccess: { (list) in
                successCallback?(list)
        },
            onFailure: { (errorMessage) in
                failureCallback?(errorMessage)
        })
    }
}
