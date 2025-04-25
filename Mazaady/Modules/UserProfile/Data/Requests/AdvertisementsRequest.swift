//
//  AdvertisementsRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire

struct AdvertisementsRequest: BaseRequest {
    var path: String {
        "/advertisements"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
}
