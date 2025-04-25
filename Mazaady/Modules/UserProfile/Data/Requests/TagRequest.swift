//
//  tagRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import Alamofire

struct TagRequest: BaseRequest {
    
    var path: String {
        "/tags"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
}

