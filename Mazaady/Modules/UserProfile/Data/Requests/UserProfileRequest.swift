//
//  UserProfileRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire

struct UserProfileRequest: BaseRequest {
    var path: String {
        "/user"
    }
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
}
